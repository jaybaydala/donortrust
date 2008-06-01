
module ActiveRecord
 module Acts
   module Versioned
     module ClassMethods
       def acts_as_paranoid_versioned
         acts_as_paranoid
         acts_as_versioned      

         # protect the versioned model
         self.versioned_class.class_eval do
           def self.delete_all(conditions = nil); return; end
         end
       end
     end
   end
 end
 end