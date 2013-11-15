require 'spec_helper'

describe 'Reading XML Post' do
  include Devise::TestHelpers

  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
    path = File.dirname(__FILE__) + '/../vehicle1.xml'
    @xml = File.read(path)
    @xml.should_not be_nil
    @controller = PatternsController.new
    Pattern.delete_all
  end

  after(:each) do
    Pattern.delete_all
  end

  it 'should read vehicle #1' do
    post :bulk, @xml, :content_type => 'application/xml'
    if Settings.bulk_enabled
      Pattern.count.should eq(1)
      Pattern.first.vehicles.count.should eq(2)
      expect(response).to be_success
      expect(response.status).to eq(200)
    else
      Pattern.count.should eq(0)
      expect(response).to_not be_success
      expect(response.status).to eq(422)
    end
  end

  it 'should not read invalid vehicle' do
    @invalid = "<decode></decode>"
    post :bulk, @invalid, :content_type => 'application/xml'
    Pattern.count.should eq(0)
    #expect(response).to be_success
    response.success?.should be_false
    expect(response.status).to eq(422)
  end
end