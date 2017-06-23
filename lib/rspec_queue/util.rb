module RSpecQueue
  class Util
    def self.flat_hashify(obj, hash = {})
      if obj.is_a? Array
        obj.each { |obj|
          hash.merge flat_hashify(obj, hash)
        }
        hash
      elsif obj.children.any?
        obj.children.each { |obj|
          hash.merge flat_hashify(obj, hash)
        }
        hash
      else
        hash[obj.id] = obj
        hash
      end
    end
  end
end
