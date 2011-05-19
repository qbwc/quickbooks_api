class Quickbooks::DtdParser < Quickbooks::QbxmlParser
  include Quickbooks::ClassBuilder

COMMENT_START = "<!--"
COMMENT_END = "-->"
COMMENT_MATCHER = /\A#{COMMENT_START}.*#{COMMENT_END}\z/


def parse_file(qbxml_file)
  parse( 
    cleanup_qbxml(
      File.read(qbxml_file)))
end

private

def process_leaf_node(xml_obj, parent_class)
 attr_name, qb_type = parse_leaf_node_type(xml_obj)
  if parent_class
    add_casting_attribute(parent_class, attr_name, qb_type)
  end
end

def process_non_leaf_node(xml_obj, parent_class)
  klass = build_qbxml_class(xml_obj)
  attr_name = to_attribute_name(klass)
  if parent_class
    add_strict_attribute(parent_class, attr_name, klass)
  end
  klass
end

def process_comment_node(xml_obj, parent_class)
  parent_class
end

# helpers

def parse_leaf_node_type(xml_obj)
  attr_name = to_attribute_name(xml_obj)
  text_node = xml_obj.children.first
  [attr_name, text_node.text]
end

def build_qbxml_class(xml_obj)
  obj_name = xml_obj.name
  unless qbxml_class_defined?(obj_name) 
    klass = Class.new(QbxmlBase)
    get_schema_namespace.const_set(obj_name, klass) 
    add_xml_template(klass, xml_obj.to_xml)
  else
    klass = get_schema_namespace.const_get(obj_name)
  end
  klass
end

def qbxml_class_defined?(name)
  get_schema_namespace.constants.include?(name)
end

# remove all comment lines and empty nodes
def cleanup_qbxml(qbxml)
  qbxml = qbxml.split('\n')
  qbxml.map! { |l| l.strip }
  qbxml.reject! { |l| l =~ COMMENT_MATCHER }
  qbxml.join('')
end

end
