class CfScaffoldGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, and test directories.
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))


      m.template('model.rb', File.join('app/models', "#{file_name}.rb"))

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      m.template('unit_test.rb',       File.join('test/unit',       class_path, "#{file_name}_test.rb"))
      m.template('fixtures.yml',       File.join('test/fixtures', "#{table_name}.yml"))

      unless options[:skip_migration]
        m.migration_template(
          'migration.rb', 'db/migrate', 
          :assigns => {
            :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}",
            :attributes     => attributes
          }, 
          :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
        )
      end

      m.cf_route_resources controller_file_name
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold_resource ModelName [field:type, field:type]"
    end

    def model_name 
      class_name.demodulize
    end
    
     def cf_route_resources(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          sentinel = 'ActionController::Routing::Routes.draw do |map|'

          logger.route "map.resources #{resource_list}"
          unless options[:pretend]
            gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\n  map.resources #{resource_list}, :active_scaffold => true, :path_prefix => \"/#{class_path}\"\n"
            end
          end
        end
        
   def gsub_file(relative_destination, regexp, *args, &block)
            path = destination_path(relative_destination)
            content = File.read(path).gsub(regexp, *args, &block)
            File.open (path, 'wb') { |file| file.write(content) }
   end
end
