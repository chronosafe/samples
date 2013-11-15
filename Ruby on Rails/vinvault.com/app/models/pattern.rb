require 'x_parse.rb'
class Pattern < ActiveRecord::Base
  has_many :vehicles, :dependent => :destroy
  has_many :vehicle_caches, :dependent => :destroy

  def self.read_xml(xml)
    xp = XParse.new
    xp.source_xml(xml)
  end

  def self.vin_to_pattern(vin)
    return vin[0..7] + ' ' + vin[9] unless vin.nil? || vin.length < 17
    nil
  end

  def full_name
    "#{self.year} #{self.make} #{self.series} #{self.vehicles.count == 1 ? self.vehicles.first.trim : ''}"
  end

  def needs_refresh?
    # never refreshed, then refresh
    return true if refreshed_at.nil?
    return false if concrete? # concrete records don't need updating
    frequency = Settings.refresh_frequency.days
    if update_needed && ((Time.zone.now - refreshed_at).to_i / 1.day) > frequency
      true
    else
      false
    end
  end


  def needs_update?
    #return false if !update_needed?  # Already updated? leave it alone
    update = false
    if vehicles.count == 0
      update = true
    else
      vehicles.each do |v|
        if v.needs_update?
          update = true
          break
        end
      end
    end
    update
  end

  # Should an update be performed?
  def should_update?
    needs_update? && needs_refresh?
  end

  def self.for_vin(vin)
    Pattern.where(value: vin_to_pattern(vin)).first
  end

  def update_pattern(updated)
    # Use the updated pattern to update the
    changed = false
    vehicles.each do |v|
      uv = updated.vehicles.where("trim = ?", v.trim).first
      DT.p "Vehicle trim not found '#{v.trim}', skipping" if uv.nil?
      if !uv.nil? && uv.items.count != v.items.count # There's something to update
        uv.items.each do |i|
          # If the item doesn't exist in the current vehicle, add it
          unless v.items.map {|m| m.category_id}.include? i.category_id
            # add record to vehicle
            i.vehicle = v
            i.save
            changed = true
          end
        end
      end
      if changed
        mark_as_updated
      end
    end
    changed
  end

  # create a sample vin based on the pattern
  def sample_vin
    vin = value + '%07d' %  rand(9999999)
    # assign the check digit
    vin[8] = Decode.check_digit(vin)
    vin
  end

  def mark_as_refreshed
    if year.to_i < Settings.refresh_ceiling_year
      mark_as_concrete
    else
      update_attributes(refreshed_at: DateTime.now)
    end

  end

  def mark_as_updated
    update_attributes(update_needed: false, refreshed_at: DateTime.now)
  end

  def mark_as_concrete
    update_attributes(update_needed: false, refreshed_at: DateTime.now, concrete: true)
  end

  def refresh_pattern(decode)
    # vin = sample_vin # get a sample VIN
    self.vin = decode unless decode.nil?
    DT.p "Updating pattern #{value} using vin #{self.vin}"
    updated = false
    url = "http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&vin=#{vin}&reportType=2"
    response = HTTParty.get(url)
    if response.code == 200 || response.code == 302
      # puts response.body
      xp = XParse.new
      updated = xp.source_xml(response.body) # get the requested pattern from the XML
      if updated.nil? || updated.update_needed? # If it still missing data then return false
        if year.to_i < Settings.refresh_ceiling_year # Is it an old year? Then mark it as checked once
          mark_as_concrete
        else
          mark_as_refreshed
        end
      else
        updated = update_pattern(updated)
        if updated
          mark_as_updated
        else
          mark_as_refreshed
        end
      end
    end
    updated
  end

  # create a cache to reduce request time
  def to_xml(version = 1, vin = nil)
    vehicle_cache = VehicleCache.where(version: version, pattern_id: self.id).first
    if vehicle_cache.nil?
      vehicle_cache = freshen_cache(version)
    end
    DT.p "Id: #{id}"
    vehicle_cache.value
  end

  def freshen_cache(version = 1)
    vehicle_cache = ''
    VehicleCache.destroy_all(version: version, pattern_id: self.id)
    vehicle = VehicleCache.new(version: version, pattern_id: self.id)
    #puts "Vehicles = #{vehicles.count}"
    vehicles.each do |v|
      vehicle_cache += v.to_xml
    end
    vehicle.value = vehicle_cache
    vehicle.save
    vehicle
  end

end
