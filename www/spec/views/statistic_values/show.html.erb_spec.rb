require 'spec_helper'

describe "statistic_values/show.html.erb" do
  before(:each) do
    @statistic_value = assign(:statistic_value, stub_model(StatisticValue,
      :name => "Name",
      :print_name => "Print Name",
      :interval => 1,
      :script => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Print Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
