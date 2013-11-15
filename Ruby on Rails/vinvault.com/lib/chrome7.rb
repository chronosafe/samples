#dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
#require File.join(dir, 'happymapper')
require 'happymapper'
require 'net/http'
require 'uri'

#file_contents = File.read(dir + '/../spec/fixtures/chrome.xml')

module Chrome7
  class Pattern
    include HappyMapper

    # Helper Methods
    def full_name
      "#{self.model_year} #{self.make_name} #{self.model_name} #{self.trim_name}"
    end
    
    # City MPG Helper
    def mpg_city
      e = self.vehicle_specs.engines.first
      e.fuel_econ_city.high_value.to_i
    rescue
      0
    end
    
    # Highway MPG Helper
    def mpg_highway
      e = self.vehicle_specs.engines.first
      e.fuel_econ_hwy.high_value.to_i
    rescue
      0  
    end
    
    # Shortcut to the engine specs
    def engine
      self.vehicle_specs.engines.first
    end
    
    # For operators to limit data to a specific style ID
    # There's a better way of doing this...
    
    def exterior_colors_for(id)
      self.colors.exterior.select { |e| e.style_ids.include? id }
    end
    
    def generic_specs_for(id)
       self.generic_specs.select { |s| s.style_ids.include? id }
    end
    
    def consumer_info_for(id)
      self.consumer_info.select { |s| s.style_ids.include? id }
    end
    
    def options_for(id)
      self.options.select { |s| s.style_ids.include? id }
    end
    
    def standards_for(id)
      self.standards.select { |s| s.style_ids.include? id }
    end
    
    def tech_specs_for(id)
      self.tech_specs.select { |s| s.style_ids.include? id }
    end
    
    def extended_specs_for(id)
      self.extended_specs.select { |e| e.value.style_ids.include? id }
    end
    
    # VIN Pattern Helper
    def vin_pattern
      "#{self.vin[1..8]}*#{self.vin[10]}"
    end
    # main decoder method
    # VIN is required
    # locale = Locale for the query (defaults to US)
    # extended = Boolean that determines if the full set of data should be returned (defaults to true)
    def decode(vin, locale = "US", extended = true)
      # Create te http object
      uri = URI.parse("http://services.chromedata.com/Description/7a")
      http = Net::HTTP.new(uri.host, uri.port)
      #path = "/Description/7a"
	  envelope = ""
	  if extended
      # Create the SOAP Envelope
      	envelope = <<-EOF
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:description7a.services.chrome.com">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:VehicleDescriptionRequest>
         <urn:accountInfo number="280557" secret="a61a1a0992314c16" country="US" language="en" behalfOf="" />
         <urn:vin>#{vin}</urn:vin>
         <urn:switch>ShowExtendedTechnicalSpecifications</urn:switch>
         <urn:switch>ShowAvailableEquipment</urn:switch>
      </urn:VehicleDescriptionRequest>
   </soapenv:Body>
</soapenv:Envelope>
EOF
      else
      	envelope = <<-EOF
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:description7a.services.chrome.com">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:VehicleDescriptionRequest>
         <urn:accountInfo number="280557" secret="a61a1a0992314c16" country="US" language="en" behalfOf="" />
         <urn:vin>#{vin}</urn:vin>
      </urn:VehicleDescriptionRequest>
   </soapenv:Body>
</soapenv:Envelope>
EOF
      end
      

      # Set Headers
      headers = {
		        'Content-Type' => 'text/xml'

      }
      # Post the request
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = envelope
      resp = http.request(request)
      puts resp
      # Chrome::Pattern.parse(data, :single => true)
    # rescue
    #   nil
    end
    
    # Response body class
    class ResponseStatus
      include HappyMapper
      tag 'responseStatus'
      element :response_code, String, :tag => "responseCode"
      element :response_description, String, :tag => "responseDescription"
      element :enriched_data_available, Boolean, :tag => "enrichedEquipmentTransactionAvailable"
      element :enriched_data_used, Boolean, :tag => "enrichedEquipmentTransactionUsed"
    end
    
    class StockPhoto
      include HappyMapper
      tag 'stockPhotos'
      element :url, String
      element :file_name, String, :tag => 'fileName'
    end
    
    # Represents XML that has a low and a high value as child nodes
    class RangeValue
      include HappyMapper
      element :low_value, Float, :tag => "lowValue"
      element :high_value, Float, :tag => "highValue"
    end
    
    class InstallationCause
      include HappyMapper
      
      tag 'installationCause'
      namespace "http://www.w3.org/2001/XMLSchema-instance"
      element :cause, String
      element :causing_code, String, :tag => "causingCode"
    end
    
    class TechSpecification
      include HappyMapper
      tag 'technicalSpecifications'
      
      element :title_id, Integer, :tag => "titleId"
      element :title_name, String, :tag => "titleName"
      has_one :value, RangeValue
      element :value_unit, String, :tag => "valueUnit"
    end
    
    class TechValue
      include HappyMapper
      element :value, String
      element :condition, String
      has_many :style_ids, Integer, :tag => "availableStyleIds"
    end
    
    class ExtendedTechnicalSpecification
      include HappyMapper
      
      tag 'extendedTechnicalSpecifications'
      element :title_id, Integer, :tag => "titleId"
      element :title_name, String, :tag => "titleName"
      has_one :value, TechValue, :tag => "values"
      element :value_unit, String, :tag => "valueUnit"
    end
    
    class BodyType
      include HappyMapper
      tag 'bodyTypes'
      element :body_type_id, Integer, :tag => "bodyTypeId"
      element :body_type_name, String, :tag => "bodyTypeName"
      element :primary, Boolean
    end
    
    class MarketClass
      include HappyMapper
      tag 'marketClasses'
      element :market_class_id, Integer, :tag => "marketClassId"
      element :market_class_name, String, :tag => "marketClassName"
    end
    
    class Engine
      include HappyMapper
      element :engine_type_id, Integer, :tag => "engineTypeId"
      element :engine_type, String, :tag => "engineType"
      element :cylinders, Integer
      element :displacement_liter, Float, :tag => "displacementL"
      element :displacement_ci, Integer, :tag => "displacementCI"
      element :fuel_type_id, Integer, :tag => "fuelTypeId"
      element :fuel_type, String, :tag => "fuelType"
      element :hp_value, Float, :tag => "horsepowerValue"
      element :hp_rpm, Integer, :tag => "horsepowerRPM"
      element :net_torque_value, Integer, :tag => "netTorqueValue"
      element :net_torque_rpm, Integer, :tag => "netTorqueRPM"
      has_one :fuel_econ_city, RangeValue, :tag => "fuelEconomyCityValue"
      has_one :fuel_econ_hwy, RangeValue, :tag => "fuelEconomyHwyValue"
      element :fuel_econ_unit, String, :tag => "fuelEconomyUnit"
      has_one :fuel_tank_capacity, RangeValue, :tag => "fuelTankCapacity"
      element :fuel_tank_capacity_unit, String, :tag => "fuelTankCapacityUnit"
      element :installed, Boolean
      has_one :installation_cause, InstallationCause, :tag => "installationCause"
    end
       
    class VehicleSpecification
      include HappyMapper
      
      tag 'vehicleSpecification'
      has_many :body_types, BodyType
      has_many :market_classes, MarketClass
      has_one  :gvwr_range, RangeValue, :tag => "GVWRRange"
      element  :doors, Integer, :tag => "numberOfPassengerDoors"
      has_many :engines, Engine
    end
    
    class ConsumerInformationItem
      include HappyMapper
      
      tag 'items'
      element :name, String
      element :value, String
      element :condition_note, String, :tag => "conditionNote"
    end
    
    class ConsumerInformation
      include HappyMapper
      
      tag 'consumerInformation'
      element :type_name, String, :tag => "typeName"
      has_many :items, ConsumerInformationItem
      has_many :style_ids, Integer, :tag => "availableStyleIds"
    end
    
    class ExteriorColor
      include HappyMapper
      
      tag 'exteriorColors'
      element :color_code, String, :tag => "colorCode"
      element :color_name, String, :tag => "colorName"
      element :generic_color_name, String, :tag => "genericColorName"
      element :rgb_value, String, :tag => "rgbValue"
      has_many :style_ids, Integer, :tag => "availableStyleIds"
      element :installed, Boolean
    end
    
    class InteriorColor
      include HappyMapper
      
      tag 'interiorColors'
      element :color_code, String, :tag => "colorCode"
      element :color_name, String, :tag => "colorName"
      element :installed, Boolean
    end
    
    class ColorDescription
      include HappyMapper
      tag 'colorDescription'
      has_many :exterior, ExteriorColor
      has_many :interior, InteriorColor
    end
    
    class GenericEquipment
      include HappyMapper
      
      tag 'genericEquipment'
      element :category_id, Integer, :tag => "categoryId"
      element :category_utf, Integer, :tag => "categoryUtf"
      element :description, String
      element :installed, Boolean
      has_many :style_ids, Integer, :tag => "availableStyleIds"
      has_many :installation_causes, InstallationCause
    end
    
    class Standard
      include HappyMapper
      
      tag 'standards'
      element :header_id, Integer, :tag => "headerId"
      element :header_name, String, :tag => "headerName"
      element :description, String
      element :installed, Boolean
      has_many :style_ids, Integer, :tag => "availableStyleIds"
      has_many :installation_causes, InstallationCause
    end
    
    class Style
      include HappyMapper
      
      tag 'styles'
      element :division_id, Integer, :tag => "divisionId"
      element :division_name, String, :tag => "divisionName"
      element :model_id, Integer, :tag => "modelId"
      element :style_id, Integer, :tag => "styleId"
      element :style_name, String, :tag => "styleName"
      element :style_name_wo_trim, String, :tag => "styleNameWithoutTrim"
      element :drive_train, String, :tag => "consumerFriendlyDrivetrain"
      element :body_type, String, :tag => "consumerFriendlyBodyType"
      element :man_model_code, String, :tag => "manufacturerModelCode"
      element :msrp, Float, :tag => "baseMsrp"
      element :invoice, Float, :tag => "baseInvoice"
      element :destination, Float
      element :fleet_only, Boolean, :tag => "fleetOnly"
    end
    
    class FactoryOption
      include HappyMapper

      tag 'factoryOptions'
      element :chrome_option_code, String, :tag => "chromeOptionCode"
      element :man_option_code, String, :tag => "manufacturerOptionCode"
      element :header_id, Integer, :tag => "headerId"
      element :header_name, String, :tag => "headerName"
      element :descriptions, String, :tag => "descriptions"
      has_one :msrp, RangeValue, :tag => "msrp"
      has_one :invoice, RangeValue
      element :standard, Boolean
      element :installed, Boolean
      element :installation_cause, String, :tag => "installationCause"
      has_many :style_ids, Integer, :tag => "availableStyleIds"
    end
    
    tag 'VehicleInformation' # if you put class in module you need tag
    # namespace "urn:description6.kp.chrome.com"
    element  :vin, String, :tag => 'vin'
    element  :model_year, Integer, :tag => "modelYear"
    element  :make_name, String, :tag => "vinMakeName"
    element  :model_name, String, :tag => "vinModelName"
    element  :style_name, String, :tag => "vinStyleName"
    element  :trim_name, String, :tag => "vinTrimName"
    has_many :options, FactoryOption
    has_many :styles, Style
    has_many :standards, Standard
    has_many :generic_specs, GenericEquipment
    has_one  :colors, ColorDescription
    has_many :consumer_info, ConsumerInformation
    has_one  :vehicle_specs, VehicleSpecification
    has_many :tech_specs, TechSpecification
    has_many :extended_specs, ExtendedTechnicalSpecification
    has_many :stock_photos, StockPhoto
    # Not sure why these don't work as RangeValue classes...
    # Had to use :deep to get around them returning nil as RangeValues
    # TODO: Investigate why it's not working
    has_one  :msrp, Float, :tag => "baseMsrp", :deep => true
    has_one  :invoice, Float, :tag => "baseInvoice", :deep => true
    has_one  :destination, Float, :tag => "destination", :deep => true
    has_one  :response, ResponseStatus
  end
  


end
#pattern = Chrome::Pattern.new
#puts "Pattern: " + pattern.decode('1FAFP4443XF205660')

# item = PITA::Items.parse(file_contents, :single => true)
# item.items.each do |i|
#   puts i.asin, i.detail_page_url, i.manufacturer, ''
# pattern = CHROME::Pattern.parse(file_contents, :single => true)
# p pattern.inspect #.standards.first.inspect
  #puts pattern.standards.map {|m| "#{m.header_name}: #{m.description}"}
# end