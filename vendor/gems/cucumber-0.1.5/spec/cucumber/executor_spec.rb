require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

module Cucumber
  describe Executor do
    before do # TODO: Way more setup and duplication of lib code. Use lib code!
      @io = StringIO.new
      @f = Formatters::ProgressFormatter.new(@io)
      @m = StepMother.new
      @r = Executor.new(@f, @m)
      @feature_file = File.dirname(__FILE__) + '/sell_cucumbers.feature'
      @parser = TreetopParser::FeatureParser.new
      @features = Tree::Features.new
      @features << @parser.parse_feature(@feature_file)
    end

    it "should pass when blocks are ok" do
      @m.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n.to_i }
      @m.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n -= n.to_i }
      @m.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
      @r.visit_features(@features)
      @f.dump
      @io.string.should == (<<-STDOUT).strip
\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[31m\n\e[0m\e[0m\e[1m\e[31m
\e[0m
STDOUT

    end

    it "should print filtered backtrace with feature line" do
      @m.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @m.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @m.register_step_proc(/I should owe (\d*) cucumbers/) { |n| raise "dang" }
      @r.visit_features(@features)
      @io.string.should == (<<-STDOUT).strip
\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[31mF\e[0m\e[0m\e[0m\e[1m\e[31m

1)
dang
#{__FILE__}:33:in `Then /I should owe (\\d*) cucumbers/'
#{@feature_file}:9:in `Then I should owe 7 cucumbers'
\e[0m
STDOUT
    end

#     it "should allow calling of other steps from steps" do
#       @r.register_step_proc("call me please") { @x = 1 }
#       @r.register_step_proc("I will call you") { @r.register_step_proc("call me please") }
#       @r.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
#       @feature.accept(@r)
#       @f.dump
#       @io.string.should == "...\n"
#     end
  end
end
