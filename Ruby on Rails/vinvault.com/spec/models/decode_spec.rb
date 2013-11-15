require 'spec_helper'


describe 'Decode class' do
  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
    FactoryGirl.create(:pattern)
    @valid_vin = { vin: '1ZVBP8KS0C5250988' }
    @invalid_check = { vin: '1ZVBP8KS0C5250981' }
    @invalid_vin = { vin: '1111' }
    @missing_vin = {}
    @invalid_char =  { vin: '1ZVBP8KS0C525O988' }
  end

  #let (:valid_vin)      { { vin: '1ZVBP8KS0C5250988' } }
  #let (:invalid_check)  { { vin: '1ZVBP8KS0C5250981' } }
  #let (:invalid_vin)    { { vin: '1111'} }
  #let (:missing_vin)    { {} }
  #let (:invalid_char)   { { vin: '1ZVBP8KS0C525O988' } }

  describe 'Valid VIN' do
    before(:each) do
      @decode = Decode.new(@valid_vin)
      @decode.save
    end

    it 'should have 4 status records' do
      @decode.statuses.should_not be_nil
      @decode.statuses.count.should eq(4)
      @decode.statuses.include?(Status.named('VALID')).should be_true
    end

    it 'should be a successful decode' do
      @decode.successful.should be_true
    end
  end

  describe 'Valid VIN but invalid checksum' do
    before(:each) do
      @decode = Decode.create(@invalid_check)
    end

    it 'should have 3 status records' do
      @decode.statuses.should_not be_nil
      @decode.statuses.count.should eq(3)
      @decode.statuses.include?(Status.named('INVALIDCHECK')).should be_true
    end

    it 'should be a successful decode' do
      @decode.successful.should be_false
    end
  end

  describe 'Invalid VIN (length)' do
    before(:each) do
      @decode = Decode.create(@invalid_vin)
    end

    it 'should have 4 status records' do
      @decode.statuses.should_not be_nil
      @decode.statuses.count.should eq(1)
      @decode.statuses.include?(Status.named('NOMATCH')).should be_true
      #@decode.statuses.include?(Status.named('INVALIDLENGTH')).should be_true
    end

    it 'should be a successful decode' do
      @decode.successful.should be_false
    end
  end

  describe 'Invalid VIN (missing)' do
    before(:each) do
      @decode = Decode.create(@missing_vin)
    end

    it 'should have no status records' do
      @decode.statuses.should_not be_nil
      @decode.statuses.count.should eq(0)
    end

    it 'should be an unsuccessful decode' do
      @decode.successful.should be_false
    end
  end

  describe 'Invalid VIN (invalid character)' do
    before(:each) do
      @decode = Decode.create(@invalid_char)
    end

    it 'should have no status records' do
      @decode.statuses.should_not be_nil
      @decode.statuses.count.should eq(3)
      @decode.statuses.include?(Status.named('INVALIDCHARACTERS')).should be_true
    end

    it 'should be an unsuccessful decode' do
      @decode.successful.should be_false
    end
  end
end