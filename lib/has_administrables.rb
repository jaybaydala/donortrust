## Credits to Daniel @ http://www.inter-sections.net/2007/09/25/polymorphic-has_many-through-join-model/

module HasAdministrables

    def has_administrables(args)
      has_many  ("administrated_" + args[:model].downcase.pluralize).to_sym,
                :through      => :administrations,
                :source       => :administrable,
                :source_type  => args[:model] do 
                  class_eval do
                    define_method("<<") do |administrable|
                      Administration.send(:with_scope, :create => {}) { self.concat administrable }
                    end
                  end
                end

    end

end

