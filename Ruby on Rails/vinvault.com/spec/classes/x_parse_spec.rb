require 'spec_helper'

describe 'Pattern parser' do

  before (:all) do
    load "#{Rails.root}/db/seeds.rb"
    path = File.dirname(__FILE__) + '/../vehicle1.xml'
    @xml = File.read(path)
    @xml.should_not be_nil
  end

  it 'should parse pattern' do
    xp = XParse.new
    pattern = xp.source_xml(@xml)
    pattern.is_a?(Pattern).should be_true
    pattern.value.should eq('JTKDE167 8')
    pattern.year.should eq('2008')
    pattern.make.should eq('Scion')
    pattern.series.should eq('tC')
  end
end