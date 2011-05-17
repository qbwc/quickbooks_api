#!/usr/bin/env ruby

class Quickbooks::QbxmlParser
  include Quickbooks
  include Quickbooks::Support

def parse_file(qbxml_file)
  parse(File.read(qbxml_file))
end

def parse(qbxml)
  xml_doc = Nokogiri::XML(qbxml)
  process_xml_obj(xml_doc, nil)
end

# private

# process qbxml
#
def process_xml_obj(xml_obj, parent)
  case xml_obj
  when XML_DOCUMENT
      process_xml_obj(xml_obj.root, parent)
  when XML_NODE_SET
    if !xml_obj.empty?
      process_xml_obj(xml_obj.shift, parent) 
      process_xml_obj(xml_obj, parent) 
    end
  when XML_ELEMENT
    if is_leaf_node?(xml_obj)
      process_leaf_node(xml_obj, parent)
    else
      obj = process_non_leaf_node(xml_obj, parent)
      process_xml_obj(xml_obj.children, obj)
      obj
    end
  when XML_COMMENT
    process_comment_node(xml_obj, parent)
  end
end

# child class should overwrite these 
#
def process_leaf_node(xml_obj, parent_instance)
  attr_name, data = parse_leaf_node_data(xml_obj)
  if parent_instance
    set_attribute_value(parent_instance, attr_name, data)
  end
  parent_instance
end

def parse_leaf_node_data(xml_obj)
  attr_name = to_attribute_name(xml_obj)
  text_node = xml_obj.children.first
  [attr_name, text_node.text]
end

def process_non_leaf_node(xml_obj, parent_instance)
  instance = fetch_qbxml_class_instance(xml_obj)
  attr_name = to_attribute_name(instance.class)
  if parent_instance
    set_attribute_value(parent_instance, attr_name, instance)
  end
  instance
end

def fetch_qbxml_class_instance(xml_obj)
  instance = Qbxml.const_get(xml_obj.name).new
  instance
end

def set_attribute_value(instance, attr_name, data)
  instance.send("#{attr_name}=", data) if instance.respond_to?(attr_name)
end

def process_comment_node(xml_obj, parent_instance)
  parent_instance
end


end
