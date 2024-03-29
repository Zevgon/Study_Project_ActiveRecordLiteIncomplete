require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.camelcase.constantize
  end

  def table_name
    @class_name.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    unless options.keys.empty?
      options.keys.each do |key|
        instance_variable_set("@#{key}", options[key])
      end
    end
    @foreign_key ||= "#{name.to_s}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    unless options.keys.empty?
      options.keys.each do |key|
        instance_variable_set("@#{key}", options[key])
      end
    end
    @foreign_key ||= "#{self_class_name.downcase}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.capitalize.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    p options
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
