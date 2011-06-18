# inheritance base for schema classes
class Quickbooks::QbxmlBase
  include Quickbooks::Support
  include Quickbooks::Support::QBXML

  extend  Quickbooks::Support
  extend  Quickbooks::Support::API

QB_TYPE_CONVERSION_MAP= {
  "AMTTYPE"          => lambda {|d| d ? Float(d) : 0.0 },
  #"BOOLTYPE"         => lambda {|d| d ? (d == 'True' ? true : false) : false },
  "BOOLTYPE"         => lambda {|d| d ? String(d) : '' },
  "DATETIMETYPE"     => lambda {|d| d ? Time.parse(d).xmlschema : Time.now.xmlschema },
  "DATETYPE"         => lambda {|d| d ? Date.parse(d).xmlschema : Date.today.xmlschema },
  "ENUMTYPE"         => lambda {|d| d ? String(d) : ''},
  "FLOATTYPE"        => lambda {|d| d ? Float(d) : 0.0},
  "GUIDTYPE"         => lambda {|d| d ? String(d) : ''},
  "IDTYPE"           => lambda {|d| d ? String(d) : ''},
  "INTTYPE"          => lambda {|d| d ? Integer(d) : 0 },
  "PERCENTTYPE"      => lambda {|d| d ? Float(d) : 0.0 },
  "PRICETYPE"        => lambda {|d| d ? Float(d) : 0.0 },
  "QUANTYPE"         => lambda {|d| d ? Integer(d.to_i) : 0 },
  "STRTYPE"          => lambda {|d| d ? String(d) : ''},
  "TIMEINTERVALTYPE" => lambda {|d| d ? String(d) : ''}
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
  root.children.each do |xml_template|
    next unless xml_template.is_a? XML_ELEMENT
    attr_name = to_attribute_name(xml_template)
    log.debug "to_qbxml#attr_name: #{attr_name}"

    val = self.send(attr_name)
    next unless val

    case val
    when Array
      xml_nodes += build_qbxml_nodes(xml_template, val)
    else
      xml_nodes << build_qbxml_node(xml_template, val)
    end
    log.debug "to_qbxml#val: #{val}"
  end

  log.debug "to_qbxml#xml_nodes_size: #{xml_nodes.size}"
  root.children = xml_nodes.join('')
  root.to_s
end


def self.template(recursive = false, use_disk_cache = false, reload = false)
  if recursive
    @template = (!reload && @template) || load_template(true, use_disk_cache)
  else build_template(false)
  end
end


def self.attribute_names
  instance_methods(false).reject { |m| m[-1..-1] == '=' || m =~ /_xml_class/} 
end


def inner_attributes
  top_level_attrs = \
    self.class.attribute_names.inject({}) do |h, m|
      h[m] = self.send(m); h
    end
  
  values = top_level_attrs.values.compact
  if values.empty?
    {}
  elsif values.size > 1 || values.first.is_a?(Array)
    attributes
  else
    values.first.inner_attributes
  end
end


def attributes(recursive = true)
  self.class.attribute_names.inject({}) do |h, m|
    val = self.send(m)
    if val
      unless recursive
        h[m] = val
      else
        h[m] = nested_attributes(val)
      end
    end; h
  end
end


private

# qbxml conversion

def nested_attributes(val)
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
  else val
  end
end

def build_qbxml_node(node, val)
  case val
  when Quickbooks::QbxmlBase
    val.to_qbxml
  else
    node.children = val.to_s
    node
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

# qbxml class templates

def self.load_template(recursive = false, use_disk_cache = false)
  if use_disk_cache && File.exist?(template_cache_path)
    YAML.load(File.read(template_cache_path))
  else
    log.info "Warning: on disk template is missing, rebuilding..." if use_disk_cache
    template = build_template(recursive)
    dump_template(template) if use_disk_cache
    template
  end
end

def self.build_template(recursive = false)
  attribute_names.inject({}) do |h, a|
    attr_type = self.send("#{a}_type") 
    h[a] = (is_cached_class?(attr_type) && recursive) ? attr_type.build_template(true): attr_type.to_s; h
  end
end

def self.dump_template(template)
  File.open(template_cache_path, 'w') do |f|
    f << template.to_yaml
  end
end

def self.template_cache_path
  "#{get_template_cache_path}/#{to_attribute_name(self)}.yml"
end

def self.schema_type
  namespace = self.to_s.split("::")[1]
  API::SCHEMA_MAP.find do |k,v|
    simple_class_name(v[:namespace]) == namespace
  end.first
end


end
