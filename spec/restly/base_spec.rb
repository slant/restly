require "helper"
require "pry"

describe Restly::Base do

  subject { BaseSample }

  before do
    class BaseSample < Restly::Base
    end
  end

  after do
    Object.send(:remove_const, :BaseSample)
  end

  describe "Defaults" do

    it "has the default generated resource_name" do
      subject.resource_name.should == 'base_sample'
    end

    it "has an Oauth2 client" do
      subject.client.is_a?(OAuth2::Client).should == true
    end

    it "client has the default site" do
      subject.client.site.should == Restly::Configuration.site
    end

    it "client has the default client id" do
      subject.client.id.should == Restly::Configuration.client_id
    end

    it "client has the default client secret" do
      subject.client.secret.should == Restly::Configuration.client_secret
    end

  end

  describe "Inherited Default Overrides" do

    it "inherited can set a custom site" do
      subject.site = "http://example_b.com"
      subject.client.site.should_not == Restly::Configuration.client_id
    end

    it "inherited can set a custom client_id" do
      subject.client_id = "custom_id"
      subject.client.id.should_not == Restly::Configuration.client_id
    end

    it "inherited can set a custom client_secret" do
      subject.client_secret = "custom_secret"
      subject.client.secret.should_not == Restly::Configuration.client_id
    end

  end

end
