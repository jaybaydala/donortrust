class ECard < ActiveRecord::Base
  after_save :make_uploads_world_readable
  file_column :small,     :web_root => "images/uploaded_pictures/", :root_path => File.join(RAILS_ROOT, "public/images/uploaded_pictures")
  file_column :medium,    :web_root => "images/uploaded_pictures/", :root_path => File.join(RAILS_ROOT, "public/images/uploaded_pictures")
  file_column :large,     :web_root => "images/uploaded_pictures/", :root_path => File.join(RAILS_ROOT, "public/images/uploaded_pictures")
  file_column :printable, :web_root => "images/uploaded_pictures/", :root_path => File.join(RAILS_ROOT, "public/images/uploaded_pictures")
  has_many :gifts
  validates_presence_of :name

  private
  def make_uploads_world_readable
    list << self.small if self.small?
    list << self.medium if self.medium?
    list << self.large if self.large?
    list << self.printable if self.printable?
    FileUtils.chmod_R(0644, list) unless list.empty?
  end
end
