require 'nokogiri'
class XParse
  # returns a Pattern object
  def source_xml(xml)
    return nil if xml.nil?
    @doc = Nokogiri.XML(xml.encode('UTF-8'))
    return nil if @doc.nil? || (!@doc.nil? && !is_valid?) # make sure the document is valid
    # check to see if the pattern already exists
    output = existing(@doc)
    return output unless output.nil? || (!output.nil? && output.concrete) # if it does then just return the existing pattern
    #DT.p 'pattern did not already exist'
    if output.nil?
      #DT.p 'creating new pattern'
      output = pattern(@doc)
    else
      # it is an existing pattern, so update as long as the source is _not_ 1 (nada)
      if source(@doc) != 1
        # delete the existing vehicles and reparse them
        #DT.p 'recreating vehicles'
        output.vehicles.destroy_all
        parse_vehicles(@doc, output)
      else
        #DT.p 'Source 1 document, ignore update'
      end
    end
    output
  end

  def source(doc)
    source_node = doc.xpath('//Decoder/@source').first
    source_node.nil? ? 0 : source_node.content.to_i
  end

  def is_valid?
    status = @doc.xpath('//Decoder/VIN/@Status').first
    return false if status.nil?
    status.content == 'SUCCESS'
  end

  def existing(doc)
    vin_node = doc.xpath('//Decoder/VIN/@Number').first
    vin = vin_node.nil? ? nil : vin_node.content
    pattern = Pattern.where('value = ?', Pattern.vin_to_pattern(vin)).first
    if pattern.nil?
      nil
    else
      pattern
    end

  end

  def pattern(doc)
    # check to see if there is an existing pattern
    pat = Pattern.new
    vin_node = doc.xpath('//Decoder/VIN/@Number').first

    vin = vin_node.nil? ? nil : vin_node.content
    if vin != nil


      pat.source = source(doc)
      pat.vin = vin if pat.source != 1 # don't save source #1's vins, they're crap.
      pat.value = Pattern.vin_to_pattern(vin)
      pat.year, pat.make, pat.series = ymm(doc)
      return nil if !pat.save
      parse_vehicles(doc, pat)
      pat
    else
      nil
    end
  end

  def ymm(doc)
    vehicle = doc.xpath('//Decoder/VIN/Vehicle').first
    year = vehicle.xpath('@Model_Year').first.content.encode('UTF-8')
    make = vehicle.xpath('@Make').first.content.encode('UTF-8')
    series = vehicle.xpath('@Model').first.content.encode('UTF-8')
    return year, make, series
  end

  def parse_vehicles(doc, pattern)
    vehicles = doc.xpath('//Decoder/VIN/Vehicle')
    vehicles.each do |v|
      vehicle = Vehicle.new
      unless v.nil?
        vehicle.trim = v.xpath('@Trim_Level').nil? ? '-' : v.xpath('@Trim_Level').first.content.encode('UTF-8')
        vehicle.pattern = pattern
        parse_items(v.xpath('Item'), vehicle) if vehicle.save
      end
    end
  rescue
    return nil
  end

  def parse_items(items, vehicle)
    items.each do |i|
      item = Item.new
      item.category = Category.named(i.xpath('@Key').first.content)
      item.value = i.xpath('@Value').first.content.encode('UTF-8')
      item.vehicle = vehicle
      if item.value != 'No data' && !item.category.nil?  # don't save records with no data.  We'll assume that's the value
        option_list = has_options(item)
        if option_list.count > 1
          item.value = nil
          parse_item_options(option_list, item) if item.save
        else
          item.save
        end
      end
    end
  end

  def parse_item_options(options, item)
    options.each do |opt|
      io = ItemOption.new
      io.value = opt.to_s.strip.encode('UTF-8')
      io.item = item
      io.save
    end
  end

  def has_options(item)
    split_char = '|'
    split_char = ',' if item.value.include?(',') && (item.category == Category.named('Interior Trim') || item.category == Category.named('Exterior Color'))
    item.value.to_s.split(split_char)
  end
end