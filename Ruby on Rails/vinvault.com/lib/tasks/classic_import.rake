require 'rubygems'
require 'httparty'
require 'ostruct'

# Number of pattern records to import
PATTERN_COUNT = 7157

# Run:
# classic:clear to clear tables (check ClassicItem!)
# classic:import to load records
# classic:serials to add serial records (default)
# classic:add to add the year, make, series, and origin as items
#

class VehicleValidationException < Exception
end

namespace :classic do

  desc 'Output data in vdata format'
  task :export => :environment do
    include Colors
    # Loop through the database and create a file for each year for each manufacturer:
    # 1970_ford.vdata
    # Append to that file for each value you find
    # At the end there should be files from 1955 - 1975
    # Output the files to /source/export/
    created_files = []
    ClassicPattern.all.each do |pattern|
      short_file = "#{pattern.make.downcase.gsub(' ','_')}_#{pattern.year}"
      filename = Rails.root.join("source/export/#{short_file}.vdata")
      File.open(filename, 'a') do |file|
        created_files << short_file unless created_files.include? short_file
        puts green convert pattern
        write_line(file, convert(pattern))
        pattern.vehicles.each do |vehicle|
          puts magenta convert vehicle
          write_line(file, convert(vehicle))
          if pattern.serials.count > 0
            pattern.serials.each do |serial|
              #puts convert serial
              write_line(file, convert(serial))
            end
          end
          vehicle.sorted_items.each do |item|
            #puts convert item
            write_line(file, convert(item))
            if item.options.count > 0
              item.options.each do |option|
                #puts convert option
                write_line(file, convert(option))
              end
            end
          end
        end
      end
    end

    # Write out the master.vdata file
    File.open(Rails.root.join('source/master.vdata'), 'w') do |file|
      file << "# Master file for all sub-files\n"
      file << "# #{created_files.count} files\n"
      file << "# created: #{DateTime.now}\n"
      file << "\n"
      created_files.each do |files|
        file << "file export/#{files}\n"
      end
    end
    puts 'Data export completed'
  end

  def write_line(file, line)
    raise 'file not open' if file.nil?
    file << line + "\n"
  end

  # convert data to vdata format
  def convert(data)
    return "cls #{data.id}, #{data.value}" if data.is_a? ClassicPattern
    return "clv #{data.id}, #{data.year}, #{data.make}, #{data.series}, #{data.name}" if data.is_a? ClassicVehicle
    return "ci #{data.category.code} #{data.updated_value}" if data.is_a? ClassicItem
    return "co #{data.value}" if data.is_a? ClassicItemOption
    return "ser #{data.digits} #{data.start_value} #{data.end_value}" if data.is_a? ClassicSerial
    nil
  end

  desc 'Delete vehicle patterns'
  task :delete_vehicles => :environment do
    file = Rails.root.join('source/vehicle.vdata')
    @classic_pattern_id = nil
    @classic_vehicle_id = nil
    File.open(file, 'r').each_line do |line|
      if line =~ /^classic_pattern_first/
        part = /^classic_pattern_first (\d*)/.match(line).captures
        @classic_pattern_id = part[0].to_i
        #puts "Starting classic patterns at id #{@classic_pattern_id}"
      end

      if line =~ /^classic_vehicle_first/
        part = /^classic_vehicle_first (\d*)/.match(line).captures
        @classic_vehicle_id = part[0].to_i
        #puts "Starting classic vehicles at id #{@classic_vehicle_id}"
      end
      delete_classic_pattern(line) if line =~ /^cls/
      delete_modern_pattern(line) if line =~ /^mod/
    end
  end

  desc 'Import classic vehicle patterns'
  task :add_vehicles => :environment do
    include Colors
    # Parse DSL for adding vehicles
    file = Rails.root.join('source/vehicle.vdata')
    @classic_pattern_id = nil
    @classic_vehicle_id = nil
    @pattern = nil
    @vehicle = nil
    @item = nil

    @name = nil
    @macros = {}

    process_file(file)

  end

  # ClassicCategory.all.order('name').each {|c| puts "ClassicCategory.add_or_update(name: '#{c.name}', unit: nil ) # #{c.classic_items.first.value}"}
  desc 'Clear tables'
  task :clear => :environment do
    ClassicPattern.destroy_all
    ClassicGroup.destroy_all
    ClassicCategory.destroy_all
    ClassicPatternAssociation.destroy_all
    ClassicPatternGroup.destroy_all
    ClassicSerial.destroy_all

    puts "Cleared ClassicPattern (#{ClassicPattern.count})"
  end

  desc 'Add data'
  task :add => :environment do
    make = ClassicCategory.add_or_update({name: 'Make', classic_group: ClassicGroup.named('Basic')})
    series = ClassicCategory.add_or_update({name: 'Series', classic_group: ClassicGroup.named('Basic')})
    year = ClassicCategory.add_or_update({name: 'Model Year', classic_group: ClassicGroup.named('Basic')})
    origin = ClassicCategory.add_or_update({name: 'Origin', classic_group: ClassicGroup.named('Basic')})
    ClassicVehicle.all.each do |vehicle|
      vehicle.add_item(make, vehicle.make)
      vehicle.add_item(series, vehicle.series)
      vehicle.add_item(year, vehicle.year)
      vehicle.add_item(origin, 'United States')
      puts 'Adding data for ' + vehicle.title
    end
  end

  desc 'Set serials'
  task :serials => :environment do
    ClassicPattern.all.each do |pat|
      if pat.make  == 'Mercury'
        ClassicSerial.create(classic_pattern_id: pat.id, start_value: 500000, end_value: 999999, digits: 6)
        puts 'Adding Ford serial range'
      end
      if pat.make == 'Ford'
        ClassicSerial.create(classic_pattern_id: pat.id, start_value: 1, end_value: 499999, digits: 6)
        puts 'Adding Mercury serial range'
      end
    end
  end

  # Importing 5542 1975 Oldsmobile Toronado Custom SEries 3EY Coupe id: 22057

  desc 'Import classic vehicle patterns'
  task :import => :environment do
    # Loop through each pattern ID and get the XML
    (5241..PATTERN_COUNT).each_with_index do |id, index|
      response = HTTParty.get("http://classic.decodethis.com/c_patterns/#{id}.xml")
      pat = response.body
      hash = Hash.from_xml pat
      pattern = OpenStruct.new(OpenStruct.new(hash).pattern)
      # puts pattern.value
      # Create a new pattern or update the existing one for the data
      p = ClassicPattern.where(id: pattern.id).first_or_create
      p.update_attributes(value: pattern.value)
      # For the Pattern, create the vehicle associated with it
      vehicle = OpenStruct.new(pattern.vehicle)
      v = ClassicVehicle.where(id: vehicle.id).first_or_create
      v.update_attributes(year: vehicle.year, make: vehicle.make, series: vehicle.model, name: vehicle.trim, classic_pattern_id: pattern.id)
      # Import the items for the vehicle
      vehicle.items.each do |idx|
        puts "Importing #{id} #{v.title} id: #{v.id}"
       idx.each do |itm|
         if itm != 'item'
           itm.each do |the_item|
            item = OpenStruct.new(the_item)
            # create / update the category and group
            group = group_find(item.section)
            category = category_find(item.category, group)
            category.update_attributes(classic_group_id: group.id)  if !group.nil? && category.classic_group.nil?
             # Create a new item record, with special case for colors
             if item.section == 'Exterior Colors'
               # make these records ClassicItemOptions
               i = ClassicItem.where(classic_vehicle_id: v.id, value:'Exterior Colors').first_or_create
               option = ClassicItemOption.where(classic_item_id: i.id, value: item.value).first_or_create
               option.update_attributes(value: item.value)
               i.update_attributes(classic_category_id: category.id)
               # puts "Option #{option.value} for #{v.title} for Item: #{option.classic_item_id}"
             else
               # make a new ClassicItem and save it
               i = ClassicItem.where(classic_vehicle_id: v.id, value: item.value).first_or_create
               # find_or_create the Category and Groups

               # save the record
               i.update_attributes(classic_category_id: category.id)
             end
           end
         end
       end
      end
    end
  end

  def group_find(group)
    ClassicGroup.where(name: group).first_or_create
  end

  def category_find(category, group)
    ClassicCategory.where(name: category, classic_group_id: group.id).first_or_create
  end

  def parse(line)
    # Read each line of the file and parse it
    # puts "line: #{line}"
    if line =~ /^inc/
      parts = /^inc (\w+)/.match(line).captures
      name = parts[0]
      puts red "including: #{name}"
      #puts @macros.inspect
      @macros[name].each do |l|
        parse(l)
      end
    end
    parse_modern_pattern(line) if line =~ /^mod.*$/
    parse_modern_vehicle(line) if line =~ /^modv.*/
    parse_image(line) if line =~ /^img/
    parse_classic_pattern(line) if line =~ /^cls.*$/
    parse_classic_vehicle(line) if line =~ /^clv.*/
    parse_classic_item(line) if line =~ /^ci/
    parse_classic_item_option(line) if line =~ /^co/
    parse_classic_validate(line) if line =~ /^cval/
    parse_classic_serial(line) if line =~ /^ser/
    parse_classic_condition(line) if line =~ /^if/

    #if line =~ /^clsi/ # Pattern with id
    #  parts = /^clsi (\d*),/.match(line).captures # get the id
    #  parse_classic_pattern(line, parts[0].to_i)
    #end
    #
    #if line =~ /^clvi/ # Vehicle with id
    #  parts = /^clvi (\d*),/.match(line).captures # get the id
    #  parse_classic_vehicle(line, parts[0].to_i)
    #end

  end

  def process_file(file)
    start_macro = false
    File.open(file, 'r').each_line do |line|
      if start_macro
        if line =~ /^end/
          start_macro = false
        else
          if @macros[@name].nil?
            @macros[@name] = [line.strip]
          else
            @macros = @macros.merge({ @name => @macros[@name] << line.strip})
          end
        end

      else
        if line =~ /^def/
          start_macro = true
          parts = /^def (.*)/.match(line).captures # get name of macro
          @name = parts[0]
        end

        if line =~/^file/
          parts = /file (.*)/.match(line).captures
          filename = parts[0]
          filename = Rails.root.join("source/#{filename}.vdata")
          process_file(filename) # recursively parse the file
        end

        if line =~ /^classic_pattern_first/
          part = /^classic_pattern_first (\d*)/.match(line).captures
          @classic_pattern_id = part[0].to_i
          #puts "Starting classic patterns at id #{@classic_pattern_id}"
        end

        if line =~ /^classic_vehicle_first/
          part = /^classic_vehicle_first (\d*)/.match(line).captures
          @classic_vehicle_id = part[0].to_i
          #puts "Starting classic vehicles at id #{@classic_vehicle_id}"
        end

        if line =~ /^cls/ # starting a new pattern
          @pattern = nil
          @classic_pattern_id = @classic_pattern_id + 1
        end

        if line =~ /^clv/ # starting a new vehicle
          @vehicle = nil
          @classic_vehicle_id = @classic_vehicle_id + 1
        end

        if line =~ /^mod/ # starting a new pattern
          @pattern = nil
        end

        if line =~ /^veh/  # starting a new vehicle
          @vehicle = nil
        end
        if line =~ /^itm/ || line =~ /^ci/ # starting a new item
          @item = nil
        end


        parse(line) if line.length > 2 && !start_macro # not a def statement
      end


    end
  end

  # if conditional value (assigns to current item)
  def parse_classic_condition(line)
    raise 'item not defined' if @item.nil?
    parts = /^if (\d+:\d+) (\w+)/.match(line).captures
    condition = parts[0]
    value = parts[1]
    puts "Adding conditional if #{condition} == #{value}"
    @item.update_attributes(conditional: condition, condition_value: value)
  end

  def parse_classic_serial(line)
    raise 'missing vehicle' if @vehicle.nil?
    # format: ser digits start end prefix
    parts = []
    parts = /ser (\d) (\d+) (\d+) (\w+)/.match(line).captures unless /ser (\d) (\d+) (\d+) (\w+)/.match(line).nil?
    if parts.count == 0
      parts = /ser (\d) (\d+) (\d+)/.match(line).captures
    end
    digits = parts[0]
    start_val = parts[1]
    end_val = parts[2]
    prefix = parts.count == 4 ? parts[3] : nil
    serial = ClassicSerial.where(classic_pattern_id: @classic_pattern_id, digits: digits, start_value: start_val, end_value: end_val, prefix: prefix).first_or_create
    puts "  -- Adding serial range: #{serial.digits} digits, from: #{serial.start_value} to #{serial.end_value} prefix #{prefix}"
  end

  def parse_image(line)
    parts = /img (.*)/.match(line).captures
    @vehicle.update_attributes(image: parts[0])
    puts magenta "  -- Adding image '#{@vehicle.image}' to vehicle #{@vehicle.title}"
  end

  def parse_classic_validate(line)
    parts = /cval (.*)/.match(line).captures
    d = Decode.new(vin: parts[0])
    success = d.save
    if success
      # look to see if the vehicle is in the collection of patterns
      d.pattern.vehicles.each do |vehicle|
        if vehicle == @vehicle
          puts yellow "Validated vehicle #{vehicle.title} using VIN #{d.vin}"
          return true
        end
      end
    end
    puts red "Vehicle #{@vehicle.title} was not validated"
    raise VehicleValidationException
  end

  def parse_classic_pattern(line)
    id = nil
    value = nil
    parts = nil

    if /cls (\d+), (.*)/.match(line).nil?
      puts 'pattern does not have id'
      parts = /cls (.*)/.match(line).captures
      id = @classic_pattern_id
      value = parts[0]
    else

      parts = /cls (\d+), (.*)/.match(line).captures # cls with id
      puts 'pattern has an id of' + parts[0]
      id = parts[0].to_i
      value = parts[1]
    end

    #id = @classic_pattern_id if id.nil?
    puts green "\n+ Building pattern id #{id} for value #{value}"
    @pattern = ClassicPattern.where(id: id).first_or_create
    @pattern.update_attributes(value: value)
  end

  def parse_classic_vehicle(line)
    #raise 'Missing vehicle and id' if @classic_vehicle_id.nil? && id.nil?
    id = nil
    year = nil
    make = nil
    series = nil
    trim = nil

    if /clv (\d+), (\d{4}), (\w.+), (\w.+), (\w.+)/.match(line).nil?
      parts   = /clv (\d{4}), (\w.+), (\w.+), (\w.+)/.match(line).captures
      id      = @classic_vehicle_id if id.nil?
      year    = parts[0]
      make    = parts[1]
      series  = parts[2]
      trim    = parts[3]
    else
      parts = /clv (\d+), (\d{4}), (\w.+), (\w.+), (\w.+)/.match(line).captures
      id      = parts[0]
      year    = parts[1]
      make    = parts[2]
      series  = parts[3]
      trim    = parts[4]
    end

    @vehicle = ClassicVehicle.where(id: id).first_or_create
    @vehicle.update_attributes(classic_pattern_id: @pattern.id, id: id, year: year, make: make, series: series, name: trim)
    puts cyan " -- Built vehicle #{@vehicle.id} #{@vehicle.title} for pattern #{@pattern.id}"
    # add the year, make, and series, name to the items collection
    ClassicItem.where(classic_vehicle_id: id, classic_category_id: ClassicCategory.coded('year').id, value: year).first_or_create
    ClassicItem.where(classic_vehicle_id: id, classic_category_id: ClassicCategory.coded('make').id, value: make).first_or_create
    ClassicItem.where(classic_vehicle_id: id, classic_category_id: ClassicCategory.coded('series').id, value: series).first_or_create
    ClassicItem.where(classic_vehicle_id: id, classic_category_id: ClassicCategory.coded('trim').id, value: trim).first_or_create
  end

  def parse_classic_item(line)
    raise 'Missing vehicle in parse_classic_item' if @vehicle.nil?
    #puts "item_line: #{line}"
    parts = /ci (\w+):? (.*)/.match(line).captures
    @category = ClassicCategory.where(code: parts[0]).first
    raise "Missing category #{parts[0]} in parse_classic_item " if @category.nil?
    #if ClassicItem.where(classic_category_id: @category.id, classic_vehicle_id: @vehicle.id).count > 1
    #  puts 'multiple items of type' + @category.name
    #  @item = ClassicItem.where(classic_category_id: @category.id, classic_vehicle_id: @vehicle.id, value: parts[1]).first_or_create
    #else
    #  @item = ClassicItem.where(classic_category_id: @category.id, classic_vehicle_id: @vehicle.id).first_or_create
    #end
    #@item.update_attributes(value: parts[1])
    @item = ClassicItem.where(classic_category_id: @category.id, classic_vehicle_id: @vehicle.id, value: parts[1]).first_or_create
    puts "   -- Creating item #{@category.name} => #{parts[1]}"
  end

  def parse_classic_item_option(line)
    code = nil
    parts = []
    parts = /co (.+) code: (\w+)/.match(line).captures unless /co (.+) code: (\w+)/.match(line).nil?
    if parts.count == 2
      code = parts[1]
    else
      parts = /co (.*)/.match(line).captures unless parts.count == 2
    end
    unless parts.nil?
      ClassicItemOption.where(classic_item_id: @item.id, value: parts[0], code: code).first_or_create
      if code.nil?
        puts "     -- Adding option '#{parts[0]}' to #{@item.id}"
      else
        puts "     -- Adding option '#{parts[0]}' with code '#{code}' to #{@item.id}"
      end
    end
  end

  def parse_modern_pattern(line)
    parts = /mod (\d*), (.*)/.match(line).captures
    puts "+ Building pattern id #{parts[0]} for value #{parts[1]}"
  end

  def delete_classic_pattern(line)
    parts = []
    parts = /cls (\d*), (.*)/.match(line).captures unless /cls (\d*), (.*)/.match(line).nil?

    if parts.count == 2
      puts "Deleting pattern id #{parts[0]}"
      pat = ClassicPattern.where(id: parts[0].to_i).first
      pat.destroy unless pat.nil?
    else
      @classic_pattern_id = @classic_pattern_id + 1
      puts "Deleting pattern id #{@classic_pattern_id}"
      pat = ClassicPattern.where(id: @classic_pattern_id).first
      pat.destroy unless pat.nil?
    end

  end

  def delete_modern_pattern(line)

  end

  def parse_modern_vehicle(vehicle)

  end

  def parse_item(item)

  end

  def pull_from(line)
    data = line.split(',')
    the_next = data.first
    the_rest = data[]
  end

end
