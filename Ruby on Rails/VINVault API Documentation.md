# VINVault API Documentation

Welcome to VINVault.com, and thank you for considering our data source.  We have carefully cultivated an accurate and reliable source of VIN data for North America, and we're proud to share it with our customers.

Our data source is built for speed. We pre-cache a lot of the calculations on the server-side in order to provide the best response time possible for our customers.  If at any time you notice unacceptable speeds, or inaccurate data, please contact us at [support@vinvault.com](mailto:support@vinvault.com).

The data service is built on Ruby on Rails, and provides a [RESTful](http://en.wikipedia.org/wiki/Representational_state_transfer) solution for VIN data.  To that end most communication to the service will be in HTTP `POST`s that will create a `Decode` object in our database.  

Each vehicle you decode will have a single `Decode` object representing it, no matter how many times you request that vehicle by VIN.  Your access is logged, though, by request, so if you make multiple requests for the same VIN you will always get back the same data but each request will count against your subscription's quota.

## The API Request

### API Usage

Each subscription has certain usage caps, as described on the [Plans](http://vinvault.com/plans) page.  Each successful decode request counts against your monthly and daily totals.  Unsuccessful requests do not count against your total.  Be aware that a request can be successful and not yield a valid VIN decode.  Passing an invalid VIN, for example, will still result in a decode, just one that is marked as resulting from an invalid VIN.

Note that the Platinum plan has 'unlimited' daily and monthly decodes.  While unlimited, the Terms of Service states that you can only use the service for your own needs; you can't resell access to the service directly.  We reserve the right to terminate any account that abuses the Terms of Service.

If you have additional needs for decode caps that aren't currently available please contact us, we'll work with you to come up with a viable solution.  

### API End Point

There is one primary end point for the API that supplies data for both the Basic and Advanced types of decodes.  It provides different views of the same data (Basic is simplistic, designed for light-weight use, while the Advanced provides the full suite of data on each request).  

If your subscription provides access to the Advanced API you can also make requests against the Basic API by adding the parameter `type=1` to your query.

|End Point|HTTP Verb| URI|
|-------|-----|----|
| Basic | POST|http://api.vinvault.com/api/decodes[.format]|
| Advanced | POST|http://api.vinvault.com/api/decodes[.format]|

The API supports the following data formats.

|Format    | Suffix | Description|
|----------|--------|------------|
| **JSON** | .json  | JSON format (default)|
| **XML**  | .xml   | XML format |
| **JSONP**| .js    | AJAX requests |

### API Parameters

| Parameter     | Description |
| ------------- | ----------- |
| **vin**       | Vehicle's VIN |
| **auth_key**  | Your authentication |
| **callback**  | JSONP callback method name |
| **type**      | The decode type: 1 = Basic, 2 = Advanced |

The `type` parameter is optional.  By default the decode type returned is the highest available for your subscription.  So if you have access to Advanced decodes you default to the Advanced decode format.  If your subscription only allows Basic decodes and you attempt to access an Advanced decode format you will receive a `401 Unauthorized` HTTP status in the response.

You can find your API auth_key on your account's dashboard page when you log into VINVault.com.  It will also be emailed to you upon signing up to the service.

These parameters may be passed in the body of the `POST` to the API or in the query string.

### API Versioning

We anticipate there being changes to the API over time, and therefore have implemented the API to support versioning.  You can request your query to be served by a specific version of the API, or simply default to the latest version.

Instead of providing separate endpoints for each version of the API, we use the concept of requesting the version in the [Accept Header](http://pivotallabs.com/api-versioning/).  This provides a single API endpoint, requiring little updating on your end in the future.

To request a specific version of the API you must pass in the header of your request a reference to the version you wish:

```
Accept: application/vnd.vindata.v<version number>
```

As of this writing the most current version is version 1, so the header value would be:

```
Accept: application/vnd.vindata.v1
```

This allows you to continue to use older API versions even after newer versions are available.  While the `Accept` header is optional, if you supply it from the start you will always get the version of the API you expect in the future.

### Example API Requests

**Note:** The `auth_token` **RLBVPvj8riQmRuPzcT** always returns the same VIN: 1D7RB1CT8AS203937 with both Basic and Advanced access.  Feel free to use for testing purposes.

Basic API (XML output):

```
POST: http://api.vinvault.com/api/decodes.xml?vin=1D7RB1CT8AS203937&auth_token=RLBVPvj8riQmRuPzcT&type=1
```

Basic API (JSON output because it is the default format):

```
POST: http://api.vinvault.com/api/decodes?vin=1D7RB1CT8AS203937&auth_token=RLBVPvj8riQmRuPzcT&type=1
```
or using `curl`:
```
curl -X POST 'http://api.vinvault.com/api/decodes.xml?vin=1D7RB1CT8AS203937&auth_token=RLBVPvj8riQmRuPzcT&type=1'
```

_The `type=1` parameter is added above to force the output to be Basic (1) since the plan associated with the `auth_token` supports Advance decodes (Platinum plan), which would be the default.  For a Bronze account, for example, it would be unnecessary since that plan only supports Basic output._

Advanced API (JSONP output):

```
POST: http://api.vinvault.com/api/decodes.js?vin=1D7RB1CT8AS203937&auth_token=RLBVPvj8riQmRuPzcT&callback=func_callbk
```

Advanced API (JSON output):

```
POST: http://api.vinvault.com/api/decodes?vin=1D7RB1CT8AS203937&auth_token=RLBVPvj8riQmRuPzcT
```

### Retrieving Existing Decodes

If you have previously decoded a VIN the data is stored for you for later retrieval.  Calls against the API for existing decodes does not count towards your limit.  Previous decodes are made available for a 90-day period.  Past that point they are subject to deletion.

To retrieve an existing decode use the ID passed with the response for your original API call.  This is the `id` attribute in the `decode` node of the response.  Using an HTTP `GET` you can pass the ID of the desired record:

```
GET:  http://api.vinvault.com/api/decodes/<id_of_record>[.format]?auth_token=<your_token>&[type=1]
```

|Parameter|Meaning|
|---------|-------|
|id|ID of record|
|auth_token|Your authentication token|
|type|1 = Basic, 2 = Advanced (optional) |
|format| .json (default), .js, .xml (optional) |

Sample:

```
GET: http://api.vinvault.com/api/decodes/111?&auth_token=RLBVPvj8riQmRuPzcT&type=1
```


The above would return a Basic format decode for record #111 in JSON format (the default).

Requesting a ID for a decode that does not exist will result in a `404 Not Found` HTTP status in the response.

**Note:** You can only retrieve records for VINs you decoded with your account.  Attempts to retrieve other decodes will result in a `401 Unauthorized` HTTP status.

## The API Response

The API will reply to each request with an HTTP response that includes the data requested, or an error code in the case that there was an issue.  

_**Note:** The API will respond with a `201 Created` response even if there is an issue with the VIN such as an invalid checksum digit.  The decode is created, but flagged as being unsuccessful.  This allows the API to respond in the correct format with the status messages that will allow you to determine the cause of the unsuccessful result._

The response will be provided in gzip format if the request includes the proper gzip `Accept` header.

### Response Codes

The HTTP response code will help you determine the overall status of your request.  Only a response code of `201 Created` will actually return data.  The other codes will return an error message instead.

HTTP status `500 Server Error` indicates an error in the server's ability to respond to your request.  If you receive this response code please let us know the VIN and format you were attempting to request.


|Code   |Meaning|
|-------|-------|
|**201**|Successful decode|
|**401**|Plan authorization failure|
|**403**|Account authentication failure|
|**404**|Unknown format (not .js, .xml, or .json) or record not found|
|**500**|Server error, please [contact us](mailto:support@vinvault.com).|

### Response Body

The service will supply in the body of the response the data representing the vehicle when the code is a **201**.  The overall format of the data is as follows:

**XML format**
```xml
<decode api_version='1' type='2' id='139' vin='JB3BM54J3PY006076' year='1993' make='Dodge' series='Stealth' success='true' date='2013-10-20 00:30:11 UTC' status='true'>
    <status name='VALID' message='Successfully decoded VIN'></status>
    <status name='VALIDCHECK' message='VIN has a valid checksum'></status>
    <status name='VALIDCHARACTERS' message='VIN contains valid characters'></status>
    <status name='MATCH' message='VIN matches vehicle pattern'></status>
    <trim id='32323' name='ES'>
        <data category='Model Year' value='1993' unit='' group='Basic'></data>
        <data category='Make' value='Dodge' unit='' group='Basic'></data>
        <data category='Model' value='Stealth' unit='' group='Basic'></data>
        <data category='Trim Level' value='ES' unit='' group='Basic'></data>
        <data category='Origin' value='Japan' unit='' group='Basic'></data>
        <data category='Body Type' value='Hatchback 2 Dr' unit='' group='Basic'></data>
        <data category='Engine Type' value='3.0L V6 DOHC 24V' unit='' group='Drivetrain'></data>
        <data category='Transmission (short)' value='' unit='' group='Drivetrain'>
            <option id='1'>5M OD</option>
            <option id='2'>4A OD</option>
        </data>
        <data category='Transmission (long)' value='' unit='' group='Drivetrain'>
    </trim>
</decode>
```

#### `Decode` Node

Root node of the response.  Contains general information about the decode.

|Attribute|Type|Value|
|---------|----|-----|
|api_version|integer|Version of API|
|type|integer|1 = Basic, 2 = Advanced|
|id|integer|ID of decode|
|vin|string|Requested VIN|
|year|integer|Year of Manufacture|
|make|string|Manufacturer|
|series|string|Vehicle series name|
|status|boolean|Whether the response is a valid decode|
|date|DateTime|UTC date of decode|

#### `Status` Node
The status nodes give information into the decoding process, describing why the decode provides valid or invalid information.

|Attribute|Type|Value|
|---------|----|-----|
|name|String|Name of the status code|
|message|String|Message of status|

The status code values are:

| Name  | Message  |
|---------------|----------------|
| **EXPIRED** 	| User account has expired |
| **INVALIDCHARACTERS** 	| VIN contains invalid characters |
| **INVALIDCHECK** 	| VIN has an invalid checksum |
| **INVALIDLENGTH** 	| VIN is not 17 characters in length |
| **MATCH** 	| VIN matches vehicle pattern |
| **MISSINGVIN** 	| No VIN present |
| **NOMATCH** 	| VIN does not match vehicle in database |
| **SECURITY** 	| Invalid user account |
| **UNKNOWN** 	| Unknown status |
| **VALID** 	| Successfully decoded VIN |
| **VALIDCHARACTERS** 	| VIN contains valid characters |
| **VALIDCHECK** 	| VIN has a valid checksum |

#### `Trim` Node
The `trim` node represents a specific trim level for the vehicle type decoded by the VIN.  In some cases vehicles have more than one trim type, so you can have multiple `trim` nodes in a decode.  Each `trim` node will also have a collection of `data` nodes that fully describe the trim level.

|Attribute|Type|Value|
|---------|----|-----|
|id       | Integer | ID of trim record|
|name|String|Name of the trim level|

#### `Data` Node
The actual vehicle data for the particular `trim` node is contained in `data` elements.  One `data` element represents one particular category of information for the vehicle.

|Attribute|Type|Value|
|---------|----|-----|
|category|String|Name of category of the node|
|unit|String|Unit of measure|
|value|String|Data for this category|
|group|String|The grouping header|

#### `Option` Node
Some `data` nodes represent multiple choices (such as transmission or colors).  In these cases the possible values are provided as child nodes to the relevant `data` node.

|Attribute|Type|Value|
|---------|----|-----|
|id|Integer|Unique ID of option|


### `Category` Values

Each `data` node has a `category` property that defines the type of data that is represented.  The following is a list of all the defined category types:

|Categories|Group|
|----------|-----|
|4WD/AWD|Drivetrain|
|ABS Brakes|Braking|
|AM/FM Radio|Entertainment|
|Adjustable Foot Pedals|Feature|
|Air Conditioning|Comfort|
|Alloy Wheels|Wheels and Tires|
|Anti-Brake System|Braking|
|Automatic Headlights||
|Automatic Load-Leveling|Feature|
|Basic (distance)|Warranty|
|Basic (duration)|Warranty|
|Body Type|Basic|
|CD Changer|Entertainment|
|CD Player|Entertainment|
|Cargo Area Cover|Feature|
|Cargo Area Tiedowns|Feature|
|Cargo Length|Dimensions|
|Cargo Net|Feature|
|Cargo Volume|Dimensions|
|Cassette Player|Entertainment|
|Child Safety Door Locks|Safety|
|Chrome Wheels|Wheels and Tires|
|Cruise Control|Feature|
|Curb Weight|Weight|
|DVD Player|Entertainment|
|Daytime Running Lights||
|Dealer Invoice||
|Depth|Dimensions|
|Destination Charge||
|Doors|Seating|
|Driveline|Drivetrain|
|Driver Airbag|Safety|
|Driver Multi-Adjustable Power Seat|Seating|
|Electrochromic Exterior Rearview Mirror|Feature|
|Electronic Brake Assistance|Braking|
|Electronic Parking Aid|Safety|
|Engine Type|Drivetrain|
|Exterior Color|Colors|
|Fog Lights||
|Front Air Dam|Feature|
|Front Brake Type|Braking|
|Front Cooled Seat|Seating|
|Front Headroom|Dimensions|
|Front Heated Seat|Seating|
|Front Hip Room|Dimensions|
|Front Legroom|Dimensions|
|Front Power Lumbar Support|Seating|
|Front Power Memory Seat|Seating|
|Front Shoulder Room|Dimensions|
|Front Side Airbag|Safety|
|Front Side Airbag with Head Protection|Safety|
|Front Split Bench Seat|Seating|
|Front Spring Type|Suspension|
|Front Suspension|Suspension|
|MPG (city)||
|MPG (hwy)||
|Fuel Type||
|Full Size Spare Tire|Wheels and Tires|
|Genuine Wood Trim|Feature|
|Glass Rear Window on Convertible|Feature|
|Ground Clearance|Dimensions|
|Heated Exterior Mirror|Feature|
|Heated Steering Wheel|Feature|
|High Intensity Discharge Headlights||
|Interior Trim|Colors|
|Interval Wipers|Feature|
|Invalid||
|Keyless Entry|Safety|
|Leather Seat|Seating|
|Leather Steering Wheel|Feature|
|Limited Slip Differential|Drivetrain|
|Load Bearing Exterior Rack|Feature|
|Locking Differential|Drivetrain|
|Locking Pickup Truck Tailgate|Safety|
|MSRP||
|Make|Basic|
|Manual Sunroof|Feature|
|Origin|Basic|
|Maximum GVWR|Weight|
|Maximum Payload|Weight|
|Maximum Towing|Weight|
|Model|Basic|
|Model Year|Basic|
|Navigation Aid|Entertainment|
|OEM Code||
|OEM Model Number||
|Optional Seating|Seating|
|Height|Dimensions|
|Length|Dimensions|
|Width|Dimensions|
|Passenger Airbag|Safety|
|Passenger Capacity||
|Passenger Multi-Adjustable Power Seat|Seating|
|Passenger Volume|Dimensions|
|Pickup Truck Bed Liner|Feature|
|Pickup Truck Cargo Box Light||
|Power Adjustable Exterior Mirror|Feature|
|Power Door Locks|Safety|
|Power Sliding Side Van Door|Feature|
|Power Sunroof|Feature|
|Power Trunk Lid|Feature|
|Power Windows|Feature|
|Powertrain (distance)|Warranty|
|Powertrain (duration)|Warranty|
|Rain Sensing Wipers|Feature|
|Rear Brake Type|Braking|
|Rear Headroom|Dimensions|
|Rear Hip Room|Dimensions|
|Rear Legroom|Dimensions|
|Rear Shoulder Room|Dimensions|
|Rear Spoiler|Feature|
|Rear Spring Type|Suspension|
|Rear Suspension|Suspension|
|Rear Window Defogger|Feature|
|Rear Wiper|Feature|
|Remote Ignition|Safety|
|Removable Top|Feature|
|Run Flat Tires|Wheels and Tires|
|Running Boards|Feature|
|SAE Net Horsepower @ RPM||
|SAE Net Torque @ RPM||
|Second Row Folding Seat|Seating|
|Second Row Heated Seat|Seating|
|Second Row Multi-Adjustable Power Seat|Seating|
|Second Row Removable Seat|Seating|
|Second Row Side Airbag|Safety|
|Second Row Side Airbag with Head Protection|Safety|
|Second Row Sound Controls|Entertainment|
|Individual Climate Controls|Comfort|
|Side Head Curtain Airbag|Safety|
|Skid Plate|Feature|
|Sliding Rear Pickup Truck Window|Feature|
|Splash Guards|Feature|
|Standard GVWR|Weight|
|Standard Payload|Weight|
|Standard Seating|Seating|
|Standard Towing|Weight|
|Steel Wheels|Wheels and Tires|
|Steering Type|Suspension|
|Steering Wheel Mounted Controls|Feature|
|Subwoofer|Entertainment|
|Tachometer|Feature|
|Fuel Tank||
|Telematics System|Entertainment|
|Telescopic Steering Column|Feature|
|Third Row Removable Seat|Seating|
|Tilt Steering|Feature|
|Tilt Steering Column|Feature|
|Tire Pressure Monitor||
|Tires|Wheels and Tires|
|Tow Hitch Receiver|Feature|
|Towing Preparation Package||
|Track Front|Dimensions|
|Track Rear|Dimensions|
|Traction Control|Drivetrain|
|Transmission (long)|Drivetrain|
|Transmission (short)|Drivetrain|
|Trim Level|Basic|
|Trip Computer|Feature|
|Trunk Anti-Trap Device|Safety|
|Turning Diameter|Dimensions|
|Unknown||
|Vehicle Anti-Theft|Safety|
|Vehicle Stability Control System|Drivetrain|
|Voice Activated Telephone|Entertainment|
|Wheelbase|Dimensions|
|Width at Wall|Dimensions|
|Width at Wheelwell|Dimensions|
|Wind Deflector for Convertibles|Feature|

### `Group` Names

|Groups|
|------|
|Basic|
|Braking|
|Colors|
|Comfort|
|Dimensions|
|Drivetrain|
|Entertainment|
|Feature|
|Interior|
|Safety|
|Seating|
|Security|
|Suspension|
|Warranty|
|Weight|
|Wheels and Tires|
