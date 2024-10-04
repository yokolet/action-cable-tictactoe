require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  it "renders id=app attribute" do
    render
    expect(rendered).to include('id="app"')
  end
end
