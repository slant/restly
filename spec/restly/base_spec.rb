require "spec_helper"
require "pry"

describe Restly::Base do

  subject do
    Restly::Base.stub(:name) { 'RestlyTestObject' }
    Class.new(Restly::Base)
  end

  it "should have specs"


end
