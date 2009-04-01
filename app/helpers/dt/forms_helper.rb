module Dt::FormsHelper

  def label_for_required_field(model_name, field_name, label_text)
    label(model_name, field_name, render(:partial => 'dt/shared/form_required') + label_text)
  end

end
