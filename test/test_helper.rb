ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # helper method to reduce testing code by checking an attribute [or array
  # of attributes] against a list / array of values (all of which **should** be
  # invalid)
  def assert_invalid( instance, attribute=nil, *values )
    if values.empty? # no attribute value(s) specified.  Test instance as is.
      # build hash? of attributes and errors to use for reporting (if assert fails)
      # hpd : there *should* be a more direct / ruby way of doing this
      # assert_messages = []
      # instance.errors.each do | atr, err |
      #   assert_messages << { atr => err }
      # end
      # assert_messages << { instance.class.to_s + " instance" => instance.errors.on_base() }
      if attribute.class.to_s == "Array" #array of attributes all set to same value
        assert !instance.valid?, "#{instance.class}.#{attribute.inspect} is valid with value: #{instance.send(attribute[0]).inspect}"
      else # single attribute specified, report if it 
        assert !instance.valid?, "#{instance.class}.#{attribute.to_s} is valid with value: #{instance.send(attribute).inspect}"
      end
      assert !instance.save, "#{instance.class} Saved."
      if attribute.class.to_s == "Array"
        attribute.each do |a|
          assert instance.errors.invalid?( a ), "#{instance.class}.#{a.to_s} (element) has no attached error, all => #{instance.errors.full_messages.inspect}"
        end
      else
        assert instance.errors.invalid?( attribute ), "#{instance.class}.#{attribute.to_s} has no attached error, all => #{instance.errors.full_messages.inspect}"
      end
    else
      values.flatten.each do |value|
        obj = instance.dup
        if attribute.class.to_s == "Array"
          attribute.each do |a|
            obj.send "#{a}=", value
          end
        else
          obj.send "#{attribute}=", value
        end
        assert_invalid obj, attribute
      end
    end
  end
  
  # helper method to reduce testing code by checking an attribute [or array
  # of attributes] against a list / array of values (all of which **should** be
  # valid)
  def assert_valid( instance, attribute=nil, *values )
    if values.empty?
      unless attribute.nil?
        if attribute.class.to_s == "Array"
          assert instance.valid?, "#{instance.class}.#{attribute.inspect} is not valid with value: #{instance.send(attribute[0]).inspect} #{instance.errors.full_messages.inspect}"
        else
          assert instance.valid?, "#{instance.class}.#{attribute.to_s} is not valid with value: #{instance.send(attribute).inspect} #{instance.errors.full_messages.inspect}"
        end
      else
        # no attribute(s) specified.  Just check that the full instance is valid
        assert instance.valid?, "#{instance.class} instance invalid; #{instance.errors.full_messages.inspect}"
      end
      assert instance.errors.empty?, instance.errors.full_messages
    else
      m = instance.dup # the recursion was confusing mysql
      values.flatten.each do |value|
        obj = m.dup
        if attribute.class.to_s == "Array"
          # Set all of specified attributes to the [next] test value
          attribute.each do |a|
            obj.send "#{a}=", value
          end
        else
          # Set the single specified attribute to the [next] test value
          obj.send "#{attribute}=", value
        end
        assert_valid obj, attribute
      end
    end    
  end

  # Add more helper methods to be used by all tests here...
end

require 'test/spec/rails'

Test::Spec::Should.send    :alias_method, :have, :be
Test::Spec::ShouldNot.send :alias_method, :have, :be

Test::Spec::Should.class_eval do
  # Article.should.differ(:count).by(2) { blah } 
  def differ(method)
    @initial_value = @object.send(@method = method)
    self
  end

  def by(value)
    yield
    assert_equal @initial_value + value, @object.send(@method)
  end
end

