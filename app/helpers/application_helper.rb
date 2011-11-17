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
            result = result + link_to_remote(i.to_s, :update => update, :url => {:controller => controller, :action => action, :with => options, :page => i.to_s })   + " "
          else
            result = result + link_to_remote(i.to_s, :update => update, :url => {:controller => controller, :action => action, :page => i.to_s }) + " "
          end
        else
          result = result + i.to_s
        end
      end
    else
      result = "1"
    end
    return result
  end


  #
  # Shows a spinner when any active AJAX requests are running - Joe
  #
  def show_spinner
    content_tag "div", "Working... " + image_tag("/images/bus_admin/spinner.gif", :alt => ""), :id => "ajax_busy", :style => "display:none;"
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

  def insert_tabbed_pane(controllers,friendly_names)
    result = "<div><ul class='tabselector' id='tabcontrol1'>"
    i = 0
    for controller in controllers
      if i == 0
        result += "<li class='tab-selected' id='" + controller + "_tab'>"
      else
        result += "<li class='tab-unselected' id='" + controller + "_tab'>"
      end
      result += link_to_function(friendly_names[i], "tabselect($('" + controller + "_tab'),'\" + " + url_for(:action => 'update_table') + " + \"'); paneselect($('"+ controller + "_pane'))") + " </li>"
       i += 1
    end
    i = 0
    result += "</ul>"
    result += "<ul class='panes' id='panecontrol1'>"

    for controller in controllers
      if i == 0
          result += "<li id='"+ controller + "_pane' class='pane-selected'>"
      else
         result += "<li id='"+ controller + "_pane' class='pane-unselected'>"
      end
      result += render :active_scaffold => 'bus_admin/' + controller
      result += "</li>"
      i += 1
    end
    result += "</ul></div>"
  end

    def tableFactory(objects, className, excludeList, joinNameHumanName, joinName, name)
    #Build Row Header
    result = append("<div class='tableFactory'","<table cellspacing=0><tr>")
      for column in className.content_columns
        if(!exclude(column.name, excludeList))
          result = append(result,("<td class='colHeader'>"+ column.human_name + "</td>"))
        end
      end


      if joinNameHumanName != nil
        for i in 0...joinNameHumanName.length
          result = append(result,("<td class='colHeader'>"+ joinNameHumanName[i] + "</td>"))
        end
      end

      result = append(result,"<td class='colHeader'>Functions</td>")
      result = append(result,"</tr>")

    boolean = true
    for object in objects
        if(boolean)
            rowClass = 'even'
        else
            rowClass = 'odd'
        end
        boolean = !boolean

      result = append(result,("<tr class=" + rowClass + ">"))
      for column in className.content_columns
        if(!exclude(column.name, excludeList))
          result = append(result, ("<td>" + object.send(column.name).to_s + "</td>"))
        end
      end

      if joinName != nil
        for i in 0...joinName.length
          if(name[i])
            result = append(result,("<td>"+ object.send(joinName[i]).name.to_s + "</td>"))
          else
            result = append(result,("<td>"+ object.send(joinName[i]).id.to_s + "</td>"))
          end
        end
      end


#      edit = link_to 'Edit', {:action => 'edit', :id => object}, :class => 'table'
#      delete = link_to 'Remove', { :action => 'destroy', :id => object }, :confirm => 'Are you sure?', :post => true, :class => 'table'
      recover = link_to "Recover", {:action => 'recover_record', :id => object }, :confirm => 'Recover record?'

      result = append(result, "<td class='rowEnd'>")
      result = append(result, recover)
      result = append(result, "</td>")
    end

    result = append(result,"</table></div>")
    return result
  end

  def append(result, str)
     result + str;
  end

  def exclude(str, list)
    result = false
    if list != nil
      for i in 0...list.length
        if(list[i] == str)
          result = true;
          break;
        end
      end
    end

    return result;
  end

  def textilize(text)
    RedCloth.new(text).to_html
  end
end
