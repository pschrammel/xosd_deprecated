module FFI
  def self.find_type(name, type_map = nil)
    type_map = TypeDefs if type_map.nil?
    code = type_map[name]
    code = TypeDefs[name] unless code  #<------added this line
    code = name if !code && name.kind_of?(FFI::Type)
    raise TypeError, "Unable to resolve type '#{name}'" unless code
    return code
  end 
end
