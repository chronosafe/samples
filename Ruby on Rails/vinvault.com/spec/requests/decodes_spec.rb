require 'spec_helper'
require 'webmock/rspec'

describe "Decodes (admin)" do
  include Warden::Test::Helpers

  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
    path = File.dirname(__FILE__) + '/../response_successful.xml'
    @success = File.read(path)
    @success.should_not be_nil
  end

  before(:each) do
    Pattern.destroy_all
    Pattern.create(value: '1D7RB1CT A')
    Pattern.create(value: '1D7RB1CT B')
    Decode.delete_all
    #User.delete_all
    #user = FactoryGirl.create(:admin)
    user = User.where(admin: true).last
    DT.p "User: #{user.inspect}"
    login_as user, scope: :user
    Settings.updates_enabled = true
  end

  after (:each) do
    Pattern.delete_all
    Settings.updates_enabled = false
  end

  describe "POST /decodes.html" do
    it "will create a new decode based on a valid VIN" do
      stub_request(:get, "http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1D7RB1CT8AS203937").
          to_return(:status => 200, :body => @success, :headers => {})
      post decodes_path, :decode => { vin: '1D7RB1CT8AS203937'}
      response.status.should be(302)
    end

    it 'will create a new decode for an unknown pattern' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)
      post decodes_path, :decode => { vin: '1FTRW08L61KF72278' }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(302)
    end

    it 'will create a new decode for an unknown pattern only once' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)

      post decodes_path, :decode => { vin: '1FTRW08L61KF72278' }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(302)
      Pattern.count.should be(3)
      # decoding a second time should not generate another pattern
      post decodes_path, :decode => { vin: '1FTRW08L61KF72278' }
      Pattern.count.should be(3)
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, :decode => { vin: '1111'}
      response.status.should be(302)
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, :decode => { vin: '111111CT8AS203937'}
      response.status.should be(302)
    end
  end

  describe "POST /decodes.json" do

    it 'will create a new decode for an unknown pattern' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)
      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278'}, :format => :json }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(201)
    end

    it 'will create a new decode for an unknown pattern only once' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)
      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278' }, :format => :json }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(201)
      Pattern.count.should be(3)
      # decoding a second time should not generate another pattern
      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278'}, :format => :json }
      Pattern.count.should be(3)
    end

    it "will create a new decode based on a valid VIN" do
      stub_request(:get, "http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1D7RB1CT8AS203937").
          to_return(:status => 200, :body => @success, :headers => {})
      post decodes_path, { :decode => { vin: '1D7RB1CT8AS203937'}, :format => :json}
      response.status.should be(201)
      response.body.include?('VALID').should be_true
    end

    it "will create a new decode based on an invalid VIN (checksum)" do
      post decodes_path, { :decode => { vin: '111111CT8AS203930'}, :format => :json}
      response.status.should be(201)
      response.body.include?('INVALIDCHECK').should be_true
    end

    it "will create a new decode based on an invalid VIN (invalid char)" do
      post decodes_path, { :decode => { vin: '111111CT8AS20393O'}, :format => :json}
      response.status.should be(201)
      response.body.include?('INVALIDCHARACTERS').should be_true
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, { :decode => { vin: '111111'}, :format => :json}
      response.status.should be(201)
      #noinspection RubyResolve
      Decode.last.statuses.should_not be_nil
      response.body.include?('NOMATCH').should be_true
    end

    it "will not create a new decode based on a missing VIN" do
      post decodes_path, { :decode => { ddd: nil}, :format => :json}
      response.status.should be(422)
    end
  end

  describe "POST /decodes.xml" do

    it 'will create a new decode for an unknown pattern' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)

      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278'}, :format => :xml }
      response.status.should be(201)
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')

    end

    it 'will create a new decode for an unknown pattern only once' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)
      Pattern.count.should be(2)
      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278' }, :format => :xml }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(201)
      Pattern.count.should be(3)
      # decoding a second time should not generate another pattern
      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278'}, :format => :xml }
      Pattern.count.should be(3)
    end

    it "will create a new decode based on a valid VIN" do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1D7RB1CT8AS203937').
          to_return(:status => 200, :body => @success, :headers => {})
      post decodes_path, { :decode => { vin: '1D7RB1CT8AS203937'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('VALID').should be_true
    end

    it "will create a new decode based on an invalid VIN (checksum)" do
      post decodes_path, { :decode => { vin: '111111CT8AS203930'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('INVALIDCHECK').should be_true
    end

    it "will create a new decode based on an invalid VIN (invalid char)" do
      post decodes_path, { :decode => { vin: '111111CT8AS20393O'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('INVALIDCHARACTERS').should be_true
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, { :decode => { vin: '111111'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('NOMATCH').should be_true
    end

    it "will not create a new decode based on a missing VIN" do
      post decodes_path, { :decode => { ddd: nil}, :format => :xml}
      response.status.should be(422)
    end
  end
end

describe "Decodes (basic)" do
  include Warden::Test::Helpers

  before(:each) do
    Pattern.destroy_all
    path = File.dirname(__FILE__) + '/../response_successful.xml'
    @success = File.read(path)
    @success.should_not be_nil

    path = File.dirname(__FILE__) + '/../response_fail.xml'
    @fail = File.read(path)
    @fail.should_not be_nil

    Pattern.create(value: '1D7RB1CT A')
    Pattern.create(value: '1D7RB1CT B')
    Decode.delete_all
    User.delete_all
    user = FactoryGirl.create(:bronze)
    login_as user, scope: :user
    Settings.updates_enabled = true
  end

  after(:each) do
    Pattern.destroy_all
    Settings.updates_enabled = false
  end


  describe "POST /decodes.html" do
    it "will create a new decode based on a valid VIN" do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1D7RB1CT8AS203937').
          to_return(:status => 200, :body => @success, :headers => {})
      post decodes_path, :decode => { vin: '1D7RB1CT8AS203937'}
      response.status.should be(302)
    end

    it 'will create a new decode based on an invalid VIN' do
      post decodes_path, :decode => { vin: '1111'}
      response.status.should be(302)
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, :decode => { vin: '111111CT8AS203937'}
      response.status.should be(302)
    end
  end

  describe 'POST /decodes.json' do

    it 'will create a decode for an unknown pattern that has no match' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=6G1YK82A23L116221').to_return(:body => @fail, :status => 200)

      post decodes_path, { :decode => { vin: '6G1YK82A23L116221'}, :format => :json }

      response.status.should be(201)
    end

    it 'will create a new decode for an unknown pattern' do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)

      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278'}, :format => :json }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(201)
    end

    it 'will create a new decode for an unknown pattern only once' do

      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1FTRW08L61KF72278').to_return(:body => @success, :status => 200)

      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278' }, :format => :json }
      Pattern.last.value.should eq('1FTRW08L 1')
      Pattern.last.make.should eq('Ford')
      Pattern.last.series.should eq('F-150')
      response.status.should be(201)
      Pattern.count.should be(3)
      # decoding a second time should not generate another pattern
      post decodes_path, { :decode => { vin: '1FTRW08L61KF72278'}, :format => :json }
      Pattern.count.should be(3)
    end

    it "will create a new decode based on a valid VIN" do
      stub_request(:get, 'http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1D7RB1CT8AS203937').
          to_return(:status => 200, :body => @success, :headers => {})
      post decodes_path, { :decode => { vin: '1D7RB1CT8AS203937'}, :format => :json}
      response.status.should be(201)
      response.body.include?('VALID').should be_true
    end

    it "will create a new decode based on an invalid VIN (checksum)" do
      post decodes_path, { :decode => { vin: '111111CT8AS203930'}, :format => :json}
      response.status.should be(201)
      response.body.include?('INVALIDCHECK').should be_true
    end

    it "will create a new decode based on an invalid VIN (invalid char)" do
      post decodes_path, { :decode => { vin: '111111CT8AS20393O'}, :format => :json}
      response.status.should be(201)
      response.body.include?('INVALIDCHARACTERS').should be_true
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, { :decode => { vin: '111111'}, :format => :json}
      response.status.should be(201)
      #noinspection RubyResolve
      Decode.last.statuses.should_not be_nil
      response.body.include?('NOMATCH').should be_true
    end

    it "will not create a new decode based on a missing VIN" do
      post decodes_path, { :decode => { ddd: nil}, :format => :json}
      response.status.should be(422)
    end
  end

  describe "POST /decodes.xml" do
    it "will create a new decode based on a valid VIN" do
      stub_request(:get, "http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&reportType=2&vin=1D7RB1CT8AS203937").
          to_return(:status => 200, :body => @success, :headers => {})
      post decodes_path, { :decode => { vin: '1D7RB1CT8AS203937'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('VALID').should be_true
    end

    it "will create a new decode based on an invalid VIN (checksum)" do
      post decodes_path, { :decode => { vin: '111111CT8AS203930'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('INVALIDCHECK').should be_true
    end

    it "will create a new decode based on an invalid VIN (invalid char)" do
      post decodes_path, { :decode => { vin: '111111CT8AS20393O'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('INVALIDCHARACTERS').should be_true
    end

    it "will create a new decode based on an invalid VIN" do
      post decodes_path, { :decode => { vin: '111111'}, :format => :xml}
      response.status.should be(201)
      response.body.include?('NOMATCH').should be_true
    end

    it "will not create a new decode based on a missing VIN" do
      post decodes_path, { :decode => { ddd: nil}, :format => :xml}
      response.status.should be(422)
    end
  end
end