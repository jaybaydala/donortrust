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
  
end
