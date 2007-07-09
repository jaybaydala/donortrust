module BusAccountHelper
  def password_form_column(record, field_name)
    password_field_tag field_name, record.password
  end
  def password_confirmation_form_column(record, field_name)
    password_field_tag field_name, record.password_confirmation
  end

end