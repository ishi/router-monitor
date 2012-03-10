require 'spec_helper'

describe ProfileController do

  describe "GET 'change'" do
    it "returns http success" do
      get 'change'
      response.should be_success
    end
  end

end
