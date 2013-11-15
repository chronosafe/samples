//
//  CHRVehicleDescription.h
//  VINTest
//
//  Created by Richard Brown on 12/4/12.
//  Copyright (c) 2012 Richard Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class CHRResponseStatus;
@class CHRValue;
@class CHRRestraintType;
@class CHRHighLow;
@class CHRVINDescription;
@class CHRBasePrice;
@class CHRStockImage;

@interface CHRVehicleDescription : NSObject

@property (nonatomic) NSString *year;
@property (nonatomic) NSString *model;
@property (nonatomic) NSString *make;
@property (nonatomic) NSString *style;
@property (nonatomic) NSString *trim;

@property (nonatomic) CHRResponseStatus *status;
@property (nonatomic) CHRVINDescription *vinDescription;
@property (nonatomic) NSArray *styles;
@property (nonatomic) NSArray *engines;
@property (nonatomic) NSArray *standards;
@property (nonatomic) NSArray *generics;
@property (nonatomic) CHRBasePrice *basePrice;
@property (nonatomic) NSArray *techSpecs;
@property (nonatomic) NSArray *factoryOptions;
@property (nonatomic) NSString *data;

+ (RKObjectMapping *)vehicleMapping;

+ (RKObjectManager *)setupForVIN:(NSString *)vin;

+ (NSString *)urlForVIN:(NSString *)vin withFormat:(NSString *)format;

+ (NSString *)hashKeyForVIN:(NSString *)vin;

- (NSString *)fullName;

- (CHRStockImage *)stockPhoto;

+ (CHRVehicleDescription *)vehicleForXML:(NSString *)xml;


@end
