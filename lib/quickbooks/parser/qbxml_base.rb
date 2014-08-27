# inheritance base for schema classes
class Quickbooks::Parser::QbxmlBase
  include Quickbooks::Logger
  extend  Quickbooks::Logger
  include Quickbooks::Parser::XMLGeneration

  QBXML_BASE = Quickbooks::Parser::QbxmlBase

  FLOAT_CAST = Proc.new {|d| d ? Float(d) : 0.0}                                  
  BOOL_CAST  = Proc.new {|d| d ? (d == 'true' ? true : false) : false }          
  DATE_CAST  = Proc.new {|d| d ? Date.parse(d).strftime("%Y-%m-%d") : Date.today.strftime("%Y-%m-%d") } 
  TIME_CAST  = Proc.new {|d| d ? Time.parse(d).xmlschema : Time.now.xmlschema }   
  INT_CAST   = Proc.new {|d| d ? Integer(d.to_i) : 0 }                                 
  STR_CAST   = Proc.new {|d| d ? String(d) : ''}                                  

  QB_TYPE_CONVERSION_MAP= {
    "AMTTYPE"          => FLOAT_CAST,
    "BOOLTYPE"         => BOOL_CAST,
    "DATETIMETYPE"     => TIME_CAST,
    "DATETYPE"         => DATE_CAST,
    "ENUMTYPE"         => STR_CAST,
    "FLOATTYPE"        => FLOAT_CAST,
    "GUIDTYPE"         => STR_CAST,
    "IDTYPE"           => STR_CAST,
    "INTTYPE"          => INT_CAST,
    "PERCENTTYPE"      => FLOAT_CAST,
    "PRICETYPE"        => FLOAT_CAST,
    "QUANTYPE"         => INT_CAST,
    "STRTYPE"          => STR_CAST,
    "TIMEINTERVALTYPE" => STR_CAST
  }

  attr_accessor :xml_attributes
  class << self
    attr_accessor :xml_attributes
  end

  def initialize(params = nil)
    return unless params.is_a?(Hash)
    @xml_attributes = params['xml_attributes'] || params[:xml_attributes] || {}
    params.delete('xml_attributes')
    params.delete(:xml_attributes)

    params.each do |attr, value|
      if self.respond_to?(attr)
        expected_attr_type = self.class.send("#{attr}_type")
        value = \
          case value
          when Hash
            expected_attr_type.new(value)
          when Array
            value.inject([]) { |a,i| a << expected_attr_type.new(i) }
          else value
          end
        self.send("#{attr}=", value)
      else
        log.info "Warning: instance #{self} does not respond to attribute #{attr}"
      end
    end
  end

  def self.attribute_names
    # 1.9.2 changes instance_methods behavior to return symbols instead of strings
    instance_methods(false).reject { |m| m[-1..-1] == '=' || m.to_s =~ /xml_attributes/ || m =~ /_xml_class/}.map { |m| m.to_s }
  end

  # returns innermost attributes without outer layers of the hash
  #
  def inner_attributes(parent = self)
    attrs = attributes(false)
    attrs.delete('xml_attributes')
    values = attrs.values.compact

    if values.empty?
      attributes
    elsif values.first.is_a?(Array)
      attributes
    elsif values.size > 1
      parent.attributes
    else
      first_val = values.first
      if first_val.respond_to?(:inner_attributes)
        first_val.inner_attributes(self)
      else
        parent.attributes
      end
    end
  end

  def attributes(recursive = true)
    attrs = {}
    attrs['xml_attributes'] = xml_attributes
    self.class.attribute_names.inject(attrs) do |h, m|
      val = self.send(m)
      if !val.nil?
        if recursive
          h[m] = case val
            when QBXML_BASE
              val.attributes
            when Array
              val.inject([]) { |a, obj| obj.is_a?(QBXML_BASE) ? a << obj.attributes : a << obj } 
            else val
            end
        else
          h[m] = val
        end
      end; h
    end
  end

  # returns a type map of the object's attributes
  #
  def self.template(recursive = false, reload = false)
    if recursive
      @template = (!reload && @template) || build_template(true)
    else build_template(false)
    end
  end

private

  def self.build_template(recursive = false)
    attribute_names.inject({}) do |h, a|
      attr_type = self.send("#{a}_type") 
      h[a] = ((attr_type < QBXML_BASE) && recursive) ? attr_type.build_template(true): attr_type.to_s; h
    end
  end

end
