class Hash

  def path_to_nested_key(key)
    each do |k,v|
      path = [k]
      if k == key
        return path
      elsif v.is_a? Hash
        nested_path = v.path_to_nested_key(key)
        return (path + nested_path) if nested_path
      end
    end
    return nil
  end

  def self.nest(path, value)
    hash_constructor = Proc.new { |h, k| h[k] = Hash.new(&hash_constructor) }
    nested_hash = Hash.new(&hash_constructor)

    last_key = path.last
    path.inject(nested_hash) { |h, k| (k == last_key) ? h[k] = value : h[k] }
    nested_hash
  end

end

class Class
  def simple_name
    self.to_s.split("::").last
  end
end

class Object
  def not_blank?
    !self.blank?
  end
end

class File
  def self.read_from_unknown(file)
    case file
    when String
      File.read(file)
    when IO
      file.read
    end
  end
end
