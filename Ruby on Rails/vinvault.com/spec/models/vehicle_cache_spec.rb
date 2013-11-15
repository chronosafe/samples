require 'spec_helper'

describe VehicleCache do
  before(:all) do
    VehicleCache.destroy_all
    @cache = VehicleCache.create(pattern_id: 1, value: '<cached/>', version: 1)
  end

  it 'should create a valid cache' do
    @cache.pattern_id.should be(1)
    @cache.value.should start_with('<cached')
    @cache.version.should be(1)
  end
end
