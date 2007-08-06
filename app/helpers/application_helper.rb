module ApplicationHelper
  #include AuthenticatedSystem
  def show_message_and_reset(message, type)   
    message_div = 'message_div'
    @color = "black"
    case type
      when "error" 
        @color = "red"
      when warning
        @color = "yellow"
      when info
        @color = "green"
    end
         render :update do |page|
        page.replace_html message_div, '<p style="color: ' + @color + ';">' + message + '</p>' 
        page.delay(5) do          
          page.replace_html message_div, ''  
        end
    end
  end
  
  #
  # Generates a list of page links for updateing an div using AJAX
  #
  def pageinated_links_for_ajax(pageArray, update, controller, action, options)
    result = ""
    if pageArray.length > 1
      for i in 1...pageArray.length+1
        if i != pageArray.current_page.to_i
          if options != nil
            result = result + link_to_remote(i.to_s, :update => update, :url => {:controller => controller, :action => action, :with => options, :page => i.to_s })             
          else
            result = result + link_to_remote(i.to_s, :update => update, :url => {:controller => controller, :action => action, :page => i.to_s })             
          end
        else
          result = result + i.to_s
        end
      end
    end
    return result
  end
  
  
  #
  # Shows a spinner when any active AJAX requests are running - Joe
  #
  def show_spinner
    content_tag "div", "Working... " + image_tag("/images/misc/spinner.gif"), :id => "ajax_busy", :style => "display:none;"
  end
  
  #
  # Creates a simple show hide div box for displaying a small section of text - Joe
  #
  def show_hide_text_area(text, textLength, uniqueKeyWord, containerClassName)
    result = ""
    shortText = text[0,textLength]
    result = result + "<div class=\"#{containerClassName}\">"
       result = result + "<div id=\"#{uniqueKeyWord}_short\">"
       result = result + "#{shortText}... (" + 
                link_to_function("more", nil, :id =>"#{uniqueKeyWord}_more_link") do |page|
                        page.visual_effect :slide_up, "#{uniqueKeyWord}_short", :duration => 0.5
                        page.delay(0.5) do
                            page.visual_effect :slide_down, "#{uniqueKeyWord}_long", :duration => 0.5
                        end
               end + ")</div>"
       result = result + "<div id=\"#{uniqueKeyWord}_long\" style=\"display:none\">#{text} ("
       result = result + 
                link_to_function("less", nil, :id =>"#{uniqueKeyWord}_less_link") do |page|
                        page.visual_effect :slide_up, "#{uniqueKeyWord}_long", :duration => 0.5
                        page.delay(0.5) do
                            page.visual_effect :slide_down, "#{uniqueKeyWord}_short", :duration => 0.5
                        end
               end + ") </div></div>"
    
    return result
  end
  
  def slide_down_link(text, id, div)
      link_to_function(text, nil, :id =>id) do |page|
                            page.visual_effect :slide_down, div, :duration => 0.5
                   end
  end
  
    def slide_up_link(text, id, div)
      link_to_function(text, nil, :id =>id) do |page|
                            page.visual_effect :slide_up, div, :duration => 0.5
                   end
  end
  
end