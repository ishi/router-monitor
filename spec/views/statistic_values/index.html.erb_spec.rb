require 'spec_helper'

describe "statistic_values/index.html.erb" do
  before(:each) do
    assign(:statistic_values, [
      stub_model(StatisticValue,
        :name => "Name",
        :print_name => "Print Name",
        :interval => 1,
        :script => "MyText"
      ),
      stub_model(StatisticValue,
        :name => "Name",
        :print_name => "Print Name",
        :interval => 1,
        :script => "MyText"
      )
    ])
  end

  it "renders a list of statistic_values" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Print Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
