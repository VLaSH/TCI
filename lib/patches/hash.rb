class Hash
  # Recursive traversal methods from Ruby Facets 2.4.5
  # http://facets.rubyforge.org/
  def traverse(&b)
    inject({}) do |h,(k,v)|
      v = ( Hash === v ? v.traverse(&b) : v )
      nk, nv = b[k,v]
      h[nk] = nv
      h
    end
  end

  # This method has been updated to include HashWithIndifferentAccess support
  def traverse!(&b)
    new_hash = self.traverse(&b)
    new_hash = HashWithIndifferentAccess.new(new_hash) if self.instance_of?(HashWithIndifferentAccess)
    self.replace(new_hash)
  end
  
  def delete!(key)
    self.delete(key)
    self
  end
end