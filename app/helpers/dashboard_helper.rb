module DashboardHelper
  
  
  #
  # Shows a spinner when any active AJAX requests are running - Joe
  #
  def show_spinner(message = 'Working')
    content_tag "span","- #{message}... " + image_tag("dt/icons/ajax-spinner.gif", :class => 'icon', :alt => ""), :id => "ajax_busy", :style => "display:none;"
  end

  def what_is_this?(id,description)
    result = image_tag('dt/icons/information.png', :border=>0, :alt => 'What is this?')
    result = result + content_tag(:span,blind_down_link("What is This?","what_is_this_#{id}",id),:class => :small_text)
    result + content_tag(:div, ( description + " (" + blind_up_link('Hide',"what_is_this_#{id}",id) + ")"), :id => id, :class => 'what_is_this_box', :style => 'display:none;')
  end

  def blind_down_link(text, id, div)
      link_to_function(text, nil, :id =>id) do |page|
                            page.visual_effect :blind_down, div, :duration => 0.5
                            page.visual_effect :highlight, div, :duration => 2
                   end
  end

  def blind_up_link(text, id, div)
      link_to_function(text, nil, :id =>id) do |page|
                            page.visual_effect :blind_up, div, :duration => 0.5
                   end
  end

  def dashboard_blind_down_link_toggle(text, id, div, style,class_name)
      link_to_function(text, nil, :id =>id + "_down", :style => style) do |page|
                            page[id + "_link"].remove_class_name('close_' + class_name)
                            page[id + "_link"].add_class_name('open_' + class_name)
                            page.visual_effect :blind_down, div, :duration => 0.5
                            page.visual_effect :highlight, div, :duration => 2
                            page.hide(id + "_down")
                            page.show(id + "_up")
                   end
  end

  def dashboard_blind_up_link_toggle(text, id, div, style,class_name)
      link_to_function(text, nil, :id =>id + "_up", :style => style) do |page|
                            page[id + "_link"].remove_class_name('open_' + class_name)
                            page[id + "_link"].add_class_name('close_' + class_name)
                            page.visual_effect :blind_up, div, :duration => 0.5
                            page.hide(id + "_up")
                            page.show(id + "_down")
                   end
  end

  def dashboard_blind_up_down_links(text1,text2, id, div, class_name)
      dashboard_blind_up_link_toggle(text2, id, div, '',class_name) + dashboard_blind_down_link_toggle(text1,id,div,'display:none;',class_name)
  end

  def dashboard_blind_down_up_links(text1,text2, id, div, class_name)
      dashboard_blind_down_link_toggle(text1,id,div,'',class_name) + dashboard_blind_up_link_toggle(text2, id, div, 'display:none;',class_name)
  end

  def delete_icon(delete_path)
    link_to(image_tag('bus_admin/icons/delete_icon.gif', :style => "vertical-align:middle;", :border => 0),delete_path, :confirm => 'Are you sure you want to delete this?', :method => :delete )
  end
  
  def dashboard_blind_list(content, target, collapsed=false, class_name='list')
    blind_container(content,target,collapsed,'li',class_name)
  end

  def dashboard_h4(content, target, collapsed=false, class_name='dash_h4')
    blind_container(content,target,collapsed,'h4',class_name)
  end

  def blind_container(content, target_div, collapsed=false, type='div', class_name='blind')
    if !collapsed
      '<' + type + ' id="' + target_div + '_link" class="open_' + class_name + "\" " +
      'onmouseover="Element.show(\'' + target_div  + '_icon\')" ' +
      'onmouseout="Element.hide(\'' + target_div  + '_icon\')" ' +
      ' ">' + content + '<span class="right_justified" id="' + target_div + '_icon" style="display:none;">' + 
      dashboard_blind_up_down_links(image_tag('dt/icons/expand_icon.png',:border=>0),image_tag('dt/icons/collapse_icon.png',:border=>0),target_div,target_div, class_name) +
      '</span></' + type + '>'
    else
      '<' + type + ' id="' + target_div + '_link" class="close_' + class_name + "\" " +
      'onmouseover="Element.show(\'' + target_div  + '_icon\')" ' +
      'onmouseout="Element.hide(\'' + target_div  + '_icon\')" ' +
      '">' + content + '<span class="right_justified" id="' + target_div + '_icon" style="display:none;">' + 
       dashboard_blind_down_up_links(image_tag('dt/icons/expand_icon.png',:border=>0),image_tag('dt/icons/collapse_icon.png',:border=>0),target_div,target_div, class_name) + 
       '</span></' + type + '>'
    end
  end
  
end