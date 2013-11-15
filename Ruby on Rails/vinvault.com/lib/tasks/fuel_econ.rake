require 'rubygems'
require 'csv'
require 'zip'

namespace :fuel_econ do
  desc 'Import Fuel Economy Values'
  task :import => :environment do
    #response = HTTParty.get('http://www.fueleconomy.gov/feg/epadata/vehicles.csv.zip')
    zipfile = Tempfile.new("file")
    zipfile.binmode # This might not be necessary depending on the zip file
    zipfile.write(HTTParty.get('http://www.fueleconomy.gov/feg/epadata/vehicles.csv.zip').body)
    zipfile.close

# Unzip the temp zip file and process the contents
# Let garbage collection delete the temp zip file

    Zip::File.open(zipfile.path) do |file|
      file.each do |content|
        data = file.read(content)
        puts data
        # Do whatever you want with the contents
        FuelEcon.import(data)
      end
    end

    #FuelEcon.import()
  end
end