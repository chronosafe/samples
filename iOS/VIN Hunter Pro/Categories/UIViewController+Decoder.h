//
// Created by chronosafe on 12/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Vehicle;
@class CHRVehicleDescription;

@interface UIViewController (Decoder)

-(void)decodeVIN:(NSString *)vin success:(void (^)(Vehicle * vehicle))success failure:(void (^)(NSString * error))failure;
-(Vehicle *)saveVehicle:(CHRVehicleDescription *)vehicleDescription forVIN:(NSString *) vin withContext:(NSManagedObjectContext *)context;

@end