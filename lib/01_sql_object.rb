require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns = cols.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
  end

  def self.table_name
    name = "#{self}"
    result = ""
    name.each_char.with_index do |char, idx|
      if idx == 0
        result << char.downcase
        next
      elsif
        char =~ /[A-Z]/
        result << "_#{char.downcase}"
      else
        result << char
      end
    end
    result + "s"
  end


  def self.all
    items = DBConnection.execute(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL

    parse_all(items)
  end

  def self.parse_all(results)
    answer = []
    results.each do |hash|
      answer << self.new(hash)
    end

    answer
  end

  def self.find(id)
    all.each do |object|
      return object if object.id == id
    end

    nil
  end

  def initialize(params = {})
    params.each do |col, val|
      col = col.to_sym
      raise "unknown attribute \'#{col}\'" unless self.class.columns.include?(col)
      self.send("#{col}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      self.send(col)
    end
  end

  def insert
    col_names = self.class.columns.drop(1).join(", ")
    question_marks = Array.new(self.class.columns.length - 1) {"?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL


    self.send(:id=, DBConnection.last_insert_row_id)
  end

  def update
    set_row = self.class.columns.map do |col|
      "#{col} = ?"
    end.drop(1).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_row}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id
      update
    else
      insert
    end
  end
end
