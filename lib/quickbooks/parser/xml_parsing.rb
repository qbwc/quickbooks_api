require 'nokogiri'

module Quickbooks::Parser::XMLParsing

  XML_DOCUMENT = Nokogiri::XML::Document
  XML_NODE_SET = Nokogiri::XML::NodeSet
  XML_NODE = Nokogiri::XML::Node
  XML_ELEMENT = Nokogiri::XML::Element
  XML_COMMENT= Nokogiri::XML::Comment
  XML_TEXT = Nokogiri::XML::Text

  COMMENT_START = "<!--"
  COMMENT_END = "-->"
  COMMENT_MATCHER = /\A#{COMMENT_START}.*#{COMMENT_END}\z/

  # remove all comment lines and empty nodes
  def cleanup_qbxml(qbxml)
    qbxml = qbxml.split('\n')
    qbxml.map! { |l| l.strip }
    qbxml.reject! { |l| l =~ COMMENT_MATCHER }
    qbxml.join('')
  end

  def leaf_node?(xml_obj)
    xml_obj.children.size == 0 || xml_obj.children.size == 1
  end

  def parse_leaf_node_data(xml_obj)
    attr_name = underscore(xml_obj)
    text_node = xml_obj.children.first
    [attr_name, text_node && text_node.text]
  end

  def parse_xml_attributes(xml_obj)
    attrs = xml_obj.attributes
    attrs.inject({}) { |h, (n,v)| h[n] = v.value; h }
  end

end
