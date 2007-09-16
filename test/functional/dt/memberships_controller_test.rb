require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/memberships_controller'

# Re-raise errors caught by the controller.
class Dt::MembershipsController; def rescue_action(e) raise e end; end


context "Dt::MembershipsController handling GET /dt/memberships.js" do
	fixtures :memberships
	
	setup do
		@controller = Dt::MembershipsController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

end


#MEMBER STORIES
#=============
#As a user, I should be able to:
#  - become a member of a public group
#  - not become a member of a non-public group
#  - become a member of a non-public group to which i've been invited
#As a group member, I should be able to:
#  - withdraw membership from a group
