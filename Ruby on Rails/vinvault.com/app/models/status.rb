class Status < ActiveRecord::Base
  has_many :decode_statuses

  @@stat = nil

  def self.named(name)
    @@stat ||= Status.all.load.to_a
    @@stat.select {|s| s.name == name }.first
  end

  def self.validate_vin(vin)
    result = []

    # VIN is missing
    if vin.nil?
      result << self.named('MISSINGVIN')
    end

    # VIN is not 17 characters
    if vin.length != 17
      result << self.named('INVALIDLENGTH')
    end

    # VIN Checksum is invalid
    if Decode.checksum(vin)
      result << self.named('VALIDCHECK')
    else
      result << self.named('INVALIDCHECK')
    end

    # Make sure the VIN has only valid characters
    if vin =~/^[A-Z\d][^QIO]+$/
      result << self.named('VALIDCHARACTERS')
    else
      result << self.named('INVALIDCHARACTERS')
    end


    result

  end

  def to_xml
    "<status name='#{self.name}' message='#{self.message}'></status>"
  end

  def to_basic_xml
    "<status name='#{self.name}'/>"
  end

  def self.add_or_update(hash)
    status = Status.where(name: hash[:name]).first_or_create
    status.update_attributes(hash)
    puts "Creating/Updating status: #{status.name}" if Settings.verbose
  end


end
