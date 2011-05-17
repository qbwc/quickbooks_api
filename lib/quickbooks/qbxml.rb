# namespace for dynamically gnerated schema classes
module Quickbooks::Qbxml; end

# inheritance base for schema classes
class Quickbooks::Qbxml::Base
  include Quickbooks
  include Quickbooks::Support

#QB_TYPE_CONVERSION_MAP= {
  #"DATETIMETYPE" => lambda {|d| Date.parse(d)},
  #"ENUMTYPE"     => lambda {|d| String(d)},
  #"IDTYPE"       => lambda {|d| String(d)},
  #"INTTYPE"      => lambda {|d| Integer(d)},
  #"PERCENTTYPE"  => lambda {|d| Float(d)},
  #"QUANTTYPE"    => lambda {|d| Integer(d)},
  #"STRTYPE"      => lambda {|d| String(d)}
#}

QB_TYPE_CONVERSION_MAP= {
  "DATETIMETYPE" => lambda {|d| String(d)},
  "ENUMTYPE"     => lambda {|d| String(d)},
  "IDTYPE"       => lambda {|d| String(d)},
  "INTTYPE"      => lambda {|d| String(d)},
  "PERCENTTYPE"  => lambda {|d| String(d)},
  "QUANTTYPE"    => lambda {|d| String(d)},
  "STRTYPE"      => lambda {|d| String(d)}
}

def initialize(params = nil)
  return unless params.is_a?(Hash)
  params.each do |k,v|
    if self.respond_to?(k)
      self.send("#{k}=", v)
    end
  end
end

def to_xml
  xml_doc = Nokogiri::XML(self.class.xml_template)
  root = xml_doc.root
  log.debug "to_xml#nodes_size: #{root.children.size}"

  filled_nodes = []
  root.children.each do |n|
    log.debug "to_xml#n.class: #{n.class}"
    case n
    when XML_ELEMENT
      attr_name = to_attribute_name(n.name)
      log.debug "to_xml#attr_name: #{attr_name}"

      val = self.send(attr_name)
      log.debug "to_xml#val: #{val}"
      
      if val
        if is_leaf_node?(n)
          n.children = val.to_s
          filled_nodes.push(n)
        else
          filled_nodes.push(val.to_xml)
        end
      end
    else next
    end
  end
  log.debug "to_xml#filled_nodes_size: #{filled_nodes.size}"
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

end
