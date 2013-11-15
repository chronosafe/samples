//
//  Vehicle+VIN.h
//  VINHunterPro
//
//  Created by Richard Brown on 12/23/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "Vehicle.h"
#import "CHRVehicleDescription.h"

@interface Vehicle (VIN)

// Return the full name of the vehicle
- (NSString *)fullName;

// Return the name of the vehicle, minus trim
- (NSString *)fullNameWOTrim;

// Validate the checksum digit of the VIN
+ (BOOL)validate:(NSString *)vin;

// Decode the VIN by calling the web service, execute completion blocks when done
+ (void)decodeVIN:(NSString *)vin success:(void (^)(Vehicle *vehicle))success failure:(void (^)(NSString *error))failure;

// Have a vehicle with no data (from migration)?  This will populate the object
// Call this before pushing the detailed view controller
+(void)decodeVehicle:(Vehicle *)vehicle success:(void (^)(Vehicle *))success failure:(void (^)(NSString *))failure;

//+ (Vehicle *)saveVehicle:(CHRVehicleDescription *)vehicleDescription forVIN:(NSString *)vin;
- (NSDate *)dayCreated;
- (NSString *)dayCreatedString;

- (NSArray *)imageArray;
- (Photo *)defaultPhoto;
- (void)clearDefault;
- (NSString *)stockPhotoUrl;
- (NSString *)toHTML;

@end
