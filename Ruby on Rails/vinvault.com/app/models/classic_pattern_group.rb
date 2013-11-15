class ClassicPatternGroup < ActiveRecord::Base
  has_many :classic_pattern_associations
  has_many :classic_patterns, :through => :classic_pattern_associations

  def default
    classic_patterns.first
  end

  def year
    default.year
  end

  def make
    default.make
  end

  def series
    default.series
  end

  def full_name
    "#{year} #{make} #{series}"
  end

  def vehicles
    array = []
    classic_patterns.each do |pat|
      pat.classic_vehicles.each do |vehicle|
        array << vehicle
      end
    end
    array
  end

  def to_xml(decode_type, vin = nil)
    xml = ''
    classic_patterns.each do |pat|
      DT.p "Adding vehicle to xml"
      pat.classic_vehicles.each do |vehicle|
        xml += vehicle.to_xml(vin)
      end
    end
    xml
  end

end
