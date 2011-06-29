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

private

  def build_qbxml_node(node, val)
    case val
    when QbxmlBase
      val.to_qbxml
    else
      node.children = val.to_s
      node
    end
  end

  def build_qbxml_nodes(node, val)
    val.inject([]) do |a, v|
      n = \
        case v
        when QbxmlBase
          v.to_qbxml
        else
          clone_qbxml_node(node,v)
        end
      a << n
    end
  end

  def clone_qbxml_node(node, val)
    n = node.clone
    n.children = val.to_s
    n
  end

end
