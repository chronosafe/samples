//
//  Vehicle.h
//  VINHunterPro
//
//  Created by Richard Brown on 12/23/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Vehicle : NSManagedObject

@property (nonatomic, retain) NSString * carfaxData;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * locationLat;
@property (nonatomic, retain) NSNumber * locationLong;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * mileage;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * nadaAuctionData;
@property (nonatomic, retain) NSString * nadaData;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * styleId;
@property (nonatomic, retain) NSString * trans;
@property (nonatomic, retain) NSString * trim;
@property (nonatomic, retain) NSString * trimName;
@property (nonatomic, retain) NSString * vin;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSString *carfaxUrl;
@property (nonatomic, retain) NSString *intColor;
@property (nonatomic, retain) NSNumber *sample;
// NADA values
@property (nonatomic) NSString *msrp;
@property (nonatomic) NSString *nadaLoan;
@property (nonatomic) NSString *nadaRetail;
@property (nonatomic) NSString *nadaTradeIn;
@property (nonatomic) NSString *nadaTradeInAverage;
@property (nonatomic) NSString *nadaTradeInRough;

@end

@interface Vehicle (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
