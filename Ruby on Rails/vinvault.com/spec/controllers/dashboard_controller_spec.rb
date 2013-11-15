require 'spec_helper'

describe DashboardController do
  include Devise::TestHelpers

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      response.status.should be(302) #unauthorized, redirected to root
    end
  end

end
