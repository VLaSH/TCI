class Array
  # Recursive traversal methods from Ruby Facets 2.4.5
  # http://facets.rubyforge.org/
  def traverse(&block)
    map do |item|
      if item.is_a?(self.class)
        item.traverse(&block)
      else
        yield item
      end
    end
  end

  def traverse!(&block)
    replace(traverse(&block))
  end
end