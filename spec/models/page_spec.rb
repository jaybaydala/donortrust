require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  let(:page) { Page.new(:title => "Foo") }
  describe "permalink" do
    it "should auto-set the permalink" do
      page.should_receive(:permalink=).with(page.title.parameterize).once
      page.save
    end
    it "should not auto-set the permalink it it's already set" do
      page.permalink = 'bar'
      page.title.should_not_receive(:parameterize)
      page.save
    end
  end
end