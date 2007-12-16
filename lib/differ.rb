class Differ
  
  class InnerValue
      
      attr_accessor :old_value, :new_value
      
      def initialize(old_value, new_value)
        self.old_value = old_value
        self.new_value = new_value
      end
    
  end
  
  attr_accessor :object_a, :object_b
  
  def initialize(objA, objB)
    self.object_a = objA
    self.object_b = objB
    @diffs = {}
    do_diff
  end
  
  def differences
    @diffs
  end
  
  private
  def do_diff
    columns = self.object_a.class.column_names()
    columns.each do |c|
      objectAValue = self.object_a.send(c)
      objectBValue = self.object_b.send(c)
      unless objectAValue == objectBValue
        @diffs[c] = InnerValue.new(objectAValue, objectBValue)
      end
    end
  end
end