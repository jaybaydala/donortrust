module Dt::ProfilesHelper
  def action_button(text, link, options = {})
    link_to text, link, options.merge(:class => 'action_button')
  end
end