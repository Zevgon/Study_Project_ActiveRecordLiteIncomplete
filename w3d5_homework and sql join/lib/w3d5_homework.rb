class CorgiTest
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

CorgiTest.instance_eval do
  def who_am_i
    "I am #{self}!"
  end

  def self.format_name
    class_name = "#{self}"
    result = ""
    class_name.each_char.with_index do |char, idx|
      if idx == 0
        result << char.downcase
        next
      elsif char =~ /[A-Z]/
        result << "_#{char.downcase}"
      else
        result << char
      end
    end

    result + "s"
  end
end

p CorgiTest.format_name
