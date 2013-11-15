//
//  CHRVehicleDescription.m
//  VINTest
//
//  Created by Richard Brown on 12/4/12.
//  Copyright (c) 2012 Richard Brown. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "CHRVehicleDescription.h"
#import "CHRVINDescription.h"
#import "CHRBasePrice.h"
#import "CHRStyle.h"
#import "CHRHighLow.h"
#import "CHRRestraintType.h"
#import "CHRResponseStatus.h"
#import "CHRPrimaryValue.h"
#import "CHREngine.h"
#import "CHRFuelEconomy.h"
#import "CHRStandard.h"
#import "CHRGenericEquipment.h"
#import "CHRTechSpecs.h"
#import "CHRFactoryOption.h"
#import "CHRStyleValue.h"
#import "CHREngineSpec.h"
#import "CHRInstalled.h"
#import "CHRRange.h"
#import "CHRTechValue.h"
#import "CHROptionPrice.h"
#import "NSArray+objectsAccessors.h"
#import "CHRStockImage.h"
#import "RKObjectMappingOperationDataSource.h"

@implementation CHRVehicleDescription

// This dumps to NSLogs instead of to the returned value because I want to maintain format.  This should only
// be called when debugging.

-(NSString *)description {
    NSLog(@"Vehicle: %@ %@ %@ (%@)", self.year, self.make, self.model, self.style);
    NSLog(@"Status: %@/%@", self.status.responseCode, self.status.description);
    NSLog(@"VINDescription: %@ %@ %@ %@",self.vinDescription.year, self.vinDescription.division, self.vinDescription.model, self.vinDescription.style);
    NSLog(@"VINDescription: %@ %@", self.vinDescription.bodyType, self.vinDescription.drivingWheels);
    NSLog(@"Restraints: %d", [self.vinDescription.restraintTypes count]);
    for (CHRRestraintType *r in self.vinDescription.restraintTypes) {
        NSLog(@"  header: (%d) %@ group: (%d) %@ category: (%d) %@", r.header.objId, r.header.value, r.group.objId, r.group.value, r.category.objId, r.category.value);
    }
    NSLog(@"Market Class: %@", self.vinDescription.marketClass.value);
    NSLog(@"GVWR: High: %@ Low: %@", self.vinDescription.gvwr.high, self.vinDescription.gvwr.low);
    NSLog(@"Manufacturer Country: %@", self.vinDescription.manufacturer.value);
    NSLog(@"Styles: %d", [self.styles count]);

    NSInteger x __attribute__((unused)) = 1;
    for (CHRStyle *style in self.styles) {
        NSLog(@"  Style #: %d", x++);
        NSLog(@"  id:%d yr:%@ name:%@ nameWOT:%@", style.styleId, style.year, style.name, style.nameWoTrim);
        NSLog(@"  code: %@ fo: %@ mf: %@", style.mfrModelCode, style.fleetOnly, style.modelFleet);
        NSLog(@"  division: %@", style.division.value);
        NSLog(@"  subdivision: %@", style.subdivision.value);
        NSLog(@"  model: %@", style.model.value);
        NSLog(@"  basePrice: (%@) %@, %@, %@", style.basePrice.unknown, style.basePrice.invoice, style.basePrice.msrp, style.basePrice.destination);
        NSLog(@"  drivetrain: %@", style.drivetrain);
        NSLog(@"  BodyTypes: %d", [style.bodyTypes count]);
        for (CHRPrimaryValue *body in style.bodyTypes) {
            NSLog(@"    primary: %@, %@", body.primary, body.value);
        }
        NSLog(@"  marketClass: %@", style.marketClass.value);
        NSLog(@"  stockPhoto: %@", style.stockImage);
        NSLog(@" ");
    }
    NSLog(@"Engines: %d", [self.engines count]);
    for (CHREngine *engine in self.engines) {
        NSLog(@"  HO: %@ Cyl: %@", engine.highOutput, engine.cylinders.value);
        NSLog(@"  Fuel Type: %@", engine.fuelType);
        NSLog(@"  HP: %@", engine.horsepower);
        NSLog(@"  Torque: %@", engine.netTorque);
        NSLog(@"  Displacement: %@", engine.displacement);
        NSLog(@"  fuelEconomy: (%@)", engine.fuelEconomy.unit);
        NSLog(@"    City: %@", engine.fuelEconomy.city);
        NSLog(@"    HWY: %@", engine.fuelEconomy.hwy);
        NSLog(@"  fuelCapacity: %@", engine.fuelCapacity);
        NSLog(@"  installed: %@", engine.installed);
    }
    NSLog(@"Standards: %d", [self.standards count]);
    for (CHRStandard *std in self.standards)  {
        NSLog(@"  S: %@", std);
    }
    NSLog(@"Generic Equipment: %d", [self.generics count]);
    for (CHRGenericEquipment *generic in self.generics) {
        NSLog(@"  G: %@", generic);
    }
    NSLog(@"TechSpecs: %d", [self.techSpecs count]);
    for (CHRTechSpecs *tech in self.techSpecs) {
        NSLog(@"  T: %@", tech);
        for (CHRTechValue *value in tech.values) {
            NSLog(@"    Values: %@", value);
        }

    }
    NSLog(@"Factory Options: %d", [self.factoryOptions count]);
    for (CHRFactoryOption *option in self.factoryOptions) {
        NSLog(@"  O: %@", option);
    }
    NSLog(@"Base Price: %@", self.basePrice);
    return [NSString stringWithFormat:@"%@ %@ %@", self.year, self.make, self.model];
}

+(RKObjectMapping *)vehicleMapping {
#pragma mark - Main Vehicle Mapping
    // Main vehicle mapping
    
    RKObjectMapping *vehicleDesc = [RKObjectMapping mappingForClass:[CHRVehicleDescription class]];
    
    [vehicleDesc addAttributeMappingsFromDictionary:@{
     @"modelYear"      : @"year",
     @"bestMakeName"   : @"make",
     @"bestModelName"  : @"model",
     @"bestStyleName"  : @"style",
     @"bestTrimName"   : @"trim"}];
    
#pragma mark - Common Data Mappings
    // Common data mappings
    
    RKObjectMapping *responseStatusMapping = [RKObjectMapping mappingForClass:[CHRResponseStatus class]];
    [responseStatusMapping addAttributeMappingsFromArray:@[@"responseCode", @"description"]];
    
    RKObjectMapping *highLowMapping = [RKObjectMapping mappingForClass:[CHRHighLow class]];
    [highLowMapping addAttributeMappingsFromArray:@[@"high",@"low",@"unit"]];
    
    RKObjectMapping *valueMapping = [RKObjectMapping mappingForClass:[CHRValue class]];
    [valueMapping addAttributeMappingsFromDictionary:@{@"id" : @"objId", @"text" : @"value"}];
    
    RKObjectMapping *primaryMapping  = [RKObjectMapping mappingForClass:[CHRPrimaryValue class]];
    [primaryMapping addAttributeMappingsFromDictionary:@{@"primary" : @"primary", @"text" : @"value", @"id" : @"objId"}];
    
    RKObjectMapping *priceMapping = [RKObjectMapping mappingForClass:[CHRPrice class]];
    [priceMapping addAttributeMappingsFromArray:@[@"unknown", @"invoice", @"msrp", @"destination"]];
    
    RKObjectMapping *stockPhotoMapping = [RKObjectMapping mappingForClass:[CHRStockImage class]];
    [stockPhotoMapping addAttributeMappingsFromArray:@[@"filename", @"url", @"width", @"height"]];
    
#pragma mark - Restraint Type
    // Restraint Type
    
    RKObjectMapping * restraintTypeMapping = [RKObjectMapping mappingForClass:[CHRRestraintType class]];
    [restraintTypeMapping addRelationshipMappingWithSourceKeyPath:@"category" mapping:valueMapping];
    [restraintTypeMapping addRelationshipMappingWithSourceKeyPath:@"group" mapping:valueMapping];
    [restraintTypeMapping addRelationshipMappingWithSourceKeyPath:@"header" mapping:valueMapping];
    
#pragma mark - VIN Description
    // VIN Description
    
    RKObjectMapping *vinDescriptionMapping = [RKObjectMapping mappingForClass:[CHRVINDescription class]];
    [vinDescriptionMapping addAttributeMappingsFromDictionary:@{
     @"vin"             : @"vin",
     @"modelYear"       : @"year",
     @"division"        : @"division",
     @"modelName"       : @"model",
     @"styleName"       : @"style",
     @"bodyType"        : @"bodyType",
     @"drivingWheels"   : @"drivingWheels"}];
    
#pragma mark - Style
    RKObjectMapping *styleMapping = [RKObjectMapping mappingForClass:[CHRStyle class]];
    [styleMapping addAttributeMappingsFromDictionary:@{
     @"id"              : @"styleId",
     @"modelYear"       : @"year",
     @"name"            : @"name",
     @"mfrModelCode"    : @"mfrModelCode",
     @"nameWoTrim"      : @"nameWoTrim",
     @"fleetOnly"       : @"fleetOnly",
     @"modelFleet"      : @"modelFleet",
     @"passDoors"       : @"passDoors",
     @"altBodyType"     : @"altBodyType",
     @"altStyleName"    : @"altStyleName",
     @"drivetrain"      : @"drivetrain"}];
    
#pragma mark - Status
    RKRelationshipMapping *statusRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"responseStatus" toKeyPath:@"status" withMapping:responseStatusMapping];
    [vehicleDesc addPropertyMapping:statusRelation];
    
    RKObjectMapping *baseValueMapping = [RKObjectMapping mappingForClass:[CHRStyleValue class]];
    [baseValueMapping addAttributeMappingsFromDictionary:@{@"text" : @"value"}];
    
#pragma mark - Vehicle associations
    [vehicleDesc addRelationshipMappingWithSourceKeyPath:@"vinDescription" mapping:vinDescriptionMapping];
    [vinDescriptionMapping addRelationshipMappingWithSourceKeyPath:@"restraintTypes" mapping:restraintTypeMapping];
    [vinDescriptionMapping addRelationshipMappingWithSourceKeyPath:@"marketClass" mapping:valueMapping];
    [vinDescriptionMapping addRelationshipMappingWithSourceKeyPath:@"gvwr" mapping:highLowMapping];
    RKRelationshipMapping *worldRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"WorldManufacturerIdentifier" toKeyPath:@"manufacturer" withMapping:baseValueMapping];
    [vinDescriptionMapping addPropertyMapping:worldRelation];
    RKRelationshipMapping *stylesRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"style" toKeyPath:@"styles" withMapping:styleMapping];
    
    [vehicleDesc addPropertyMapping:stylesRelation];
    
#pragma mark - Style Relationships
    // Style relationships
    
    [styleMapping addRelationshipMappingWithSourceKeyPath:@"division" mapping:valueMapping];
    [styleMapping addRelationshipMappingWithSourceKeyPath:@"subdivision" mapping:valueMapping];
    [styleMapping addRelationshipMappingWithSourceKeyPath:@"model" mapping:valueMapping];
    [styleMapping addRelationshipMappingWithSourceKeyPath:@"basePrice" mapping:priceMapping];
    [styleMapping addRelationshipMappingWithSourceKeyPath:@"marketClass" mapping:valueMapping];
    RKRelationshipMapping *bodyMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"bodyType" toKeyPath:@"bodyTypes" withMapping:primaryMapping];
    [styleMapping addPropertyMapping:bodyMapping];
    [styleMapping addRelationshipMappingWithSourceKeyPath:@"stockImage" mapping:stockPhotoMapping];
    
#pragma mark - Engine mapping
    // Engine mapping
    RKObjectMapping *engineMapping = [RKObjectMapping mappingForClass:[CHREngine class]];
    [engineMapping addAttributeMappingsFromArray:@[@"highOutput"]];
    
#pragma mark - Engine Spec Mapping
    // Engine Spec Mapping
    RKObjectMapping *engineSpecMapping = [RKObjectMapping mappingForClass:[CHREngineSpec class]];
    [engineSpecMapping addAttributeMappingsFromArray:@[@"value", @"rpm", @"liters", @"cubicIn"]];
    
#pragma mark - Installed mapping
    RKObjectMapping *installedMapping = [RKObjectMapping mappingForClass:[CHRInstalled class]];
    [installedMapping addAttributeMappingsFromArray:@[@"cause"]];
    
#pragma mark - Fuel Economy mapping
    // Fuel Economy
    
    RKObjectMapping *fuelEconomyMapping = [RKObjectMapping mappingForClass:[CHRFuelEconomy class]];
    [fuelEconomyMapping addAttributeMappingsFromArray:@[@"unit"]];
    [fuelEconomyMapping addRelationshipMappingWithSourceKeyPath:@"city" mapping:highLowMapping];
    [fuelEconomyMapping addRelationshipMappingWithSourceKeyPath:@"hwy" mapping:highLowMapping];
    
#pragma mark - Engine relationships
    // Engine Relationships
    
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"cylinders" mapping:baseValueMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"engineType" mapping:valueMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"fuelType" mapping:valueMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"horsepower" mapping:engineSpecMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"netTorque" mapping:engineSpecMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"displacement" mapping:engineSpecMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"fuelEconomy" mapping:fuelEconomyMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"fuelCapacity" mapping:highLowMapping];
    [engineMapping addRelationshipMappingWithSourceKeyPath:@"installed" mapping:installedMapping];
    RKRelationshipMapping *engineRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"engine" toKeyPath:@"engines" withMapping:engineMapping];
    [vehicleDesc addPropertyMapping:engineRelation];
    
#pragma mark - Standard mappings
    // Standard
    
    RKObjectMapping *standardMapping = [RKObjectMapping mappingForClass:[CHRStandard class]];
    RKObjectMapping *descMap = [RKObjectMapping mappingForClass:[CHRStyleValue class]];
    [descMap addAttributeMappingsFromDictionary:@{@"text" : @"value"}];
    
    RKRelationshipMapping *catRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"category" toKeyPath:@"categories" withMapping:valueMapping];
    RKRelationshipMapping *styleRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"styleId" toKeyPath:@"styles" withMapping:baseValueMapping];
    RKRelationshipMapping *desc1Relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"description" toKeyPath:@"desc" withMapping:descMap];
    RKRelationshipMapping *standardRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"standard" toKeyPath:@"standards" withMapping:standardMapping];
    
    [standardMapping addRelationshipMappingWithSourceKeyPath:@"header" mapping:valueMapping];
    [standardMapping addRelationshipMappingWithSourceKeyPath:@"installed" mapping:installedMapping];
    [standardMapping addPropertyMappingsFromArray:@[catRelation, styleRelation, desc1Relation]];
    [vehicleDesc addPropertyMapping:standardRelation];
    
#pragma mark - Generic Equipment mapping
    // Generic Equipment
    
    RKObjectMapping *genericMapping = [RKObjectMapping mappingForClass:[CHRGenericEquipment class]];
    
    RKRelationshipMapping *categoryId2Relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"categoryId" toKeyPath:@"categories" withMapping:baseValueMapping];
    RKRelationshipMapping *styleId2Relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"styleId" toKeyPath:@"styles" withMapping:baseValueMapping];
    [genericMapping addRelationshipMappingWithSourceKeyPath:@"installed" mapping:installedMapping];
    [genericMapping addPropertyMappingsFromArray:@[categoryId2Relation, styleId2Relation]];
    RKRelationshipMapping *genericRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"genericEquipment" toKeyPath:@"generics" withMapping:genericMapping];
    
    [vehicleDesc addPropertyMapping:genericRelation];
    
#pragma mark - Base Price mapping
    // Base Price
    
    RKObjectMapping *basePriceMapping = [RKObjectMapping mappingForClass:[CHRBasePrice class]];
    [basePriceMapping addAttributeMappingsFromArray:@[@"unknown"]];
    [basePriceMapping addRelationshipMappingWithSourceKeyPath:@"invoice" mapping:highLowMapping];
    [basePriceMapping addRelationshipMappingWithSourceKeyPath:@"msrp" mapping:highLowMapping];
    [basePriceMapping addRelationshipMappingWithSourceKeyPath:@"destination" mapping:highLowMapping];
    [vehicleDesc addRelationshipMappingWithSourceKeyPath:@"basePrice" mapping:basePriceMapping];
    
#pragma mark - Range mapping
    // Range
    
    RKObjectMapping *rangeMapping = [RKObjectMapping mappingForClass:[CHRRange class]];
    [rangeMapping addAttributeMappingsFromArray:@[@"min", @"max"]];
    
#pragma mark - Tech Value mapping
    // Tech Values
    
    RKObjectMapping *techValueMapping = [RKObjectMapping mappingForClass:[CHRTechValue class]];
    RKRelationshipMapping *techRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"styleId" toKeyPath:@"styles" withMapping:baseValueMapping];
    
    [techValueMapping addPropertyMapping:techRelation];
    [techValueMapping addAttributeMappingsFromArray:@[@"value", @"condition"]];
    
#pragma mark - Tech Specs mapping
    // Tech Specs
    
    RKObjectMapping *techSpecMapping = [RKObjectMapping mappingForClass:[CHRTechSpecs class]];
    [techSpecMapping addRelationshipMappingWithSourceKeyPath:@"titleId" mapping:baseValueMapping];
    [techSpecMapping addRelationshipMappingWithSourceKeyPath:@"range" mapping:rangeMapping];
    RKRelationshipMapping *techvalRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"value" toKeyPath:@"values" withMapping:techValueMapping];
    [techSpecMapping addPropertyMapping:techvalRelation];
    RKRelationshipMapping *techSpecRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"technicalSpecification" toKeyPath:@"techSpecs" withMapping:techSpecMapping];
    [vehicleDesc addPropertyMapping:techSpecRelation];
    
#pragma mark - Factory Option Pricing mapping
    // Factory Option Pricing
    
    RKObjectMapping *factoryPriceMapping = [RKObjectMapping mappingForClass:[CHROptionPrice class]];
    [factoryPriceMapping addAttributeMappingsFromArray:@[@"unknown",@"invoiceMin", @"invoiceMax", @"msrpMin", @"msrpMax"]];
    
#pragma mark - Factory Option mapping
    // Factory Option
    
    RKObjectMapping *factoryOptionMapping = [RKObjectMapping mappingForClass:[CHRFactoryOption class]];
    [factoryOptionMapping addAttributeMappingsFromArray:@[@"chromeCode", @"oemCode", @"standard", @"optionKindId",@"utf", @"fleetOnly"]];
    [factoryOptionMapping addRelationshipMappingWithSourceKeyPath:@"header" mapping:valueMapping];
    RKRelationshipMapping *cat2Relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"category" toKeyPath:@"categories" withMapping:valueMapping];
    RKRelationshipMapping *desc2Relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"description" toKeyPath:@"desc" withMapping:descMap];
    RKRelationshipMapping *style2Relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"styleId" toKeyPath:@"styles" withMapping:baseValueMapping];
    
    [factoryOptionMapping addPropertyMapping:desc2Relation];
    [factoryOptionMapping addPropertyMapping:cat2Relation];
    [factoryOptionMapping addPropertyMapping:style2Relation];
    [factoryOptionMapping addRelationshipMappingWithSourceKeyPath:@"price" mapping:factoryPriceMapping];
    RKRelationshipMapping *factoryRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"factoryOption" toKeyPath:@"factoryOptions" withMapping:factoryOptionMapping];
    [vehicleDesc addPropertyMapping:factoryRelation];
    
    return vehicleDesc;
    
}

- (NSString *)fullName {
   return [NSString stringWithFormat:@"%@ %@ %@ %@", self.year, self.make, self.model, self.trim == nil ? @"" : self.trim];
}

+(RKObjectManager *) setupForVIN:(NSString *)vin {


    // Register mappings
    RKObjectMapping *vehicleMapping = [self vehicleMapping];

    NSString *key = [self hashKeyForVIN:vin];  // Calculate the security key

    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://chrome.vinhunterpro.com"]];

    [client setDefaultHeader:@"key" value:key];
    RKObjectManager *man = [[RKObjectManager alloc] initWithHTTPClient:client];
    RKResponseDescriptor *responder = [RKResponseDescriptor responseDescriptorWithMapping:vehicleMapping pathPattern:nil keyPath:@"VehicleDescription" statusCodes:[NSIndexSet indexSetWithIndex:200]];

    [man addResponseDescriptor:responder];
    return man;
}

+(NSString *)urlForVIN:(NSString *)vin withFormat:(NSString *)format {
    return [NSString stringWithFormat:@"/vehicles/%@.%@", vin, format];
}

// Create a hash for the VIN seeded with a number created by a calculation instead of a string
+(NSString *)hashKeyForVIN: (NSString *)vin {
    vin = [vin uppercaseString];
    long long md = (2993993339 * 39994494 + 2003);
    //NSLog(@"%lld", md);
    const char *cstr = [[NSString stringWithFormat:@"%lld", md] UTF8String];

    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);

    NSString *h = [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
    ];
    //NSLog(@"%@", h);

    const char *vstr = [[vin stringByAppendingString:h] UTF8String];
    //NSLog(@"%s", vstr);

    unsigned char vresult[16];
    CC_MD5(vstr, strlen(vstr), vresult);
    NSString *h2 = [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            vresult[0], vresult[1], vresult[2], vresult[3],
            vresult[4], vresult[5], vresult[6], vresult[7],
            vresult[8], vresult[9], vresult[10], vresult[11],
            vresult[12], vresult[13], vresult[14], vresult[15]
    ];
    //NSLog(@"%@", h2);
    // Return the final md5 hash
    return h2;
}

- (CHRStockImage *)stockPhoto {
    CHRStyle *style = [self.styles first];
    return style.stockImage;
}

// Return a CHRVehicleDescription object from an XML string
+ (CHRVehicleDescription *)vehicleForXML:(NSString *)xml {
    // Make sure a valid xml string is being passed in
    if (!xml)
        return nil;

    NSDictionary * dictionary = [RKMIMETypeSerialization objectFromData:[xml dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"application/xml" error:nil];
    RKMapping *mapping = [CHRVehicleDescription vehicleMapping];

    CHRVehicleDescription *vehicleDescription = [CHRVehicleDescription new];

    RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:dictionary[@"VehicleDescription"]
                                                                   destinationObject:vehicleDescription
                                                                             mapping:mapping];

    RKObjectMappingOperationDataSource *dataSource = [RKObjectMappingOperationDataSource new];
    operation.dataSource = dataSource;
    [operation start];

    return vehicleDescription;
}
@end
