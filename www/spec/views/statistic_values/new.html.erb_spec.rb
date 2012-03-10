require 'spec_helper'

describe "statistic_values/new.html.erb" do
  before(:each) do
    assign(:statistic_value, stub_model(StatisticValue,
      :name => "MyString",
      :print_name => "MyString",
      :interval => 1,
      :script => "MyText"
    ).as_new_record)
  end

  it "renders new statistic_value form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => statistic_values_path, :method => "post" do
      assert_select "input#statistic_value_name", :name => "statistic_value[name]"
      assert_select "input#statistic_value_print_name", :name => "statistic_value[print_name]"
      assert_select "input#statistic_value_interval", :name => "statistic_value[interval]"
      assert_select "textarea#statistic_value_script", :name => "statistic_value[script]"
    end
  end
end
