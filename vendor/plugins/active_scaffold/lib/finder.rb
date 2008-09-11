module ActiveScaffold
  module Finder
    # Takes a collection of search terms (the tokens) and creates SQL that
    # searches all specified ActiveScaffold columns. A row will match if each
    # token is found in at least one of the columns.
    def self.create_conditions_for_columns(tokens, columns, like_pattern = '%?%')
      # if there aren't any columns, then just return a nil condition
      return unless columns.length > 0

      tokens = [tokens] if tokens.is_a? String

      where_clauses = []
      columns.each do |column|
        where_clauses << "LOWER(#{column.search_sql}) LIKE ?"
      end
      phrase = "(#{where_clauses.join(' OR ')})"

      sql = ([phrase] * tokens.length).join(' AND ')
      tokens = tokens.collect{ |value| [like_pattern.sub('?', value.downcase)] * where_clauses.length }.flatten

      [sql, *tokens]
    end

    # Generates an SQL condition for the given ActiveScaffold column based on
    # that column's database type (or form_ui ... for virtual columns?).
    # TODO: this should reside on the column, not the controller
    def self.condition_for_column(column, value, like_pattern = '%?%')
      return unless column and column.search_sql and value and not value.empty?
      case column.form_ui || column.column.type
        when :boolean, :checkbox
        ["#{column.search_sql} = ?", (value.to_i == 1)]

        when :integer
        ["#{column.search_sql} = ?", value.to_i]

        else
        ["LOWER(#{column.search_sql}) LIKE ?", like_pattern.sub('?', value.downcase)]
      end
    end

    protected

    attr_writer :active_scaffold_conditions
    def active_scaffold_conditions
      @active_scaffold_conditions ||= []
    end

    attr_writer :active_scaffold_joins
    def active_scaffold_joins
      @active_scaffold_joins ||= []
    end

    def all_conditions
      merge_conditions(
        active_scaffold_conditions,                   # from the search modules
        conditions_for_collection,                    # from the dev
        conditions_from_params,                       # from the parameters (e.g. /users/list?first_name=Fred)
        conditions_from_constraints,                  # from any constraints (embedded scaffolds)
        active_scaffold_session_storage[:conditions] # embedding conditions (weaker constraints)
      )
    end

    # returns a single record (the given id) but only if it's allowed for the specified action.
    # accomplishes this by checking model.#{action}_authorized?
    # TODO: this should reside on the model, not the controller
    def find_if_allowed(id, action, klass = nil)
      klass ||= active_scaffold_config.model
      record = klass.find(id)
      raise ActiveScaffold::RecordNotAllowed unless record.authorized_for?(:action => action.to_sym)
      return record
    end

    # returns a Paginator::Page (not from ActiveRecord::Paginator) for the given parameters
    # options may include:
    # * :sorting - a Sorting DataStructure (basically an array of hashes of field => direction, e.g. [{:field1 => 'asc'}, {:field2 => 'desc'}]). please note that multi-column sorting has some limitations: if any column in a multi-field sort uses method-based sorting, it will be ignored. method sorting only works for single-column sorting.
    # * :per_page
    # * :page
    # TODO: this should reside on the model, not the controller
    def find_page(options = {})
      options.assert_valid_keys :sorting, :per_page, :page
      options[:per_page] ||= 999999999
      options[:page] ||= 1

      klass = active_scaffold_config.model

      # create a general-use options array that's compatible with Rails finders
      finder_options = { :order => build_order_clause(options[:sorting]),
                         :conditions => all_conditions,
                         :joins => joins_for_collection,
                         :include => active_scaffold_joins.empty? ? nil : active_scaffold_joins}

      # NOTE: we must use :include in the count query, because some conditions may reference other tables
      count = klass.count(finder_options.reject{|k,v| [:order].include? k})

      # we build the paginator differently for method- and sql-based sorting
      if options[:sorting] and options[:sorting].sorts_by_method?
        pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
          sorted_collection = sort_collection_by_column(klass.find(:all, finder_options), *options[:sorting].first)
          sorted_collection.slice(offset, per_page)
        end
      else
        pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
          klass.find(:all, finder_options.merge(:offset => offset, :limit => per_page))
        end
      end

      pager.page(options[:page])
    end

    # TODO: this should reside on the model, not the controller
    def merge_conditions(*conditions)
      c = conditions.find_all {|c| not c.nil? and not c.empty? }
      c.empty? ? nil : c.collect{|c| active_scaffold_config.model.send(:sanitize_sql, c)}.join(' AND ')
    end

    # accepts a DataStructure::Sorting object and builds an order-by clause
    # TODO: this should reside on the model, not the controller
    def build_order_clause(sorting)
      return nil if sorting.nil? or sorting.sorts_by_method?

      # unless the sorting is by method, create the sql string
      order = []
      sorting.each do |clause|
        sort_column, sort_direction = clause
        sql = sort_column.sort[:sql]
        next if sql.nil? or sql.empty?

        order << "#{sql} #{sort_direction}"
      end

      order = order.join(', ')
      order = nil if order.empty?

      order
    end

    # TODO: this should reside on the column, not the controller
    def sort_collection_by_column(collection, column, order)
      sorter = column.sort[:method]
      collection = collection.sort_by { |record|
        value = (sorter.is_a? Proc) ? record.instance_eval(&sorter) : record.instance_eval(sorter)
        value = '' if value.nil?
        value
      }
      collection.reverse! if order.downcase == 'desc'
      collection
    end
  end
end