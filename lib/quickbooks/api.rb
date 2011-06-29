require 'ruby2ruby' # must be version 1.2.1 of ruby2ruby

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

    use_disk_cache, log_level = opts.values_at(:use_disk_cache, :log_level)
    Quickbooks::Log.init(log_level)

    @dtd_parser = Quickbooks::DtdParser.new(schema_type)
    @qbxml_parser = Quickbooks::QbxmlParser.new(schema_type)

    load_qb_classes(use_disk_cache)
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

  # disk cache ops
  #
  def self.clear_disk_cache(schema_type = nil, rebuild = false)
    check_schema_type!(schema_type)
    @@instances.delete(schema_type) 

    qbxml_cache = Dir["#{disk_cache_path(schema_type)}/*.rb"]
    template_cache = Dir["#{template_cache_path(schema_type)}/*.yml"]
    File.delete(*(qbxml_cache + template_cache))

    new(schema_type, :use_disk_cache => rebuild)
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
    class_name = class_name.to_s
    cached_classes.find { |c| underscore(c) == class_name }
  end

  def grep(pattern)
    case pattern
    when Regexp
      cached_classes.select { |c| underscore(c).match(pattern) }
    when String
      cached_classes.select { |c| underscore(c).include?(pattern) }
    end
  end

  # QBXML 2 RUBY

  def qbxml_to_obj(qbxml)
    case qbxml
    when IO
      qbxml_parser.parse_file(qbxml)
    else
      qbxml_parser.parse(qbxml)
    end
  end

  def qbxml_to_hash(qbxml, include_container = false)
    qb_obj = qbxml_to_obj(qbxml)
    unless include_container
      qb_obj.inner_attributes
    else
      qb_obj.attributes
    end
  end

  # RUBY 2 QBXML

  def hash_to_obj(data)
    key = data.keys.first
    value = data[key]

    key_path = container_class.template(true).path_to_nested_key(key.to_s)
    raise(RuntimeError, "#{key} class not found in api template") unless key_path

    wrapped_data = Hash.nest(key_path, value)
    container_class.new(wrapped_data)
  end

  def hash_to_qbxml(data)
    hash_to_obj(data).to_qbxml
  end

private 

  def load_qb_classes(use_disk_cache = false)
    if use_disk_cache
      disk_cache = Dir["#{disk_cache_path}/*.rb"]
      if disk_cache.empty?
        log.info "Warning: on disk schema cache is empty, rebuilding..."
        rebuild_schema_cache(false)
        dump_cached_classes
      else
        disk_cache.each {|file| require file }
      end
    else
      rebuild_schema_cache(false)
    end

    load_full_container_template(use_disk_cache)
    container_class
  end

  # load the recursive container class template into memory (significantly
  # speeds up wrapping of partial data hashes)
  # 
  def load_full_container_template(use_disk_cache = false)
    if use_disk_cache 
      if File.exist?(container_template_path)
        container_class.instance_variable_set( '@template', YAML.load(File.read(container_template_path)) )
      else
        log.info "Warning: on disk template is missing, rebuilding..."
        container_class.template(true)
        dump_container_template
      end
    else
      container_class.template(true)
    end
  end

  # rebuilds schema cache in memory
  #
  def rebuild_schema_cache(force = false)
    dtd_parser.parse_file(dtd_file) if (cached_classes.empty? || force)
  end

  # writes cached classes to disk
  #
  def dump_cached_classes
    cached_classes.each do |c|  
      File.open("#{disk_cache_path}/#{underscore(c)}.rb", 'w') do |f|
        f << Ruby2Ruby.translate(c)
      end
    end
  end

  # writes container template to disk
  #
  def dump_container_template
    File.open(container_template_path, 'w') do |f|
      f << container_class.template(true).to_yaml
    end
  end

end
