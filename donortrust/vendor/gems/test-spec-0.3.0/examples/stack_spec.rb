# Copied with minor code changes (should_xxx -> should.xxx) from RSpec.

require File.dirname(__FILE__) + '/../lib/test/spec'
require File.dirname(__FILE__) + "/stack"

context "A stack (in general)" do
  setup do
    @stack = Stack.new
    ["a","b","c"].each { |x| @stack.push x }
  end
  
  specify "should add to the top when sent 'push'" do
    @stack.push "d"
    @stack.peek.should.equal "d"
  end
  
  specify "should return the top item when sent 'peek'" do
    @stack.peek.should.equal "c"
  end
  
  specify "should NOT remove the top item when sent 'peek'" do
    @stack.peek.should.equal "c"
    @stack.peek.should.equal "c"
  end
  
  specify "should return the top item when sent 'pop'" do
    @stack.pop.should.equal "c"
  end
  
  specify "should remove the top item when sent 'pop'" do
    @stack.pop.should.equal "c"
    @stack.pop.should.equal "b"
  end
end

context "An empty stack" do
  setup do
    @stack = Stack.new
  end
  
  specify "should be empty" do
    @stack.should.be.empty
  end
  
  specify "should no longer be empty after 'push'" do
    @stack.push "anything"
    @stack.should.not.be.empty
  end
  
  specify "should complain when sent 'peek'" do
    lambda { @stack.peek }.should.raise StackUnderflowError
  end
  
  specify "should complain when sent 'pop'" do
    lambda { @stack.pop }.should.raise StackUnderflowError
  end
end

context "An almost empty stack (with one item)" do
  setup do
    @stack = Stack.new
    @stack.push 3
  end
  
  specify "should not be empty" do
    @stack.should.not.be.empty
  end
  
  specify "should remain not empty after 'peek'" do
    @stack.peek
    @stack.should.not.be.empty
  end
  
  specify "should become empty after 'pop'" do
    @stack.pop
    @stack.should.be.empty
  end
end

context "An almost full stack (with one item less than capacity)" do
  setup do
    @stack = Stack.new
    (1..9).each { |i| @stack.push i }
  end
  
  specify "should not be full" do
    @stack.should.not.be.full
  end
  
  specify "should become full when sent 'push'" do
    @stack.push Object.new
    @stack.should.be.full
  end
end

context "A full stack" do
  setup do
    @stack = Stack.new
    (1..10).each { |i| @stack.push i }
  end
  
  specify "should be full" do
    @stack.should.be.full
  end
  
  specify "should remain full after 'peek'" do
    @stack.peek
    @stack.should.be.full
  end
  
  specify "should no longer be full after 'pop'" do
    @stack.pop
    @stack.should.not.be.full
  end

  specify "should complain on 'push'" do
    lambda { @stack.push Object.new }.should.raise StackOverflowError
  end
end
