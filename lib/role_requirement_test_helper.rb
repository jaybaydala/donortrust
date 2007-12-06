# Include this is test_helper.rb to enable test-case helper support for RoleRequirement via:
#   include RoleRequirementTestHelper
#
# RoleRequirementTestHelper uses the power of ruby to temporarily "hijack" your target action.  (don't worry, it puts things back the way it was after it runs)
# This means that the only thing that will be tested is whether or not the action can be accessed with a given circumstances.
# Any authentication you implement inside of your action will be ignored.
#
module RoleRequirementTestHelper

  # Makes sure a busaccount can access the given action
  #
  # Example:
  #
  #   assert_busaccount_can_access(:quentin, "index")
  # 
  def assert_busaccount_can_access(busaccount, actions, params = {})
    assert_busaccount_access_check(true, busaccount, actions, params)
  end
  
  # Makes sure a busaccount cant access the given action
  #
  # Example:
  #
  #   assert_busaccount_cant_access(:quentin, "destroy", :listing_id => 1)
  # 
  def assert_busaccount_cant_access(busaccount, actions, params = {})
    assert_busaccount_access_check(false, busaccount, actions, params)
  end
  
  # Check a list of busaccounts against a set of actions with parameters.
  # 
  # Parameters:
  #   busaccounts_access_list - a hash where the key is the label for a fixture, and the value is a boolean.
  #   actions - a list of actions to test against
  #   params - a hash containing the parameters to pass to each test call to the controller.
  # 
  # Example:
  #   assert_busaccount_access(
  #     {:admin => true, :quentin => false }, 
  #     [:show, :edit], 
  #     {:listing_id => 1})
  def assert_busaccounts_access(busaccounts_access_list, actions, params = {})
    busaccounts_access_list.each_pair {|busaccount, access| 
      assert_busaccount_access_check(access, busaccount, actions, params)
    }
  end
  
  alias :assert_busaccount_cannot_access :assert_busaccount_cant_access

private
  def assert_busaccount_access_check(should_access, busaccount, actions, params = {})
    params = HashWithIndifferentAccess.new(params)
    
    (Array===actions ? actions : [actions]).each { |action|
      # reset the controller, request, and response
      @controller = @controller.class.new
      @request = @request.class.new
      @response = @response.class.new
      login_as busaccount
      if should_access
        assert request_passes_role_security_system?(action, params), "request to #{@controller.class}##{action} with busaccount #{busaccount} and params #{params.inspect} should have passed "
      else
        assert ! request_passes_role_security_system?(action, params), "request to #{@controller.class}##{action} with busaccount #{busaccount} and params #{params.inspect} should have been denied"
      end
    }
  end
  
  # This is the core of the test system.
  def request_passes_role_security_system?(action, params)
    did_it_pass = false
    
    action = action.to_s
    hijacker = Hijacker.new(@controller.class)
    
    begin
      assert hijacker.hijack_instance_method(action, "@last_action_passed='#{action}'; render :text => 'passed'"), "unable to hijack method '#{action}'.  Are you sure the action exists?"
      get action, params
    rescue
      assert false, "error occurred while trying to access action '#{action}' -- #{$!.to_s}.\nCheck to make sure that you are passing needed parameters.\n#{$!.backtrace * "\n"} "
    ensure
      hijacker.restore
    end
    
    did_it_pass = (action.to_s == assigns(:last_action_passed)) # make sure it actually made it through
  end
end
