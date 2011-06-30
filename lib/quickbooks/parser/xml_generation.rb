module Quickbooks::Parser::XMLGeneration
  include Quickbooks::Parser
  include Quickbooks::Parser::XMLParsing
  include Quickbooks::Support::Inflection

  def to_qbxml
    xml_doc = Nokogiri::XML(self.class.xml_template)
    root = xml_doc.root
    log.debug "to_qbxml#nodes_size: #{root.children.size}"

    # replace all children nodes of the template with populated data nodes
    xml_nodes = []
    root.children.each do |xml_template|
      next unless xml_template.is_a? XML_ELEMENT
      attr_name = underscore(xml_template)
      log.debug "to_qbxml#attr_name: #{attr_name}"

      val = self.send(attr_name)
      next unless val && val.not_blank?

      xml_nodes += build_qbxml_nodes(xml_template, val)
      log.debug "to_qbxml#val: #{val}"
    end

    log.debug "to_qbxml#xml_nodes_size: #{xml_nodes.size}"
    root.children = xml_nodes.join('')
    set_xml_attributes!(root)
    root.to_s
  end

private

  def build_qbxml_nodes(node, val)
    val = [val].flatten
    val.inject([]) do |a, v|
      a << case v
        when QbxmlBase
          v.to_qbxml
        else
          n = node.clone
          n.children = val.to_s
          n
        end
    end
  end

  def set_xml_attributes!(node)
    node.attributes.each { |name, value| node.remove_attribute(name) }
    self.xml_attributes.each { |a,v| node.set_attribute(a, v) }
  end

end
