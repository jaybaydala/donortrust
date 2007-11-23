module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a List Column
    module ListColumns
      def get_column_value(record, column)
        # check for an override helper
        value = if column_override? column
          # we only pass the record as the argument. we previously also passed the formatted_value,
          # but mike perham pointed out that prohibited the usage of overrides to improve on the
          # performance of our default formatting. see issue #138.
          send(column_override(column), record)
        elsif column.inplace_edit
          active_scaffold_inplace_edit(record, column)
        else
          value = record.send(column.name)

          if column.association.nil? or column_empty?(value)
            formatted_value = clean_column_value(format_column(value))
          else
            case column.association.macro
              when :has_one, :belongs_to
                formatted_value = clean_column_value(format_column(value.to_label))

              when :has_many, :has_and_belongs_to_many
                firsts = value.first(4).collect { |v| v.to_label }
                firsts[3] = '…' if firsts.length == 4
                formatted_value = clean_column_value(format_column(firsts.join(', ')))
            end
          end

          formatted_value
        end

        value = '&nbsp;' if value.nil? or value.empty? # fix for IE 6
        return value
      end

      # TODO: move empty_field_text and &nbsp; logic in here?
      # TODO: move active_scaffold_inplace_edit in here?
      # TODO: we need to distinguish between the automatic links *we* create and the ones that the dev specified. some logic may not apply if the dev specified the link.
      def render_list_column(text, column, record)
        if column.link
          return "<a class='disabled'>#{text}</a>" unless record.authorized_for?(:action => column.link.crud_type)
          return text if column.singular_association? and column_empty?(text)

          url_options = params_for(:action => nil, :id => record.id, :link => text)
          if column.singular_association? and associated = record.send(column.association.name)
            url_options[:id] = associated.id
          end

          render_action_link(column.link, url_options)
        else
          text
        end
      end

      # There are two basic ways to clean a column's value: h() and sanitize(). The latter is useful
      # when the column contains *valid* html data, and you want to just disable any scripting. People
      # can always use field overrides to clean data one way or the other, but having this override
      # lets people decide which way it should happen by default.
      #
      # Why is it not a configuration option? Because it seems like a somewhat rare request. But it
      # could eventually be an option in config.list (and config.show, I guess).
      def clean_column_value(v)
        h(v)
      end

      ##
      ## Overrides
      ##

      def column_override(column)
        "#{column.name.to_s.gsub('?', '')}_column" # parse out any question marks (see issue 227)
      end

      def column_override?(column)
        respond_to?(column_override(column))
      end

      ##
      ## Formatting
      ##

      def format_column(column_value)
        if column_empty?(column_value)
          active_scaffold_config.list.empty_field_text
        elsif column_value.instance_of? Time
          format_time(column_value)
        elsif column_value.instance_of? Date
          format_date(column_value)
        else
          column_value.to_s
        end
      end

      def format_time(time)
        format = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[:default] || "%m/%d/%Y %I:%M %p"
        time.strftime(format)
      end

      def format_date(date)
        format = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:default] || "%m/%d/%Y"
        date.strftime(format)
      end

      # ==========
      # = Inline Edit =
      # ==========
      def active_scaffold_inplace_edit(record, column)
        value = record.send(column.name)
        formatted_column = clean_column_value(format_column(value))
        id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
        tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
        in_place_editor_options = {:url => {:action => "update_column", :column => column.name, :id => record.id.to_s},
         :click_to_edit_text => as_("Click to edit"),
         :cancel_text => as_("Cancel"),
         :loading_text => as_("Loading…"),
         :save_text => as_("Update"),
         :saving_text => as_("Saving…"),
         :script => true}.merge(column.options)
        content_tag(:span, formatted_column, tag_options) + in_place_editor(tag_options[:id], in_place_editor_options)
      end

    end
  end
end