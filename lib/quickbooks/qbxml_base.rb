# inheritance base for schema classes
class Quickbooks::QbxmlBase
  include Quickbooks::Support
  extend  Quickbooks::Support
  include Quickbooks::Support::QBXML

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

  # replace all children nodes of the template with populated data nodes
  xml_nodes = []
  root.children.each do |template|
    next unless template.is_a? XML_ELEMENT
    attr_name = to_attribute_name(template)
    log.debug "to_qbxml#attr_name: #{attr_name}"

    val = self.send(attr_name)
    next unless val

    case val
    when Array
      xml_nodes += build_qbxml_nodes(template, val)
    else
      xml_nodes << build_qbxml_node(template, val)
    end
    log.debug "to_qbxml#val: #{val}"
  end

  log.debug "to_qbxml#xml_nodes_size: #{xml_nodes.size}"
  root.children = xml_nodes.join('')
  root
end


def inner_attributes
  top_level_attrs = \
    self.class.attribute_names.inject({}) do |h, m|
      h[m] = self.send(m); h
    end
  
  values = top_level_attrs.values.compact
  if values.size > 1 || values.first.is_a?(Array)
    attributes
  else
    values.first.inner_attributes
  end
end


def attributes
  self.class.attribute_names.inject({}) do |h, m|
    val = self.send(m)
    h[m] = \
      case val
      when Quickbooks::QbxmlBase
        val.attributes
      when Array
        val.inject([]) do |a, obj| 
          case obj
          when Quickbooks::QbxmlBase
            a << obj.attributes 
          else a << obj
          end
        end
      else
        val
      end; h
  end
end
##########

# class methods

def self.attribute_names
  instance_methods(false).reject { |m| m[-1..-1] == '=' || m =~ /_xml_class/} 
end


def self.type_map
  attribute_names.inject({}) do |h, a|
    attr_type = self.send("#{a}_type") 
    h[a] = is_cached_class?(attr_type) ? attr_type.type_map : attr_type; h
  end
end


private


def build_qbxml_node(node, val)
  case val
  when Quickbooks::QbxmlBase
    val.to_qbxml
  else
    node.children = val.to_s
    xml_nodes << node
  end
end

def build_qbxml_nodes(node, val)
  val.inject([]) do |a, v|
    n = clone_qbxml_node(node,v)
    a << n
  end
end

def clone_qbxml_node(node, val)
  n = node.clone
  n.children = \
    case val
    when Quickbooks::QbxmlBase
      val.to_qbxml 
    else 
      val.to_s
    end; n
end

end
