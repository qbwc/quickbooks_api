require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe Quickbooks::Config do

  #describe "configuration helpers" do

    #it "should return the supported schema types" do
      #valid_schema_types.should be_an_instance_of(Array)
      #valid_schema_types.include?(:qb).should be_true 
      #valid_schema_types.include?(:qbpos).should be_true 
    #end

    #it "should check if a particular schema type is supported" do
      #self.stub!(:schema_type => :qb)
      #valid_schema_type?.should be_true
      #self.stub!(:schema_type => :qbpos)
      #valid_schema_type?.should be_true
      #self.stub!(:schema_type => :doesntexist)
      #valid_schema_type?.should == false
    #end
    
    #it "should determine the dtd file path for any supported schema type" do
      #self.stub!(:schema_type => :qb)
      #File.exists?(dtd_file).should be_true
      #self.stub!(:schema_type => :qbpos)
      #File.exists?(dtd_file).should be_true
    #end

    #it "should determine the namespace for any supported schema type" do
      #self.stub!(:schema_type => :qb)
      #schema_namespace.should be_a_kind_of(Module)
      #self.stub!(:schema_type => :qbpos)
      #schema_namespace.should be_a_kind_of(Module)
    #end

    #it "should determine the container class for any supported schema type" do
      #self.stub!(:schema_type => :qb)
      #container_class.should == 'QBXML'
      #self.stub!(:schema_type => :qbpos)
      #schema_namespace.should == 'QBPOSXML'
    #end

  #end

  #describe "other helpers" do
    
    #before :all do
      #@qb_api = Quickbooks::API.new(:qb)
      #@qbpos_api = Quickbooks::API.new(:qbpos)
    #end

    #it "should return all the cached classes" do
      #self.stub!(:schema_type => :qb)
      #cached_classes.should be_an_instance_of(Array)
      #cached_classes.empty?.should be_false
      #cached_classes.include?(container_class).should be_true
      #self.stub!(:schema_type => :qbpos)
      #cached_classes.should be_an_instance_of(Array)
      #cached_classes.empty?.should be_false
      #cached_classes.include?(container_class).should be_true
    #end

    #it "should check if a particular class is cached" do
      #self.stub!(:schema_type => :qb)
      #is_cached_class?(Quickbooks::QBXML::QBXML).should be_true
      #self.stub!(:schema_type => :qbpos)
      #is_cached_class?(Quickbooks::QBPOSXML::QBPOSXML).should be_true
    #end

  #end

end
