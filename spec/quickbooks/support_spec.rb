require File.join(File.dirname(__FILE__), "spec_helper.rb")

include Quickbooks::Support
include Quickbooks::Support::QBXML

describe Quickbooks::Support do

  describe "configuration helpers" do

    it "should return the supported schema types" do
      valid_schema_types.should be_an_instance_of(Array)
      valid_schema_types.include?(:qb).should be_true 
      valid_schema_types.include?(:qbpos).should be_true 
    end

    it "should check if a particular schema type is supported" do
      self.stub!(:schema_type => :qb)
      valid_schema_type?.should be_true
      self.stub!(:schema_type => :qbpos)
      valid_schema_type?.should be_true
      self.stub!(:schema_type => :doesntexist)
      valid_schema_type?.should == false
    end
    
    it "should determine the dtd file path for any supported schema type" do
      self.stub!(:schema_type => :qb)
      File.exists?(get_dtd_file).should be_true
      self.stub!(:schema_type => :qbpos)
      File.exists?(get_dtd_file).should be_true
    end

    it "should determine the namespace for any supported schema type" do
      self.stub!(:schema_type => :qb)
      get_schema_namespace.should be_a_kind_of(Module)
      self.stub!(:schema_type => :qbpos)
      get_schema_namespace.should be_a_kind_of(Module)
    end

    it "should determine the container class for any supported schema type" do
    end

    it "should determine the magic hash key for any supported schema type" do
      self.stub!(:schema_type => :qb)
      get_magic_hash_key.should be_an_instance_of(Symbol)
      self.stub!(:schema_type => :qbpos)
      get_magic_hash_key.should be_an_instance_of(Symbol)
    end
    
    it "should return the disk cache path" do
      self.stub!(:schema_type => :qb)
      File.exists?(get_disk_cache_path).should be_true
    end

  end

  describe "other helpers" do
    
    before :all do
      @qb_api = Quickbooks::API.new(:qb)
      @qbpos_api = Quickbooks::API.new(:qbpos)
    end

    it "should return all the cached classes" do
      self.stub!(:schema_type => :qb)
      cached_classes.should be_an_instance_of(Array)
      cached_classes.empty?.should be_false
      self.stub!(:schema_type => :qbpos)
      cached_classes.should be_an_instance_of(Array)
      cached_classes.empty?.should be_false
    end

    it "should check if a particular class is cached" do
      self.stub!(:schema_type => :qb)
      is_cached_class?(Quickbooks::QBXML::QBXML).should be_true
      self.stub!(:schema_type => :qbpos)
      is_cached_class?(Quickbooks::QBPOSXML::QBPOSXML).should be_true
    end

  end

end

describe Quickbooks::Support::QBXML do

  it "should set useful parsing constants" do
    XML_DOCUMENT.should == Nokogiri::XML::Document
    XML_NODE_SET.should == Nokogiri::XML::NodeSet
    XML_NODE.should == Nokogiri::XML::Node
    XML_ELEMENT.should == Nokogiri::XML::Element
    XML_COMMENT= Nokogiri::XML::Comment
    XML_TEXT.should == Nokogiri::XML::Text
  end

  describe "xml parsing helpers" do

    before :each do
      @klass = Nokogiri::XML::NodeSet
      stub_child = stub(:class => XML_TEXT)
      @stub_xml_node = stub(:name => "SomeNodeName", :children => [stub_child])
      @stub_xml_node.stub!(:is_a?).with(anything).and_return(false)
      @stub_xml_node.stub!(:is_a?).with(XML_ELEMENT).and_return(true)
    end

    it "should check if a node is a leaf node" do
      is_leaf_node?(@stub_xml_node).should be_true
    end
    
    it "should convert a class or xml element name to underscored" do
      to_attribute_name(@klass).should == 'node_set'
      to_attribute_name(@stub_xml_node).should == 'some_node_name'
    end

    it "should convert a full class name to a simple class name" do
      simple_class_name(@klass).should == 'NodeSet'
    end

  end

  it "should check if a class is already defined in a particular namespace" do
  end

  it "should cleanup qbxml" do
  end
  
end
