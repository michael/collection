require 'rubygems'
require 'json'
require 'date'
require 'fastercsv'

# Collection API
# ==============================================================================
# 
# Usage:
# 
# c = Collection.new
# c.property(:customer, {:name => "Customer", :type => String, :unique => true })
# c.property(:product, {:name => "Product", :type => String, :unique => true })
# c.property(:quantity, {:name => "Salesman", :type => Numeric, :unique => true })
# c.property(:price, {:name => "Price", :type => Numeric, :unique => true })
# 
# c.add("IO47181", {
#   :customer => "John Smith",
#   :product => "XT52",
#   :quantity => 21,
#   :price => 231.5
# })
#
# c.to_json
# c.to_csv
#


class Collection
  
  class PropertyExists        < StandardError ; end
  class PropertyNotFound      < StandardError ; end
  
  
  module Formatters
    def self.number_to_currency(number, options = {})
        precision = options[:precision] || 2
        unit      = options[:unit] || ""
        separator = precision > 0 ? options[:separator] || "." : ""
        delimiter = options[:delimiter] || ""
        format    = options[:format] || "%u%n"
      begin
        parts = number_with_precision(number, precision).split('.')
        format.gsub(/%n/, number_with_delimiter(parts[0], delimiter) + separator + parts[1].to_s).gsub(/%u/, unit)
      rescue
        number
      end
    end
    
    def self.number_with_delimiter(number, delimiter=",", separator=".")
      begin
        parts = number.to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        parts.join separator
      rescue
        number
      end
    end
    
    def self.number_with_precision(number, precision=3)
      "%01.#{precision}f" % ((Float(number) * (10 ** precision)).round.to_f / 10 ** precision)
    rescue
      number
    end
  end
  
  class Property
    attr_accessor :key, :name, :type, :descr, :collection

    def initialize(collection, key, options)
      @collection, @key = collection, key
      @name = options[:name]
      @type = options[:type]
      @descr = options[:descr]
      @unique = options[:unique]
    end
    
    def type_as_string
      if type.kind_of?(Numeric)
        "number"
      elsif type.kind_of?(Date)
        "date"
      else
        "string"
      end
    end
    
    def to_hash
      {
        :name => @name,
        :type => type_as_string,
        :descr => @descr.to_s,
        :unique => @unique
      }
    end
    
    def unique?
      @unique
    end
  end
  
  class Item
    attr_accessor :values
    
    def initialize(collection, key, values)
      @collection, @key, @values = collection, key, values
    end
    
    def value(property_key)
      raise PropertyNotFound unless @collection.properties.key?(property_key)
      @values[property_key]
    end
  end
  
  attr_reader :properties
  attr_reader :items
  
  def initialize
    @properties = {}
    @items = {}
    
    # preserve the insertion order
    @property_keys = []
    @item_keys = []
  end
  
  def property(key, options)
    @properties[key] = Property.new(self, key, options)
    @property_keys << key
  end
  
  def add(key, item)
    @items[key] = Item.new(self, key, item)
    @item_keys << key
  end
  
  def remove(key)
    @items.delete(key)
  end
  
  def to_json
    result = {:properties => {}, :items => {}}
    
    @property_keys.each do |key|
      result[:properties][key] = @properties[key].to_hash
    end
    
    @item_keys.each do |key|
      result[:items][key] = @items[key].values
    end
    
    JSON.pretty_generate(result)
  end
  
  def to_csv(options = { :col_sep => ',', :number_delimiter => '', :number_separator => '.' })
    csv_options = options.clone
    csv_options.delete(:number_delimiter)
    csv_options.delete(:number_separator)
    
    FasterCSV.generate(csv_options) do |csv|
      # Add headers
      headers = []
      @property_keys.each do |key|
        headers << @properties[key].name
      end
      csv << headers
      
      # Add data rows
      @item_keys.each do |item_key|
        row_data = []
        @property_keys.each do |property_key|
          val = @items[item_key].value(property_key)
          if val.kind_of?(Numeric)
            row_data << Formatters.number_to_currency(val, :separator => options[:number_separator], :delimiter => options[:number_delimiter])
          else
            row_data << val
          end
        end
        csv << row_data
      end
      
    end
  end
end
