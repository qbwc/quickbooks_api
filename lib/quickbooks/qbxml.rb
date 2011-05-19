# inheritance base for schema classes
class Quickbooks::QbxmlBase
  include Quickbooks::Support
  extend  Quickbooks::Support
  include Quickbooks::Support::XML

#QB_TYPE_CONVERSION_MAP= {
  #"AMTTYPE"          => lambda {|d| String(d)},
  #"BOOLTYPE"         => lambda {|d| String(d)},
  #"DATETIMETYPE"     => lambda {|d| Date.parse(d)},
  #"DATETYPE"         => lambda {|d| Date.parse(d)},
  #"ENUMTYPE"         => lambda {|d| String(d)},
  #"FLOATTYPE"        => lambda {|d| String(d)},
  #"GUIDTYPE"         => lambda {|d| String(d)},
  #"IDTYPE"           => lambda {|d| String(d)},
  #"INTTYPE"          => lambda {|d| Integer(d)},
  #"PERCENTTYPE"      => lambda {|d| Float(d)},
  #"PRICETYPE"        => lambda {|d| Float(d)},
  #"QUANTYPE"         => lambda {|d| Integer(d)},
  #"STRTYPE"          => lambda {|d| String(d)},
  #"TIMEINTERVALTYPE" => lambda {|d| String(d)}
#}

QB_TYPE_CONVERSION_MAP= {
  "AMTTYPE"          => lambda {|d| String(d)},
  "BOOLTYPE"         => lambda {|d| String(d)},
  "DATETIMETYPE"     => lambda {|d| String(d)},
  "DATETYPE"         => lambda {|d| String(d)},
  "ENUMTYPE"         => lambda {|d| String(d)},
  "FLOATTYPE"        => lambda {|d| String(d)},
  "GUIDTYPE"         => lambda {|d| String(d)},
  "IDTYPE"           => lambda {|d| String(d)},
  "INTTYPE"          => lambda {|d| String(d)},
  "PERCENTTYPE"      => lambda {|d| String(d)},
  "PRICETYPE"        => lambda {|d| String(d)},
  "QUANTYPE"         => lambda {|d| String(d)},
  "STRTYPE"          => lambda {|d| String(d)},
  "TIMEINTERVALTYPE" => lambda {|d| String(d)}
}


def initialize(params = nil)
  return unless params.is_a?(Hash)
  params.each do |k,v|
    if self.respond_to?(k)
      self.send("#{k}=", v)
    end
  end
end

def to_qbxml
  xml_doc = Nokogiri::XML(self.class.xml_template)
  root = xml_doc.root
  log.debug "to_qbxml#nodes_size: #{root.children.size}"

  filled_nodes = []
  root.children.each do |n|
    log.debug "to_qbxml#n.class: #{n.class}"
    case n
    when XML_ELEMENT
      attr_name = to_attribute_name(n.name)
      log.debug "to_qbxml#attr_name: #{attr_name}"

      val = self.send(attr_name)
      log.debug "to_qbxml#val: #{val}"
      
      if val
        if is_leaf_node?(n)
          n.children = val.to_s
          filled_nodes.push(n)
        else
          filled_nodes.push(val.to_qbxml)
        end
      end
    else next
    end
  end
  log.debug "to_qbxml#filled_nodes_size: #{filled_nodes.size}"
  root.children = filled_nodes.join('')
  root
end

def attributes
  self.class.attribute_names.inject({}) do |h, m|
    h[m] = self.send(m); h
  end
end

def self.attribute_names
  instance_methods(false).reject { |m| m[-1..-1] == '=' } 
end

def self.type_map
  attribute_names.inject({}) do |h, a|
    attr_type = self.send("#{a}_type") 
    h[a] = is_cached_class?(attr_type) ? attr_type.type_map : attr_type; h
  end
end

end
