# Create category groups

Group.add_or_update(name: 'Basic', code: 'BASIC')
Group.add_or_update(name: 'Dimensions', code: 'DIM')
Group.add_or_update(name: 'Drivetrain', code: 'DRIVE')
Group.add_or_update(name: 'Braking', code: 'BRAKE')
Group.add_or_update(name: 'Suspension', code: 'SUSPENSION')
Group.add_or_update(name: 'Colors', code: 'COLOR')
Group.add_or_update(name: 'Seating', code: 'SEATING')
Group.add_or_update(name: 'Weight', code: 'WEIGHT')
Group.add_or_update(name: 'Safety', code: 'SAFETY')
Group.add_or_update(name: 'Warranty', code: 'WARRANTY')
Group.add_or_update(name: 'Feature', code: 'FEATURE')
Group.add_or_update(name: 'Security', code: 'SECURITY')
Group.add_or_update(name: 'Comfort', code: 'COMFORT')
Group.add_or_update(name: 'Interior', code: 'INTERIOR')
Group.add_or_update(name: 'Entertainment', code: 'ENTERTAIN')
Group.add_or_update(name: 'Wheels and Tires', code: 'WHEELS')
Group.add_or_update(name: 'Pricing', code: 'PRICING')
Group.add_or_update(name: 'Engine', code: 'ENGINE')

# Create category types
Category.add_or_update({ name: 'Invalid'})
Category.add_or_update({ name: 'Unknown'})
Category.add_or_update({ name: 'Model Year', group: Group.named('Basic')})
Category.add_or_update({ name: 'Make', group: Group.named('Basic')})
Category.add_or_update({ name: 'Model', group: Group.named('Basic')})
Category.add_or_update({ name: 'Trim Level', group: Group.named('Basic')})
Category.add_or_update({ name: 'Manufactured in', group: Group.named('Basic'), label: 'Origin'})
Category.add_or_update({ name: 'Body Style', group: Group.named('Basic'), label: 'Body Type'})
Category.add_or_update({ name: 'Engine Type', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'Transmission-short', group: Group.named('Drivetrain'), label: 'Transmission (short)'})
Category.add_or_update({ name: 'Transmission-long', group: Group.named('Drivetrain'), label: 'Transmission (long)'})
Category.add_or_update({ name: 'Driveline', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'Fuel Type', group: Group.named('Fuel')})
Category.add_or_update({ name: 'Doors', group: Group.named('Seating')})
Category.add_or_update({ name: 'Tank', unit: 'gallon', group: Group.named('Fuel'), label: 'Fuel Tank'})
Category.add_or_update({ name: 'Fuel Economy-city', unit: 'miles/gallon', group: Group.named('Fuel'), label: 'MPG (city)'})
Category.add_or_update({ name: 'Fuel Economy-highway', unit: 'miles/gallon', group: Group.named('Fuel'), label: 'MPG (hwy)'})
Category.add_or_update({ name: 'Anti-Brake System', group: Group.named('Braking')})
Category.add_or_update({ name: 'Steering Type', group: Group.named('Suspension')})
Category.add_or_update({ name: 'Front Brake Type' , group: Group.named('Braking')})
Category.add_or_update({ name: 'Rear Brake Type', group: Group.named('Braking')})
Category.add_or_update({ name: 'Turning Diameter', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Front Suspension', group: Group.named('Suspension')})
Category.add_or_update({ name: 'Rear Suspension', group: Group.named('Suspension')})
Category.add_or_update({ name: 'Front Spring Type', group: Group.named('Suspension')})
Category.add_or_update({ name: 'Rear Spring Type', group: Group.named('Suspension')})
Category.add_or_update({ name: 'Tires', group: Group.named('Wheels and Tires')})
Category.add_or_update({ name: 'Front Headroom', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Rear Headroom', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Front Legroom', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Rear Legroom', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Front Shoulder Room', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Rear Shoulder Room', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Front Hip Room', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Rear Hip Room', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Interior Trim', group: Group.named('Colors')})
Category.add_or_update({ name: 'Exterior Color', group: Group.named('Colors')})
Category.add_or_update({ name: 'Curb Weight-automatic', unit: 'lbs', group: Group.named('Weight'), label: 'Curb Weight'})
Category.add_or_update({ name: 'Curb Weight-manual', unit: 'lbs', group: Group.named('Weight'), label: 'Curb Weight (manual)', enabled: false})
Category.add_or_update({ name: 'Overall Length', unit: 'in.', group: Group.named('Dimensions'), label: 'Length'})
Category.add_or_update({ name: 'Overall Width', unit: 'in.', group: Group.named('Dimensions'), label: 'Width'})
Category.add_or_update({ name: 'Overall Height', unit: 'in.', group: Group.named('Dimensions'), label: 'Height'})
Category.add_or_update({ name: 'Wheelbase', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Ground Clearance', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Track Front', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Track Rear', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Cargo Length', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Width at Wheelwell', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Width at Wall', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Depth', unit: 'in.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Standard Seating', group: Group.named('Seating')})
Category.add_or_update({ name: 'Optional Seating', group: Group.named('Seating')})
Category.add_or_update({ name: 'Passenger Volume', unit: 'cu.ft.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Cargo Volume', unit: 'cu.ft.', group: Group.named('Dimensions')})
Category.add_or_update({ name: 'Standard Towing', unit: 'lbs', group: Group.named('Weight')})
Category.add_or_update({ name: 'Maximum Towing', unit: 'lbs', group: Group.named('Weight')})
Category.add_or_update({ name: 'Standard Payload', unit: 'lbs', group: Group.named('Weight')})
Category.add_or_update({ name: 'Maximum Payload', unit: 'lbs', group: Group.named('Weight')})
Category.add_or_update({ name: 'Standard GVWR', unit: 'lbs', group: Group.named('Weight')})
Category.add_or_update({ name: 'Maximum GVWR', unit: 'lbs', group: Group.named('Weight')})
Category.add_or_update({ name: 'Basic-duration', unit: 'month', group: Group.named('Warranty'), label: 'Basic (duration)'})
Category.add_or_update({ name: 'Basic-distance', unit: 'mile', group: Group.named('Warranty'), label: 'Basic (distance)'})
Category.add_or_update({ name: 'Powertrain-duration', unit: 'month', group: Group.named('Warranty'), label: 'Powertrain (duration)'})
Category.add_or_update({ name: 'Powertrain-distance', unit: 'mile', group: Group.named('Warranty'), label: 'Powertrain (distance)'})
Category.add_or_update({ name: 'Rust-duration', unit: 'month', group: Group.named('Warranty'), enabled: false})
Category.add_or_update({ name: 'Rust-distance', unit: 'mile', group: Group.named('Warranty'), enabled: false})
Category.add_or_update({ name: 'MSRP', unit: 'USD', group: Group.named('Pricing')})
Category.add_or_update({ name: 'Dealer Invoice', unit: 'USD', group: Group.named('Pricing')})
Category.add_or_update({ name: 'Destination Charge', unit: 'USD', group: Group.named('Pricing')})
Category.add_or_update({ name: 'Child Safety Door Locks', group: Group.named('Safety')})
Category.add_or_update({ name: 'Locking Pickup Truck Tailgate', group: Group.named('Safety'), enabled: false})
Category.add_or_update({ name: 'Power Door Locks', group: Group.named('Safety')})
Category.add_or_update({ name: 'Vehicle Anti-Theft', group: Group.named('Safety')})
Category.add_or_update({ name: '4WD/AWD', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'ABS Brakes', group: Group.named('Braking')})
Category.add_or_update({ name: 'Automatic Load-Leveling', group: Group.named('Feature')})
Category.add_or_update({ name: 'Electronic Brake Assistance', group: Group.named('Braking')})
Category.add_or_update({ name: 'Limited Slip Differential', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'Locking Differential', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'Traction Control', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'Vehicle Stability Control System', group: Group.named('Drivetrain')})
Category.add_or_update({ name: 'Driver Airbag', group: Group.named('Safety')})
Category.add_or_update({ name: 'Front Side Airbag', group: Group.named('Safety')})
Category.add_or_update({ name: 'Front Side Airbag with Head Protection', group: Group.named('Safety')})
Category.add_or_update({ name: 'Passenger Airbag', group: Group.named('Safety')})
Category.add_or_update({ name: 'Side Head Curtain Airbag', group: Group.named('Safety')})
Category.add_or_update({ name: 'Second Row Side Airbag', group: Group.named('Safety')})
Category.add_or_update({ name: 'Second Row Side Airbag with Head Protection', group: Group.named('Safety')})
Category.add_or_update({ name: 'Electronic Parking Aid', group: Group.named('Safety')})
Category.add_or_update({ name: 'First Aid Kit', group: Group.named('Safety'), enabled: false})
Category.add_or_update({ name: 'Trunk Anti-Trap Device', group: Group.named('Safety')})
Category.add_or_update({ name: 'Keyless Entry', group: Group.named('Safety')})
Category.add_or_update({ name: 'Remote Ignition', group: Group.named('Safety')})
Category.add_or_update({ name: 'Air Conditioning', group: Group.named('Comfort')})
Category.add_or_update({ name: 'Separate Driver/Front Passenger Climate Controls', group: Group.named('Comfort'), label: 'Individual Climate Controls'})
Category.add_or_update({ name: 'Cruise Control', group: Group.named('Feature')})
Category.add_or_update({ name: 'Tachometer', group: Group.named('Feature')})
Category.add_or_update({ name: 'Tilt Steering', group: Group.named('Feature')})
Category.add_or_update({ name: 'Tilt Steering Column', group: Group.named('Feature')})
Category.add_or_update({ name: 'Heated Steering Wheel', group: Group.named('Feature')})
Category.add_or_update({ name: 'Leather Steering Wheel', group: Group.named('Feature')})
Category.add_or_update({ name: 'Steering Wheel Mounted Controls', group: Group.named('Feature')})
Category.add_or_update({ name: 'Telescopic Steering Column', group: Group.named('Feature')})
Category.add_or_update({ name: 'Adjustable Foot Pedals', group: Group.named('Feature')})
Category.add_or_update({ name: 'Genuine Wood Trim', group: Group.named('Feature')})
Category.add_or_update({ name: 'Tire Pressure Monitor', group: Group.named('Tires')})
Category.add_or_update({ name: 'Trip Computer', group: Group.named('Feature')})
Category.add_or_update({ name: 'AM/FM Radio', group: Group.named('Entertainment'), enabled: false})
Category.add_or_update({ name: 'Cassette Player', group: Group.named('Entertainment'), enabled: false})
Category.add_or_update({ name: 'CD Player', group: Group.named('Entertainment'), enabled: false})
Category.add_or_update({ name: 'CD Changer', group: Group.named('Entertainment'), enabled: false})
Category.add_or_update({ name: 'DVD Player', group: Group.named('Entertainment'), enabled: false})
Category.add_or_update({ name: 'Voice Activated Telephone', group: Group.named('Entertainment')})
Category.add_or_update({ name: 'Navigation Aid', group: Group.named('Entertainment')})
Category.add_or_update({ name: 'Second Row Sound Controls', group: Group.named('Entertainment')})
Category.add_or_update({ name: 'Subwoofer', group: Group.named('Entertainment')})
Category.add_or_update({ name: 'Telematics System', group: Group.named('Entertainment')})
Category.add_or_update({ name: 'Driver Multi-Adjustable Power Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Front Cooled Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Front Heated Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Front Power Lumbar Support', group: Group.named('Seating')})
Category.add_or_update({ name: 'Front Power Memory Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Front Split Bench Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Leather Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Passenger Multi-Adjustable Power Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Second Row Folding Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Second Row Heated Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Second Row Multi-Adjustable Power Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Second Row Removable Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Third Row Removable Seat', group: Group.named('Seating')})
Category.add_or_update({ name: 'Cargo Area Cover', group: Group.named('Feature')})
Category.add_or_update({ name: 'Cargo Area Tiedowns', group: Group.named('Feature')})
Category.add_or_update({ name: 'Cargo Net', group: Group.named('Feature')})
Category.add_or_update({ name: 'Load Bearing Exterior Rack', group: Group.named('Feature')})
Category.add_or_update({ name: 'Pickup Truck Bed Liner', group: Group.named('Feature')})
Category.add_or_update({ name: 'Power Sunroof', group: Group.named('Feature')})
Category.add_or_update({ name: 'Removable Top', group: Group.named('Feature')})
Category.add_or_update({ name: 'Manual Sunroof', group: Group.named('Feature')})
Category.add_or_update({ name: 'Automatic Headlights', group: Group.named('Lighting')})
Category.add_or_update({ name: 'Daytime Running Lights', group: Group.named('Lighting')})
Category.add_or_update({ name: 'Fog Lights', group: Group.named('Lighting')})
Category.add_or_update({ name: 'High Intensity Discharge Headlights', group: Group.named('Lighting')})
Category.add_or_update({ name: 'Pickup Truck Cargo Box Light', group: Group.named('Lighting')})
Category.add_or_update({ name: 'Running Boards', group: Group.named('Feature')})
Category.add_or_update({ name: 'Front Air Dam', group: Group.named('Feature')})
Category.add_or_update({ name: 'Rear Spoiler', group: Group.named('Feature')})
Category.add_or_update({ name: 'Skid Plate', group: Group.named('Feature')})
Category.add_or_update({ name: 'Splash Guards', group: Group.named('Feature')})
Category.add_or_update({ name: 'Wind Deflector for Convertibles', group: Group.named('Feature')})
Category.add_or_update({ name: 'Power Sliding Side Van Door', group: Group.named('Feature')})
Category.add_or_update({ name: 'Power Trunk Lid', group: Group.named('Feature')})
Category.add_or_update({ name: 'Alloy Wheels', group: Group.named('Wheels and Tires')})
Category.add_or_update({ name: 'Chrome Wheels', group: Group.named('Wheels and Tires')})
Category.add_or_update({ name: 'Full Size Spare Tire', group: Group.named('Wheels and Tires')})
Category.add_or_update({ name: 'Run Flat Tires', group: Group.named('Wheels and Tires')})
Category.add_or_update({ name: 'Steel Wheels', group: Group.named('Wheels and Tires')})
Category.add_or_update({ name: 'Power Windows', group: Group.named('Feature')})
Category.add_or_update({ name: 'Electrochromic Exterior Rearview Mirror', group: Group.named('Feature')})
Category.add_or_update({ name: 'Glass Rear Window on Convertible', group: Group.named('Feature')})
Category.add_or_update({ name: 'Heated Exterior Mirror', group: Group.named('Feature')})
Category.add_or_update({ name: 'Electrochromic Interior Rearview Mirror', group: Group.named('Feature'), enabled: false})
Category.add_or_update({ name: 'Power Adjustable Exterior Mirror', group: Group.named('Feature')})
Category.add_or_update({ name: 'Deep Tinted Glass', group: Group.named('Feature'), enabled: false})
Category.add_or_update({ name: 'Interval Wipers', group: Group.named('Feature')})
Category.add_or_update({ name: 'Rain Sensing Wipers', group: Group.named('Feature')})
Category.add_or_update({ name: 'Rear Window Defogger', group: Group.named('Feature')})
Category.add_or_update({ name: 'Rear Wiper', group: Group.named('Feature')})
Category.add_or_update({ name: 'Sliding Rear Pickup Truck Window', group: Group.named('Feature')})
Category.add_or_update({ name: 'Tow Hitch Receiver', group: Group.named('Feature')})
Category.add_or_update({ name: 'Towing Preparation Package'})
Category.add_or_update({ name: 'SAE Net Horsepower @ RPM'})
Category.add_or_update({ name: 'SAE Net Torque @ RPM'})
Category.add_or_update({ name: 'OEM Code'})
Category.add_or_update({ name: 'OEM Model Number'})
Category.add_or_update({ name: 'Passenger Capacity'})

# Classic Groups
ClassicGroup.add_or_update(name: 'Basic')
ClassicGroup.add_or_update(name: 'Body')
ClassicGroup.add_or_update(name: 'Dimension', label: 'Dimensions')
ClassicGroup.add_or_update(name: 'Engine')
ClassicGroup.add_or_update(name: 'Carburetor')
ClassicGroup.add_or_update(name: 'Transmission')
ClassicGroup.add_or_update(name: 'Clutch Type', label: 'Clutch')
ClassicGroup.add_or_update(name: 'Axle Type', label: 'Axle')
ClassicGroup.add_or_update(name: 'Differential')
ClassicGroup.add_or_update(name: 'Suspension')
ClassicGroup.add_or_update(name: 'Steering Gear', label: 'Steering')
ClassicGroup.add_or_update(name: 'Brakes')
ClassicGroup.add_or_update(name: 'Other Systems Specifications', label: 'Other Specifications')
ClassicGroup.add_or_update(name: 'Wheels, Rims & Tires', label: 'Wheels and Tires')
ClassicGroup.add_or_update(name: 'Capacities', label: 'Specifications')
ClassicGroup.add_or_update(name: 'Classic Rating')
ClassicGroup.add_or_update(name: 'VIN_Data', label: 'VIN Information')
ClassicGroup.add_or_update(name: 'Additional Information', label: 'Information')
ClassicGroup.add_or_update(name: 'Exterior Colors', label: 'Colors')
ClassicGroup.add_or_update(name: 'Standard/Optional Equipment', label: 'Equipment')

# Classic Categories
ClassicCategory.add_or_update(name: '1st', group: ClassicGroup.named('Transmission'), unit: ':1' , code: '1gear') # 2.67 to 1
ClassicCategory.add_or_update(name: '2nd', group: ClassicGroup.named('Transmission'), unit: ':1' , code: '2gear') # 1.66 to 1
ClassicCategory.add_or_update(name: '3rd', group: ClassicGroup.named('Transmission'), unit: ':1' , code: '3gear') # 1 to 1
ClassicCategory.add_or_update(name: '4th', group: ClassicGroup.named('Transmission'), unit: ':1' , code: '4gear') # 1 to 1
ClassicCategory.add_or_update(name: '5th', group: ClassicGroup.named('Transmission'), unit: ':1' , code: '5gear') # Not applicable
ClassicCategory.add_or_update(name: 'Additional Information', group: ClassicGroup.named('Additional Information'), unit: nil, enabled: false , code: 'add') # Serial Nos.  1-5360001 & up, 2-5370001 & up, 3-5374001 & up, 4-538001 & up, 5-5388001 & up, 6-5393001 & up, 7-5397001 & up.
ClassicCategory.add_or_update(name: 'Axle Type', group: ClassicGroup.named('Axle Type'), unit: nil , code: 'axle') # Semifloating
ClassicCategory.add_or_update(name: 'Battery', group: ClassicGroup.named('Other Systems Specifications'), unit: nil , code: 'batt' ) # 6
ClassicCategory.add_or_update(name: 'Block Material', group: ClassicGroup.named('Engine'), unit: nil , code: 'block') # Cast Iron
ClassicCategory.add_or_update(name: 'Body Maker', group: ClassicGroup.named('Body'), unit: nil , code: 'maker') # Fisher
ClassicCategory.add_or_update(name: 'Bore & Stroke', group: ClassicGroup.named('Engine'), unit: 'in.' , label: 'Bore &#38; Stroke' , code: 'b&s') # 3 7/16 & 4 5/16 inches
ClassicCategory.add_or_update(name: 'Brake Horsepower', group: ClassicGroup.named('Engine'), unit: 'hp' , code: 'bhp') # 152@3600
ClassicCategory.add_or_update(name: 'Classic Rating', group: ClassicGroup.named('Classic Rating'), unit: nil, enabled: false ) # Not Rated
ClassicCategory.add_or_update(name: 'Clutch Size', group: ClassicGroup.named('Clutch Type'), unit: nil, code: 'csize' ) # 10 inches
ClassicCategory.add_or_update(name: 'Clutch Type', group: ClassicGroup.named('Clutch Type'), unit: nil , code: 'ctype') # Not applicable
ClassicCategory.add_or_update(name: 'Colors', group: ClassicGroup.named('Exterior Colors'), unit: nil, label: 'Exterior Colors' , code: 'color') # Exterior Colors
ClassicCategory.add_or_update(name: 'Compression Ratio-Opt', group: ClassicGroup.named('Engine'), unit: ':1', enabled: false , code: 'compo') # 7.2 to 1
ClassicCategory.add_or_update(name: 'Compression Ratio-Std', group: ClassicGroup.named('Engine'), unit: ':1', label: 'Compression Ratio' , code: 'comp') # 7.2 to 1
ClassicCategory.add_or_update(name: 'Cooling System', group: ClassicGroup.named('Other Systems Specifications'), unit: nil , code: 'cool') # Centrifugal pump with thermostat
ClassicCategory.add_or_update(name: 'Cylinders', group: ClassicGroup.named('Engine'), unit: nil , code: 'cyl') # 8
ClassicCategory.add_or_update(name: 'Differential', group: ClassicGroup.named('Differential'), unit: nil , code: 'diff') # Hypoid
ClassicCategory.add_or_update(name: 'Differential Ratio', group: ClassicGroup.named('Differential'), unit: ':1' , code: 'diffr') # 3.60
ClassicCategory.add_or_update(name: 'Displacement', group: ClassicGroup.named('Engine'), unit: 'cu. in.' , code: 'disp') # 320.2 cu. in.
ClassicCategory.add_or_update(name: 'Drive', group: ClassicGroup.named('Transmission'), unit: nil , code: 'drive') # Rear wheel drive
ClassicCategory.add_or_update(name: 'Emergency', group: ClassicGroup.named('Brakes'), unit: nil, label: 'Emergency Brake' , code: 'ebrake') # Rear service brakes
ClassicCategory.add_or_update(name: 'Engine No. Location', group: ClassicGroup.named('Engine'), unit: nil , code: 'englo') # Boss on right side of crankcase near rear.
ClassicCategory.add_or_update(name: 'Engine Numbers', group: ClassicGroup.named('Engine'), unit: nil , code: 'engno') # Starting 5635021-7
ClassicCategory.add_or_update(name: 'Equipment', group: ClassicGroup.named('Standard/Optional Equipment'), unit: nil , code: 'equip') # Dynaflow automatic transmission
ClassicCategory.add_or_update(name: 'Exhaust System', group: ClassicGroup.named('Other Systems Specifications'), unit: nil , code: 'exha') # Single
ClassicCategory.add_or_update(name: 'Front', group: ClassicGroup.named('Suspension'), unit: nil, label: 'Front Suspension' , code: 'fsus') # Independent coil springs
ClassicCategory.add_or_update(name: 'Front Differential', group: ClassicGroup.named('Capacities'), unit: 'pt.' , code: 'fdiff') # 5 Pints
ClassicCategory.add_or_update(name: 'Front Size', group: ClassicGroup.named('Brakes'), unit: 'in.' , label: 'Front Brake Size', code: 'fbsize') # 11 55/64 inches
ClassicCategory.add_or_update(name: 'Front Tread', group: ClassicGroup.named('Dimension'), unit: 'in.' , code: 'ftred') # 59.125 inches
ClassicCategory.add_or_update(name: 'Fuel', group: ClassicGroup.named('Capacities'), unit: 'gal.', label: 'Fuel Tank' , code: 'fuel') # 19 Gallons
ClassicCategory.add_or_update(name: 'Fuel Type', group: ClassicGroup.named('Other Systems Specifications'), unit: nil , code: 'ftype') # Premium
ClassicCategory.add_or_update(name: 'Height', group: ClassicGroup.named('Dimension'), unit: 'in.' , code: 'height') # 64 13/32 inches
ClassicCategory.add_or_update(name: 'Ignition System', group: ClassicGroup.named('Other Systems Specifications'), unit: nil , code: 'ign') # Distributor and coil
ClassicCategory.add_or_update(name: 'Length', group: ClassicGroup.named('Dimension'), unit: 'in.' , code: 'length') # 208 13/16 inches
ClassicCategory.add_or_update(name: 'Lubrication', group: ClassicGroup.named('Engine'), unit: nil , code: 'lube') # Pressure to all bearings excluding wrist pin
ClassicCategory.add_or_update(name: 'Main Bearings', group: ClassicGroup.named('Engine'), unit: nil , code: 'mbear') # 5
ClassicCategory.add_or_update(name: 'Make', group: ClassicGroup.named('Basic'), unit: nil , code: 'make') # Buick
ClassicCategory.add_or_update(name: 'Make', group: ClassicGroup.named('Carburetor'), unit: nil, label: 'Carburetor Make' , code: 'carb') # Carter or Stromberg
ClassicCategory.add_or_update(name: 'Model Number', group: ClassicGroup.named('Body'), unit: nil , code: 'model') # 76C
ClassicCategory.add_or_update(name: 'Model Year', group: ClassicGroup.named('Basic'), unit: nil , code: 'year') # 1950
ClassicCategory.add_or_update(name: 'No. Doors', group: ClassicGroup.named('Body'), unit: nil, label: 'Doors' , code: 'doors') # 2
ClassicCategory.add_or_update(name: 'No. Of Gears', group: ClassicGroup.named('Transmission'), unit: nil, label: 'Gears' , code: 'gears') # 4
ClassicCategory.add_or_update(name: 'No. Produced', group: ClassicGroup.named('Basic'), unit: nil, label: 'Production' , code: 'prod') # 2964
ClassicCategory.add_or_update(name: 'Oil', group: ClassicGroup.named('Capacities'), unit: 'qt.' , code: 'oil') # 8 Quarts
ClassicCategory.add_or_update(name: 'Origin', group: ClassicGroup.named('Basic'), unit: nil , code: 'origin') # United States
ClassicCategory.add_or_update(name: 'Original Base Price', group: ClassicGroup.named('Basic'), unit: 'USD', label: 'Base Price' , code: 'msrp') # $2935.00
ClassicCategory.add_or_update(name: 'Passengers', group: ClassicGroup.named('Body'), unit: nil , code: 'pass') # 6
ClassicCategory.add_or_update(name: 'Radiator', group: ClassicGroup.named('Other Systems Specifications'), unit: nil , code: 'rad') # Vee cellular
ClassicCategory.add_or_update(name: 'Rated Horsepower', group: ClassicGroup.named('Engine'), unit: 'hp' , code: 'rhp') # 37.8
ClassicCategory.add_or_update(name: 'Rear', group: ClassicGroup.named('Suspension'), unit: nil, label: 'Rear Suspension' , code: 'rsus') # Coil springs
ClassicCategory.add_or_update(name: 'Rear Differential', group: ClassicGroup.named('Capacities'), unit: 'pt.' , code: 'rdiff') # 4 Pints
ClassicCategory.add_or_update(name: 'Rear Size', group: ClassicGroup.named('Brakes'), unit: 'in.' , label: 'Rear Brake Size', code: 'rbsize') # 12 inches
ClassicCategory.add_or_update(name: 'Rear Tread', group: ClassicGroup.named('Dimension'), unit: 'in.' , code: 'rtred') # 62 7/32 inches
ClassicCategory.add_or_update(name: 'Reverse', group: ClassicGroup.named('Transmission'), unit: ':1' , code: 'rev') # 3.02 to 1
ClassicCategory.add_or_update(name: 'Series', group: ClassicGroup.named('Basic'), unit: nil , code: 'series') # Roadmaster
ClassicCategory.add_or_update(name: 'Service', group: ClassicGroup.named('Brakes'), unit: nil , code: 'svc') # Hydraulic drum
ClassicCategory.add_or_update(name: 'Size', group: ClassicGroup.named('Brakes'), unit: 'in.', label: 'Brake Size', code: 'bsize') # 12 inches
ClassicCategory.add_or_update(name: 'Spare Location', group: ClassicGroup.named('Wheels, Rims & Tires'), unit: nil , code: 'sloc') # Trunk
ClassicCategory.add_or_update(name: 'Steering Gear', group: ClassicGroup.named('Steering Gear'), unit: nil , code: 'sgear') # Ball bearing worm and nut
ClassicCategory.add_or_update(name: 'Tire Size', group: ClassicGroup.named('Wheels, Rims & Tires'), unit: nil , code: 'tsize') # 8 x 15
ClassicCategory.add_or_update(name: 'Tire Type', group: ClassicGroup.named('Wheels, Rims & Tires'), unit: nil , code: 'ttype') # 4 ply
ClassicCategory.add_or_update(name: 'Torque', group: ClassicGroup.named('Engine'), unit: 'ft/lbs' , code: 'trq') # 280@2000
ClassicCategory.add_or_update(name: 'Transfer Case', group: ClassicGroup.named('Capacities'), unit: nil , code: 'tcase') # Not Applicable
ClassicCategory.add_or_update(name: 'Transmission', group: ClassicGroup.named('Capacities'), unit: 'pt.' , code: 'trans') # 22 Pints
ClassicCategory.add_or_update(name: 'Type', group: ClassicGroup.named('Engine'), unit: nil, label: 'Engine Type' , code: 'etype') # Overhead valve
ClassicCategory.add_or_update(name: 'VIN Location', group: ClassicGroup.named('VIN_Data'), unit: nil, enabled: true , code: 'vloc') # Plate on left front door pillar & stamped on left front frame crossmember extension.
ClassicCategory.add_or_update(name: 'Valve Lifters', group: ClassicGroup.named('Engine'), unit: nil , code: 'vlift') # Hydraulic
ClassicCategory.add_or_update(name: 'Weight', group: ClassicGroup.named('Body'), unit: 'lbs' , code: 'weight') # 4025 lbs
ClassicCategory.add_or_update(name: 'Wheel Mfr', group: ClassicGroup.named('Wheels, Rims & Tires'), unit: nil , code: 'wmfr') # Kelsey Hayes
ClassicCategory.add_or_update(name: 'Wheel Size', group: ClassicGroup.named('Wheels, Rims & Tires'), unit: nil , code: 'wsize') # 15 x 6.5
ClassicCategory.add_or_update(name: 'Wheel Type', group: ClassicGroup.named('Wheels, Rims & Tires'), unit: nil , code: 'wtype') # Steel disc
ClassicCategory.add_or_update(name: 'Wheelbase', group: ClassicGroup.named('Dimension'), unit: 'in.' , code: 'wbase') # 126 5/16 inches
ClassicCategory.add_or_update(name: 'Width', group: ClassicGroup.named('Dimension'), unit: 'in.' , code: 'width') # 80 inches
ClassicCategory.add_or_update(name: 'Note', group: ClassicGroup.named('Additional Information'), unit: '' , code: 'note') # 80 inches
ClassicCategory.add_or_update(name: 'Assembly Plant', group: ClassicGroup.named('Basic'), unit: '', code: 'plant') # Dearborn, MI
ClassicCategory.add_or_update(name: 'Engine', group: ClassicGroup.named('Engine'), unit: '', code: 'engine') # 139 CID 2V 4-Cyl
ClassicCategory.add_or_update(name: 'Body Style', group: ClassicGroup.named('Basic'), unit: '', code: 'style') # 139 CID 2V 4-Cyl
ClassicCategory.add_or_update(name: 'Style Code', group: ClassicGroup.named('Basic'), unit: '', code: 'code') # D45
ClassicCategory.add_or_update(name: 'Trim Level', group: ClassicGroup.named('Basic'), unit: '', code: 'trim') # D45


# create status types
Status.add_or_update(name: 'UNKNOWN', message: 'Unknown status', success: false)
Status.add_or_update(name: 'VALID', message: 'Successfully decoded VIN', success: true)
Status.add_or_update(name: 'MISSINGVIN', message: 'No VIN present', success: false)
Status.add_or_update(name: 'INVALIDLENGTH', message: 'VIN is not 17 characters in length', success: false)
Status.add_or_update(name: 'INVALIDCHECK', message: 'VIN has an invalid checksum', success: false)
Status.add_or_update(name: 'VALIDCHECK', message: 'VIN has a valid checksum', success: true)
Status.add_or_update(name: 'NOMATCH', message: 'VIN does not match vehicle in database', success: false)
Status.add_or_update(name: 'VALIDCHARACTERS', message: 'VIN contains valid characters', success: true)
Status.add_or_update(name: 'INVALIDCHARACTERS', message: 'VIN contains invalid characters', success: false)
Status.add_or_update(name: 'MATCH', message: 'VIN matches vehicle pattern', success: true)
Status.add_or_update(name: 'SECURITY', message: 'Invalid user account', success: false)
Status.add_or_update(name: 'EXPIRED', message: 'User account has expired', success: false)



DT.p 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.where({ :name => role }).first_or_create
  DT.p 'role: ' << role
end
DT.p 'PLANS'
PLANS.each do |plan_name|
  plan = plan_name[1]
  DT.p 'plan: ' << plan[:name]
  p = Plan.where(:name => plan[:name]).first_or_create
  p.role = Role.where(name: plan[:role]).first
  p.per_day = plan[:per_day]
  p.per_month = plan[:per_month]
  p.public = plan[:public]
  p.ip = plan[:ips]
  p.decode_type = plan[:decode_type]
  p.bulk_decodes = plan[:bulk_decodes]
  p.description = plan[:description]
  p.color = plan[:color]
  p.price = plan[:price]
  p.order = plan[:order]
  p.save
end

# Create default users
# System admin
admin = User.add_or_update(
    name: ENV['ADMIN_NAME'].dup,
    email: ENV['ADMIN_EMAIL'].dup,
    password: ENV['ADMIN_PASSWORD'].dup,
    authentication_token: '4vjNVNQBwhxvzbCF9way',
    admin: true,
    subscription: FreeSubscription.create(note: 'Admin subscription', active: true)
)
admin.roles.destroy_all
admin.add_role :admin


# Guest user
guest = User.add_or_update(
    name: 'guest',
    email: 'guest@example.com',
    password: '1234567890',
    authentication_token: '3vjN3NQBwhx3zbCFJoJ0',
    admin: false,
    subscription: FreeSubscription.create(note: 'Free subscription', active: true)
)
if guest.roles.count == 0
  guest.add_role :guest
end

# decodeThis bronze user
default = User.add_or_update(
    name: 'default',
    email: 'info@example.com',
    password: 'gungho!hogun',
    authentication_token: 'QvjAbAQBwhxvzbCF9tmp',
    admin: false,
    subscription: StripeSubscription.create( active: true)
)
default.add_role :bronze if default.roles.count == 0

# decodeThis silver user
test1 = User.add_or_update(
    name: 'test1',
    email: 'info1@example.com',
    password: 'change_me',
    authentication_token: 'QvjAbAQBwhxvzbCF1tmp',
    admin: false,
    subscription: StripeSubscription.create( active: true)
)
test1.add_role :silver if test1.roles.count == 0

# decodeThis gold user
test2 = User.add_or_update(
    name: 'test2',
    email: 'info2@example.com',
    password: 'change_me',
    authentication_token: 'QvjAbAQBwhxvzbCF2tmp',
    admin: false,
    subscription: StripeSubscription.create( active: true)

)
test2.add_role :gold if test2.roles.count == 0

# decodeThis platinum user
test3 = User.add_or_update(
    name: 'test3',
    email: 'info3@example.com',
    password: 'change_me',
    authentication_token: 'QvjAbAQBwhxvzbCF3tmp',
    admin: false,
    subscription: StripeSubscription.create( active: true)
)
test3.add_role :platinum if test3.roles.count == 0

# decodeThis platinum user
sample = User.add_or_update(
    name: 'sample',
    email: 'sample@example.com',
    password: 'change_me',
    authentication_token: ENV['SAMPLE_TOKEN'],
    admin: false,
    subscription: StripeSubscription.create( active: true)
)
sample.add_role :platinum if sample.roles.count == 0


# VINHunter user
vinhunter = User.add_or_update(
    name: 'vinhunter',
    email: 'support@example.com',
    password: 'sun*shine',
    authentication_token: '9vjAb3cwhx5zbCF9oLd',
    admin: false,
    subscription: FreeSubscription.create(note: 'VIN Hunter Subscription', active: true)
)
vinhunter.add_role :vinhunter if vinhunter.roles.count == 0

# Expired user
expired = User.add_or_update(
    name: 'expired',
    email: 'expired@example.com',
    password: 'sun*shine',
    authentication_token: '9vjAb3cwhx5zbCF9000',
    admin: false,
    subscription: InvoiceSubscription.create(active: false)
)
expired.add_role :vinhunter if expired.roles.count == 0

DT.p '*** Loaded seed data'