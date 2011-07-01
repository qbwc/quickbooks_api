class Quickbooks::API
  include Quickbooks::Logger
  include Quickbooks::Config
  include Quickbooks::Support::Inflection

  attr_reader :dtd_parser, :qbxml_parser, :schema_type
  private_class_method :new
  @@instances = {}

  def initialize(schema_type = nil, opts = {})
    self.class.check_schema_type!(schema_type)
    @schema_type = schema_type

    @dtd_parser = Quickbooks::DtdParser.new(schema_type)
    @qbxml_parser = Quickbooks::QbxmlParser.new(schema_type)

    load_qb_classes
    @@instances[schema_type] = self
  end

  # simple singleton constructor without caching support
  #
  def self.[](schema_type)
    @@instances[schema_type] || new(schema_type)
  end

  # full singleton constructor
  #
  def self.instance(schema_type = nil, opts = {})
    @@instances[schema_type] || new(schema_type, opts)
  end

  # user friendly api decorators. Not used anywhere else.
  # 
  def container
    container_class
  end

  def qbxml_classes
    cached_classes
  end

  # api introspection
  #
  def find(class_name)
    cached_classes.find { |c| underscore(c) == class_name.to_s }
  end

  def grep(pattern)
    cached_classes.select { |c| underscore(c).match(/#{pattern}/) }
  end

  # QBXML 2 RUBY

  def qbxml_to_obj(qbxml)
    qbxml_parser.parse(qbxml)
  end

  def qbxml_to_hash(qbxml, include_container = false)
    if include_container
      qbxml_to_obj(qbxml).attributes
    else
      qbxml_to_obj(qbxml).inner_attributes
    end
  end

  # RUBY 2 QBXML

  def hash_to_obj(data)
    key, value = data.detect { |name, value| name != :xml_attributes }
    key_path = container_class.template(true).path_to_nested_key(key.to_s)
    raise(RuntimeError, "#{key} class not found in api template") unless key_path

    wrapped_data = Hash.nest(key_path, value)
    container_class.new(wrapped_data)
  end

  def hash_to_qbxml(data)
    hash_to_obj(data).to_qbxml
  end

private 

  def load_qb_classes
    rebuild_schema_cache(false)
    load_full_container_template
    container_class
  end

  # rebuilds schema cache in memory
  #
  def rebuild_schema_cache(force = false)
    dtd_parser.parse_file(dtd_file) if (cached_classes.empty? || force)
  end

  # load the recursive container class template into memory (significantly
  # speeds up wrapping of partial data hashes)
  # 
  def load_full_container_template(use_disk_cache = false)
      container_class.template(true)
  end

end
