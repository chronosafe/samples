class ClassicPattern < ActiveRecord::Base
  has_many :classic_vehicles, :dependent => :destroy
  has_many :classic_serials, :dependent => :destroy

  def in_range(vin)
    return true if self.classic_serials.count == 0

    self.classic_serials.each do |s|
      if vin.length > s.digits
        serial = vin[vin.length-s.digits..vin.length].to_i
        prefix = true
        unless s.prefix.nil?
          pos = vin.length-s.digits-s.prefix.length
          p = vin[pos..pos+prefix.length]
          prefix = p == s.prefix
        end
        return true if serial <= s.end_value && serial >= s.start_value && prefix
      end
    end
    false
  end

  def serials
    classic_serials
  end

  def vehicles
    classic_vehicles
  end

  def year
    self.classic_vehicles.first.year
  end

  def make
    self.classic_vehicles.first.make
  end

  def series
    self.classic_vehicles.first.series
  end
end
