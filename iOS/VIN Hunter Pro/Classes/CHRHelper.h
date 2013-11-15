//
//  CHRHelper.h
//  VINTest
//
//  Created by Richard Brown on 12/4/12.
//  Copyright (c) 2012 Richard Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ZAActivityBar.h"

@interface CHRHelper : NSObject

+(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

+(BOOL)isTall;

+(NSArray *)colors;
+(UIColor *)colorForName:(NSString *)color;
+(NSString *)descriptionForCode:(NSString *)code;
+(NSString *)inputMode;
+(void)setInputMode:(NSString *)mode;

// User methods
+(void)refreshUserWithCompletion:(void (^)(BOOL success))completion;
+(void)require:(NSString *)required;
+(void)presentLogin;

// Account status
+(BOOL)accountIsEnabled;
+(BOOL)isNADA;
+(BOOL)isBasic;
+(PFUser *)currentUser;
+(NSDictionary *)carfaxAccount;
+(NSDictionary *)vinHunterAccount;
+(BOOL)isCompAccount;
+(BOOL)isVINHunterSubscription;
+(BOOL)isiTunesSubscription;
+(void)refreshStoreKitSubscriptionWithCompletion:(void (^)(BOOL success))completion;
+(void)refreshVINHunterSubscriptionWithCompletion:(void (^)(BOOL success))completion;

// CARFAX
+(BOOL)carfaxLoggedIn;
+(BOOL)carfaxAutoBuy;
// Subscriptions
+(NSString *)subscriptionType;
+(BOOL)isValidSubscription;
+(NSString *)userSubscription;
+(BOOL)isLifetimeSubscription;

+(BOOL)internetIsAvailable:(NSString *)failed isSilent:(BOOL)silent;
+(BOOL)isEstimatedMilage:(NSString *)mileage;

// Toast!
+(void)toastShow:(NSString *)message;
+(void)toastSuccess:(NSString *)message;
+(void)toastFail:(NSString *)message;
+(void)toastDismiss;

+(BOOL)notifyUser;
+(PFObject *)systemConfig;
+(BOOL)localSubscribe;

@end
