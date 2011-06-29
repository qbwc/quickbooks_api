class Hash

  def path_to_nested_key(key)
    self.each do |k,v|
      path = [k]
      if k == key
        return path
      elsif v.is_a? Hash
        nested_val = path_to_nested_key(v, key)
        nested_val ? (return path + nested_val) : nil
      end
    end
    return nil
  end

  def self.nest(path, value)
    hash_constructor = lambda { |h, k| h[k] = Hash.new(&hash_constructor) }

    wrapped_data = Hash.new(&hash_constructor)
    path.inject(wrapped_data) { |h, k| k == path.last ? h[k] = value: h[k] }
    wrapped_data
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
