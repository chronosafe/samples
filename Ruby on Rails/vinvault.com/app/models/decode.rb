class Decode < ActiveRecord::Base
  belongs_to :pattern, polymorphic: true
  has_many :decode_statuses, :dependent => :delete_all
  has_many :statuses, :through => :decode_statuses
  has_many :decoder_logs, :dependent => :delete_all
  belongs_to :user

  before_save :assign_pattern
  after_save :validate_vin

  validates_presence_of :vin, :message => 'must provide a VIN'
  #validates_length_of :vin, :is => 17, :message => 'must be 17 characters in length'

  # Statistics scopes
  scope :this_month, -> { where(created_at: Date.today.beginning_of_month..Date.today.end_of_month) }
  scope :this_week,  -> { where(created_at: Time.now.in_time_zone('Eastern Time (US & Canada)').beginning_of_week..Time.now.in_time_zone('Eastern Time (US & Canada)').end_of_week) }
  scope :this_year,  -> { where(created_at: Date.today.beginning_of_year..Date.today.end_of_year) }
  scope :this_day,   -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }

  def to_json(options={})
    Hash.from_xml(to_xml).to_json
  end

  def title
    pattern.nil? ? 'Unknown' : pattern.full_name
  end

  def to_xml(options={})

    # to_basic_xml if options.include? :format && options[:format] == :basic

    statuses = ''
    self.statuses.each {|s| statuses += s.to_xml if !s.success }
    self.statuses.each {|s| statuses += s.to_xml if s.success}

    ver = self.version.present? ? self.version : 1
    if self.pattern.nil?
      xml = "<decode api='#{ver}' type='2' id='#{self.id}' vin='#{self.vin}' year='' make='' series='' date='#{self.created_at}' status='#{self.successful}' modern='#{self.decode_type}'>#{statuses}</decode>"
    else
      xml = "<decode api='#{ver}' type='2' id='#{self.id}' vin='#{self.vin}' year='#{self.pattern.year}' make='#{self.pattern.make}' series='#{self.pattern.series}' date='#{self.created_at}' status='#{self.successful}' modern='#{self.decode_type}'>"
      xml += statuses
      xml += pattern.to_xml(1, vin)
      xml += '</decode>'
    end
    xml
  end

  def to_basic_xml
    statuses = ''
    self.statuses.each {|s| statuses += s.to_basic_xml if !s.success }

    if self.pattern.nil?
      xml = "<decode api='#{self.version}' type='1' id='#{self.id}' vin='#{self.vin}' year='' make='' series='' date='#{self.created_at}' status='#{self.successful}' modern='#{self.decode_type}'>#{statuses}</decode>"
    else
      xml = "<decode api='#{self.version}' type='1' id='#{self.id}' vin='#{self.vin}' year='#{self.pattern.year}' make='#{self.pattern.make}' series='#{self.pattern.series}' date='#{self.created_at}' status='#{self.successful}' modern='#{self.decode_type}'>"
      self.pattern.vehicles.each do |v|
        xml += v.to_basic_xml
      end
      xml += '</decode>'
    end
    xml
  end

  def decode_type
    pattern_type == 'Pattern'
  end

  def self.check_digit(vin)

    if !vin.nil? && vin.length == 17
      @pos = 0
      @total = 0
      @wf = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
      @char_pos = vin.upcase
      (0..16).each do |i|
        @pos = 0
        if i != 8
          @pos_char = @char_pos[i]
          case @pos_char
            when '0'
              @pos = 0
            when 'A','J','1'
              @pos = 1
            when 'B','K','S','2'
              @pos = 2
            when 'C','L','T','3'
              @pos = 3
            when 'D','M','U','4'
              @pos = 4
            when 'E','N','V','5'
              @pos = 5
            when 'F','W','6'
              @pos = 6
            when 'G','P','X','7'
              @pos = 7
            when 'H','Y','8'
              @pos = 8
            when 'R','Z','9'
              @pos = 9
            else
              @pos = 0
          end
          @total += @pos * @wf[i]
        end
      end
      @div = @total % 11
      @check = ''
      if @div == 10
        @check = 'X'
      else
        @check = @div.to_s
      end
      @check
    end
  end

  def self.checksum(vin)

    if !vin.nil? && vin.length == 17
      @pos = 0
      @total = 0
      @wf = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
      @char_pos = vin.upcase
      (0..16).each do |i|
        @pos = 0
        if i != 8
          @pos_char = @char_pos[i]
          case @pos_char
            when '0'
              @pos = 0
            when 'A','J','1'
              @pos = 1
            when 'B','K','S','2'
              @pos = 2
            when 'C','L','T','3'
              @pos = 3
            when 'D','M','U','4'
              @pos = 4
            when 'E','N','V','5'
              @pos = 5
            when 'F','W','6'
              @pos = 6
            when 'G','P','X','7'
              @pos = 7
            when 'H','Y','8'
              @pos = 8
            when 'R','Z','9'
              @pos = 9
            else
              @pos = 0
          end
          @total += @pos * @wf[i]
        end
      end
      @div = @total % 11
      @check = ''
      if @div == 10
        @check = 'X'
      else
        @check = @div.to_s
      end
      if vin[8] != @check
        # puts "Checksum for the VIN is invalid. It is " + self.vin[8] + ", but should be " +  @check
        return false
      end
      # puts 'checksum is valid'
      return true
    end
    if vin && vin.length < 17
      return false
    end
    false
  end

  def successful
    return false if self.statuses.count == 0
    self.statuses.each do |s|
      return false if !s.success
    end
    true
  end

  def is_modern?
    vin.length == 17
  end

  def assign_pattern
    # puts "assigning pattern for #{vin}"
    return nil if vin.nil?
    if vin.length == 17
      self.pattern = Pattern.find_by_value(Pattern.vin_to_pattern(self.vin))
      if self.pattern.nil? && Settings.updates_enabled
        if is_modern?
          self.pattern = acquire_pattern(vin)
        end
      end
    else
      self.pattern = assign_classic_pattern(vin) if self.pattern.nil?
    end
    # try to assign a classic pattern

    #if self.pattern_id == nil
    #  if vin.length == 17
    #    self.pattern = acquire_pattern(self.vin)
    #  end
    #  #
    #else
    #  if Settings.updates_enabled # && pattern.should_update?
    #    DT.p 'updating pattern'
    #    pattern.refresh_pattern(self.vin)
    #  else
    #    DT.p 'no update to pattern needed'
    #  end
    #end
    #self.pattern # return the assigned pattern
  end

  def assign_classic_pattern(vin)
    return nil if vin.nil?
    # DT.p "Assigning Classic Pattern for #{vin}"
    # The VIN is a non-modern VIN, so let's try to find a classic pattern association
    matching = false
    classic =  ClassicPatternGroup.new
    ClassicPattern.all.each do |pat|
      if vin.match("^"+pat.value+"$") and pat.in_range(vin)
        # Matching pattern, add it to the association
        classic.save
        ClassicPatternAssociation.create(classic_pattern_id: pat.id, classic_pattern_group_id: classic.id)
        matching = true
        # DT.p 'Found a match!'
      end
    end
    self.pattern = classic if matching # add the pattern if there's a match
  end

  def validate_vin

    return if statuses.count > 0 # If there are already validations then skip this step

    # Make sure VIN is stored as uppercase
    self.vin = self.vin.upcase
    # Get the validation
    stat_array = []
    stat_array = Status.validate_vin(self.vin) if is_modern?
    # Check to see if there's a matching pattern
    if self.pattern.nil?
      stat_array << Status.named('NOMATCH')
    else
      stat_array << Status.named('MATCH')
    end


    # If any of the statuses are false then the decode status is false
    stat_array << Status.named('VALID') if !stat_array.any? {|stat| !stat.success}
    # puts "--- Adding #{stat_array.count} records to statuses"
    # create the status array
    stat_array.each do |s|
      DecodeStatus.create(decode_id: self.id, status: s)
      # puts "Adding --- #{s.name}"
      #dc.decode_id = self.id
      #dc.status_id = s.id
      #dc.save
    end
    self.update_attribute(:success, successful)
  end


  def acquire_pattern(vin)
    url = "http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&vin=#{vin}&reportType=2"
    DT.p "acquiring #{vin} settings: #{Settings.updates_enabled}"
    if Settings.updates_enabled && vin.length == 17 && Decode.checksum(self.vin)
      DT.p "Requesting vin #{vin}"
      response = HTTParty.get(url)
      #puts "response: #{response.inspect}"
      if response.code == 200 || response.code == 302
        xp = XParse.new
        return xp.source_xml(response.body)
      end
    end
    nil
  end

  # Update an existing pattern
  def update_pattern
    #url = "http://www.decode.com/api.aspx?accessCode=UUID_NEEDED&vin=#{vin}&reportType=2"
    #vin = pattern.sample_vin # get a sample VIN
    #response = HTTParty.get(url)
    #if response.code == 200 || response.code == 302
    #  xp = XParse.new
    #  updated = xp.source_xml(response.body) # get the requested pattern from the XML
    #  if updated.update_needed? # If it still missing data then return false
    #    false
    #  else
    #    pattern.update_pattern(updated)
    #  end
    #end
    pattern.refresh_pattern(vin)
  end


end
