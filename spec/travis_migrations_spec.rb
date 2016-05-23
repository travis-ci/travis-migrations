require 'spec_helper'

describe "Travis Migrations Custom Rake Tasks" do
  it "doesn't break" do
    expect(system('rake db:migrate')).to be_truthy
  end
end
