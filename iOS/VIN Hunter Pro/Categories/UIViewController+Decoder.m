//
// Created by chronosafe on 12/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIViewController+Decoder.h"
#import "AppDelegate.h"
#import "CHRHelper.h"
#import "NSArray+objectsAccessors.h"
#import "CHRStyle.h"
#import "Photo.h"
#import "Vehicle.h"
#import "CHRVehicleDescription.h"
#import "ZAActivityBar.h"
#import "MGScrollView.h"
#import "AppDelegate.h"

@implementation UIViewController (Decoder)



-(void)decodeVIN:(NSString *)vin success:(void (^)(Vehicle * vehicle))success failure:(void (^)(NSString * error))failure {

    [ZAActivityBar showWithStatus:[NSString stringWithFormat:@"Decoding VIN %@", vin]];

    RKObjectManager* man = [CHRVehicleDescription setupForVIN:vin];
    CHRVehicleDescription __block *vehicle;

    [man getObjectsAtPath:[CHRVehicleDescription urlForVIN:vin withFormat:@"xml"] parameters:nil
                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                      vehicle = [mappingResult firstObject];
                      NSString *string = [[operation HTTPRequestOperation] responseString];

                      vehicle.data = string; // Save the xml for later
                      Vehicle *v = [self saveVehicle:vehicle forVIN:vin withContext:[[AppDelegate sharedDelegate] managedObjectContext]];
                      if (v) {
                          success(v);
                      } else {
                          failure(NSLocalizedString(@"Unable to decode vehicle.", @"Unable to decode vehicle."));
                      }


                  }
                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      failure([error localizedDescription]);
                  }];

}

-(Vehicle *)saveVehicle:(CHRVehicleDescription *)vehicleDescription forVIN:(NSString *) vin withContext:(NSManagedObjectContext *)context {
    
    //AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    //Vehicle *vehicle = [Vehicle newRecord];
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vehicle" inManagedObjectContext:context];
    Vehicle *vehicle = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    //[vehicle setValue:[NSDate date] forKey:@"timeStamp"];
    

    // Save the data from the Description to the Vehicle class
    vehicle.vin = vin;
    vehicle.createdDate = [NSDate date];
    vehicle.data = vehicleDescription.data;
    vehicle.year = vehicleDescription.year;
    vehicle.make = vehicleDescription.make;
    vehicle.model = vehicleDescription.model;
    vehicle.trim = vehicleDescription.trim ? vehicleDescription.trim : @"";
    CHRStyle *style = [vehicleDescription.styles first];

    if ([vehicleDescription.styles count] == 1) {

        vehicle.styleId = @(style.styleId);
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    if (error)   {
        [CHRHelper showAlertWithTitle:NSLocalizedString(@"Error Saving Vehicle", @"Error Saving Vehicle")
                           andMessage:NSLocalizedString(@"errorSavingVehicle", @"There was an error saving the vehicle record")];
    } else {
        if (vehicleDescription.stockPhoto != nil && vehicleDescription.stockPhoto.url)
        {
            //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.url = vehicleDescription.stockPhoto.url;
            photo.stockPhoto = @1;
            photo.selected = @1;
            photo.image = nil;
            [vehicle addPhotosObject:photo];
            NSError *error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            if (!error) {
                NSLog(@"Photo Saved %@", photo);
            }

            return vehicle;
        }
    }

    return nil;
}

@end