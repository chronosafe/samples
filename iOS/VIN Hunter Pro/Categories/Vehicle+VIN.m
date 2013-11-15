//
//  Vehicle+VIN.m
//  VINHunterPro
//
//  Created by Richard Brown on 12/23/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "Vehicle+VIN.h"
#import "Vehicle.h"
#import "RestKit.h"
#import "CHRVehicleDescription.h"
#import "CHRStyle.h"
#import "CHRHelper.h"
#import "Photo.h"
#import "AppDelegate.h"
#import "RKObjectMappingOperationDataSource.h"
#import "NSArray+objectsAccessors.h"
#import "CHRStockImage.h"


@implementation Vehicle (VIN)

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@ %@ %@", self.year, self.make, self.model, self.trim == nil ? @"" : self.trim];
}

- (NSString *)fullNameWOTrim {
    return [NSString stringWithFormat:@"%@ %@ %@", self.year, self.make, self.model];
}

+ (BOOL)validate:(NSString *)vin {
	int pos = 0;
	int total = 0;
	int wf[] = { 8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2};
	if (vin.length != 17)
		return false;
    
    vin = [vin uppercaseString];
    
    for (unsigned int x = 0; x < 17; x++)
    {
        if (x != 8)
        {
            unichar posChar = [vin characterAtIndex:x];
            switch (posChar)
            {
                case 'A': pos = 1; break;
                case 'B': pos = 2; break;
                case 'C': pos = 3; break;
                case 'D': pos = 4; break;
                case 'E': pos = 5; break;
                case 'F': pos = 6; break;
                case 'G': pos = 7; break;
                case 'H': pos = 8; break;
                case 'J': pos = 1; break;
                case 'K': pos = 2; break;
                case 'L': pos = 3; break;
                case 'M': pos = 4; break;
                case 'N': pos = 5; break;
                case 'P': pos = 7; break;
                case 'R': pos = 9; break;
                case 'S': pos = 2; break;
                case 'T': pos = 3; break;
                case 'U': pos = 4; break;
                case 'V': pos = 5; break;
                case 'W': pos = 6; break;
                case 'X': pos = 7; break;
                case 'Y': pos = 8; break;
                case 'Z': pos = 9; break;
                case '0':  pos = 0; break;
                case '1':  pos = 1; break;
                case '2':  pos = 2; break;
                case '3':  pos = 3; break;
                case '4':  pos = 4; break;
                case '5':  pos = 5; break;
                case '6':  pos = 6; break;
                case '7':  pos = 7; break;
                case '8':  pos = 8; break;
                case '9':  pos = 9; break;
                default: pos = 0;
            }
            pos = pos * wf[x];
            total += pos;
        }
    }
    
    int div = total % 11;
    unichar check = div == 10 ? 'X' : (unichar)(div + '0');
    
    return check == [vin characterAtIndex:8] ? YES : NO;
}

+(void)decodeVehicle:(Vehicle *)vehicle success:(void (^)(Vehicle *vdata))success failure:(void (^)(NSString *error))failure {
    RKObjectManager* man = [CHRVehicleDescription setupForVIN:vehicle.vin];
    CHRVehicleDescription __block *vehicleDescription;
    
    [man getObjectsAtPath:[CHRVehicleDescription urlForVIN:vehicle.vin withFormat:@"xml"] parameters:nil
                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                      
                      vehicleDescription = [mappingResult firstObject];
                      NSString *string = [[operation HTTPRequestOperation] responseString];
                      vehicle.data = string; // Save the xml for later
                      // Save the data from the Description to the Vehicle class
                      //vehicle.createdDate = [NSDate date];
                      //vehicle.data = vehicleDescription.data;
                      vehicle.year = vehicleDescription.year;
                      vehicle.make = vehicleDescription.make;
                      vehicle.model = vehicleDescription.model;
                      vehicle.trim = vehicleDescription.trim ? vehicleDescription.trim : @"";
                      CHRStyle *style = [vehicleDescription.styles first];
                      
                      if ([vehicleDescription.styles count] == 1) {
                          
                          vehicle.styleId = @(style.styleId);
                          vehicle.trimName = style.name;
                      }
                      
                      // Save the context.
                      NSError *error = nil;
                      if (![vehicle.managedObjectContext save:&error]) {
                          // Replace this implementation with code to handle the error appropriately.
                          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                          NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                          abort();
                      }

                      if (vehicle.data) {
                          if (success)
                              success(vehicle);
                      } else {
                          if (failure)
                              failure(NSLocalizedString(@"Unable to decode vehicle.", @"Unable to decode vehicle."));
                      }
                  }
                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure([NSString stringWithFormat:@"Unable to decode VIN.  Please verify the VIN %@ is for the North American market.", vehicle.vin]);
                  }
     ];
}

+(void)decodeVIN:(NSString *)vin success:(void (^)(Vehicle * vehicle))success failure:(void (^)(NSString * error))failure {
    
    RKObjectManager* man = [CHRVehicleDescription setupForVIN:vin];
    CHRVehicleDescription __block *vehicle;
    
    [man getObjectsAtPath:[CHRVehicleDescription urlForVIN:vin withFormat:@"xml"] parameters:nil
                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                      
                      vehicle = [mappingResult firstObject];
                      NSString *string = [[operation HTTPRequestOperation] responseString];
                      vehicle.data = string; // Save the xml for later
                      Vehicle *v = [self saveVehicle:vehicle
                                              forVIN:vin
                                         withContext:[[AppDelegate sharedDelegate] managedObjectContext]];
                      if (v) {
                          if (success)
                              success(v);
                      } else {
                          if (failure)
                              failure(NSLocalizedString(@"Unable to decode vehicle.", @"Unable to decode vehicle."));
                      }
                  }
                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure([NSString stringWithFormat:@"Unable to decode VIN.  Please verify the VIN %@ is for the North American market.", vin]);
                  }
     ];
}

//+(Vehicle *)saveVehicle:(CHRVehicleDescription *)vehicleDescription forVIN:(NSString *) vin {
//    Vehicle *vehicle = [Vehicle newRecord];
//    // Save the data from the Description to the Vehicle class
//    vehicle.vin = vin;
//    vehicle.data = vehicleDescription.data;
//    vehicle.year = vehicleDescription.year;
//    vehicle.make = vehicleDescription.make;
//    vehicle.model = vehicleDescription.model;
//    vehicle.trim = vehicleDescription.trim ? vehicleDescription.trim : @"";
//    CHRStyle *style = [vehicleDescription.styles first];
//    
//    if ([vehicleDescription.styles count] == 1) {
//        
//        vehicle.styleId = @(style.styleId);
//        vehicle.trimName = style.name;
//    }
//    
//    if (![vehicle save])   {
//        [CHRHelper showAlertWithTitle:NSLocalizedString(@"Error Saving Vehicle", @"Error Saving Vehicle")
//                           andMessage:NSLocalizedString(@"errorSavingVehicle", @"There was an error saving the vehicle record")];
//    } else {
//        if (vehicleDescription.stockPhoto != nil && vehicleDescription.stockPhoto.url)
//        {
//            Photo *photo = [Photo newRecord];
//            photo.url = vehicleDescription.stockPhoto.url;
//            photo.stockPhoto = @1;
//            photo.selected = @1;
//            photo.image = nil;
//            if ([photo save]) {
//                NSLog(@"Photo Saved %@", photo);
//            }
//            [vehicle addPhoto:photo];
//            return vehicle;
//        }
//    }
//    
//    return nil;
//}

+(Vehicle *)saveVehicle:(CHRVehicleDescription *)vehicleDescription forVIN:(NSString *) vin withContext:(NSManagedObjectContext *)context {
    
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
        vehicle.trimName = style.name;
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
            //[vehicle addPhotosObject:photo];
            
            //[vehicle insertObject:photo inPhotosAtIndex:0];
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
        } else {
            // There is no stock image with this vehicle, so just return the vehicle object.
            return vehicle;
        }
    }
    
    return nil;
}

- (NSDate *)dayCreated
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Fix the rare situation where the date is nil
    if (!self.createdDate) {
        NSLog(@"Date was nil, fixed.");
        self.createdDate = [NSDate date];
        [self.managedObjectContext save:nil];
    }
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.createdDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

// Return the date string for the created date
- (NSString *)dayCreatedString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    if (self.createdDate) {
        return [formatter stringFromDate:self.createdDate];

    } else
        return [formatter stringFromDate:[NSDate date]];
    }


// Convert the set into an array
- (NSArray *)imageArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.photos count]];
    for (Photo *photo in self.photos) {
        [array addObject:photo];
    }
    return array;
}

- (Photo *)defaultPhoto {
    for (Photo *photo in self.photos) {
        if (photo.selected.boolValue) {
            return photo;
        }
    }
    // If there are any photos and none are selected then return the first one
    if ([self.photos count] > 0) {
        return self.photos.allObjects.first;
    }
    // If there are no photos then return nil
    return nil;
}

// Clear the selected flag of all photos
- (void)clearDefault {
    for (Photo *photo in self.photos) {
        if (photo.selected.boolValue) {
            photo.selected = @NO;
            [photo.managedObjectContext save:nil];
        }
    }
}

- (NSString *)stockPhotoUrl {
    CHRVehicleDescription *desc = [CHRVehicleDescription vehicleForXML:[self data]];
    if ([[desc stockPhoto] url]) {
        return [[desc stockPhoto] url];
    }
    return @"";
}


- (NSString *)toHTML {
    return [NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td></tr>", self.fullName, self.vin];
}
@end
