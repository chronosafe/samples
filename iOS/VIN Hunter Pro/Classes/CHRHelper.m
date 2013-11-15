//
//  CHRHelper.m
//  VINTest
//
//  Created by Richard Brown on 12/4/12.
//  Copyright (c) 2012 Richard Brown. All rights reserved.
//

#import "CHRHelper.h"
#import "WCAlertView.h"
#import "CHRLoginViewController.h"
#import "AppDelegate.h"
#import "CHRSubscriptionHandler.h"

#define kVHActive @"ACTIVE"
#define kVHInactive @"INACTIVE"
#define kRefreshVINHunterUserUrl @"http://chrome.vinhunterpro.com/users/refresh/"

@implementation CHRHelper

+(BOOL)localSubscribe {
    return NO;
}

+ (BOOL)notifyUser {
    NSDate *date = [NSDate date];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [userDefaults valueForKey:kLastNotified];
    if (lastDate == nil)
    {
        [userDefaults setValue:date forKey:kLastNotified];
        [userDefaults synchronize];
        return YES;
    }
    
    NSTimeInterval interval = [date timeIntervalSinceDate:lastDate];
    NSLog(@"interval = %f", interval);
    if (interval < 2.0) {   // Less than 2 seconds from the last nag
        [userDefaults setValue:date forKey:kLastNotified];
        [userDefaults synchronize];
        return NO;
    }
    return YES;
}

// Show an alert formatted with the new style of modal alertbox
+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    if (![self notifyUser])
        return;
    WCAlertView *alertView = [[WCAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
    alertView.style = WCAlertViewStyleBlackHatched;
    [alertView show];

}

// Determine if the device is an iPhone 5
+ (BOOL)isTall {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
        && [UIScreen mainScreen].bounds.size.height == 568)
    {
        return YES;
    }
    return NO;
}

+(NSString *)descriptionForCode:(NSString *)code {
    	NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *errorPath = [path stringByAppendingPathComponent:@"ErrorCode.plist"];
	NSDictionary *errorList = [NSDictionary dictionaryWithContentsOfFile:errorPath];
    NSString *description = [errorList valueForKey:code];
    if ([description length] == 0) {
        return @"";
    }
    else {
        return description;
    }
}

+(UIColor *)colorForName:(NSString *)color {
    for (NSArray *array in [self colors]) {
        NSString *name = [array[0] valueForKey:@"Name"];
        UIColor *colorValue = [array[1] valueForKey:@"Color"];
        if ([name isEqualToString:color]) {
            return colorValue;
        }
    }
    return [UIColor clearColor];
}

// Return an dictionary of color choices
+(NSArray *)colors {
    return @[

    @[@{@"Name" : @"White"},
    @{@"Color" : [UIColor whiteColor]}],
    @[@{@"Name" : @"Black"},
    @{@"Color" : [UIColor blackColor]}],
    @[@{@"Name" : @"Red"},
    @{@"Color" : [UIColor redColor]}],
    @[@{@"Name" : @"Silver"},
    @{@"Color" : [UIColor grayColor]}],
    @[@{@"Name" : @"Green"},
    @{@"Color" : [UIColor colorWithRed: 51.0/255.0
                                 green:170.0/255.0
                                  blue: 51.0/255.0
                                 alpha:1.0]}],
    @[@{@"Name" : @"Orange"},
    @{@"Color" : [UIColor orangeColor]}],
    @[@{@"Name" : @"Yellow"},
    @{@"Color" : [UIColor yellowColor]}],
    @[@{@"Name" : @"Blue"},
    @{@"Color" : [UIColor blueColor]}],
    @[@{@"Name" : @"Brown"},
    @{@"Color" : [UIColor brownColor]}],
    @[@{@"Name" : @"Gray"},
    @{@"Color" : [UIColor grayColor]}],
    @[@{@"Name" : @"Purple"},
    @{@"Color" : [UIColor purpleColor]}],
    @[@{@"Name" : @"Other"},
    @{@"Color" : [UIColor whiteColor]}]

    ];

}

+(NSString *)inputMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mode = [defaults valueForKey:kInputModeKey];
    BOOL hasCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    // Default to scanner unless no camera is present
    if (mode == nil) {
        if (hasCamera) {
            return kInputModeScanner;
        } else {
            return kInputModeKeyboard;
        }
    }
    return mode;
        
}

+(void)setInputMode:(NSString *)mode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:mode forKey:kInputModeKey];
    [defaults synchronize];
}

#pragma - User Helpers

+(void)refreshStoreKitSubscriptionWithCompletion:(void (^)(BOOL success))completion {
    if ([self isiTunesSubscription]) {
        if ([[self currentUser] valueForKey:kpskReceipt]) {
            NSLog(@"Subscription expired, so check to see if there's a new receipt");
            [[CHRSubscriptionHandler sharedManager] processReceipt:[[self currentUser] valueForKey:kpskReceipt] withCompletion:^(BOOL success) {
                if (!success) {
                    // Failure in finding a valid subscription
                    [[CHRHelper currentUser] setValue:@NO forKey:kpisEnabled];
                    [[CHRHelper currentUser] saveInBackground];
                }
             if (completion) {
                 completion(YES);
             }
            }];
        }
    } else { // Wasn't a StoreKit subscription
        if (completion) {
            completion(NO);
        }
    }

}

// Reload the VIN Hunter user data and check for expiration of subscription
+(void)refreshVINHunterSubscriptionWithCompletion:(void (^)(BOOL success))completion {
    if ([self isVINHunterSubscription]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [kRefreshVINHunterUserUrl stringByAppendingString:[[CHRHelper currentUser] username]];
            NSURL *url = [NSURL URLWithString:path];
            NSError *error;
            NSString *result = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
            if ([result isEqualToString:kVHActive]) {
                if (completion) {
                    [[CHRHelper currentUser] refresh];
                    completion(YES);
                }
            } else {
                // Not an active account or an error
                // TODO: Handle the error?
                if (completion) {
                    completion(NO);
                }
            }
        });
    } else {
        // Not a VIN Hunter subscription
        if (completion) {
            completion(NO);
        }
    }
}

// Reload the iTunes user data and check for expiration of subscription
+(void)refreshUserWithCompletion:(void (^)(BOOL success))completion  {
    if ([self currentUser]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self currentUser] refresh];
            // If the subscription is expired (invalid) and from Apple, then try to restore the subscription (renew)
            
            if (![CHRHelper isValidSubscription] || [CHRHelper isLifetimeSubscription]) {
                if ([CHRHelper isVINHunterSubscription]) {
                    // VIN Hunter subscription
                    [self refreshVINHunterSubscriptionWithCompletion:^(BOOL success) {
                        if (completion) {
                            completion(success);
                        }
                    }];
                } else {
                    // iTunes subscription
                    [self refreshStoreKitSubscriptionWithCompletion:^(BOOL success) {
                        if (completion) {
                            completion(success);
                        }
                    }];
                }
            } else {
                // Subscription is valid so no need to refresh
                if (completion) {
                    completion(YES);
                }
            }
        });
    } else {
        // No current user, so no need to refresh
        if (completion) {
            completion(NO); // Call the completion block
        }
    }
}

+(PFUser *)currentUser {
    return [PFUser currentUser];
}

+(PFObject *)systemConfig {
    return nil;
}

+(NSString *)userSubscription {
    return ([self currentUser]) ? ([[self currentUser] valueForKey:kSubscription]) : nil;
}

+(NSString *)subscriptionType {
    return ([self currentUser]) ? ([[self currentUser] valueForKey:kSubscriptionType]) : nil;
}

// Conditions for being valid:
// 0. User exists
// 1. Not expired
// 2. Valid subscription type
// 3. Account is enabled
// 4. is an NADA or Basic subscription type
//
+(BOOL)isValidSubscription {
    if (![self currentUser]) { // Always invalid when not logged in
        return NO;
    }
    BOOL lifetime = [CHRHelper isLifetimeSubscription];
    NSDate *expirationDate = [[self currentUser] valueForKey:kpExpiresOn];
    BOOL expired = [expirationDate compare:[NSDate date]] == NSOrderedAscending;
    return ((!expired || lifetime) && [self subscriptionType] != nil && [self accountIsEnabled] && ([self isBasic] || [self isNADA]));
}

+(void)presentLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPresentLogin" object:nil];
}

+(BOOL)accountIsEnabled {
    PFUser *user = [PFUser currentUser];
    BOOL enabled = [[user valueForKey:kpisEnabled] boolValue];
    return enabled;
}

+ (BOOL)isBasic {
    return [[self userSubscription] isEqualToString:kBasicSubscription];
}

+ (BOOL)isCompAccount {
    return [[self subscriptionType] isEqualToString:kSubTypeComp];
}

+ (BOOL)isiTunesSubscription {
    return [[self subscriptionType] isEqualToString:kSubTypeiTunes];
}

+ (BOOL)isLifetimeSubscription {
    if ([self isVINHunterSubscription]) {
        if ([[[self currentUser] valueForKey:kLifeTimeSubscription] boolValue]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isVINHunterSubscription {
    return [[self subscriptionType] isEqualToString:kSubTypeVINHunter];
}

+ (void)require: (NSString *)required {
    if ([self currentUser]) {
        [self showAlertWithTitle:@"Access Restricted"
                      andMessage:required];
    } else {
        [self showAlertWithTitle:@"Login Required"
                      andMessage:@"Please login to your VIN Hunter account to access serviecs."];
    }
}

+ (BOOL)carfaxLoggedIn {
    if (![self currentUser])
        return NO;
    if ([[self currentUser] valueForKey:@"carfaxUsername"] && [[self currentUser] valueForKey:@"carfaxPassword"])
        return YES;
    return NO;
}

+(BOOL)carfaxAutoBuy {
    if ([self carfaxLoggedIn] && [[[self currentUser] valueForKey:@"carfaxAutoBuy"] boolValue])
        return YES;
    return NO;
}

+(NSDictionary *)carfaxAccount {
    if ([self carfaxLoggedIn]) {
        NSString *username = [[self currentUser] valueForKey:@"carfaxUsername"];
        NSString *password = [[self currentUser] valueForKey:@"carfaxPassword"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[username, password] forKeys:@[@"username", @"password"]];
        return dict;
    }
    return nil;
}

+(NSDictionary *)vinHunterAccount {
    if ([self currentUser]) {
        NSString *username = [[self currentUser] valueForKey:@"username"];
        NSString *password = [[self currentUser] valueForKey:@"password"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[username, password] forKeys:@[@"username", @"password"]];
        return dict;
    }
    return nil;
}

+ (BOOL)isNADA {
    return [[self userSubscription] isEqualToString:kNADASubscription];
}

+(BOOL)internetIsAvailable:(NSString *)failed isSilent:(BOOL)silent {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    if ([appDelegate internetIsAvailable]) {
        return YES;
    } else {
        if (!failed) {
            failed = NSLocalizedString(@"serviceUnavailbleMessage",
            @"Service is unavailable because of the lack on Internet access.  Please check your connectivity.");
        }
        if (!silent) {
            [self showAlertWithTitle:@"Connectivity Lost" andMessage:failed];
        }
        return NO;
    }
}

+(BOOL)isEstimatedMilage:(NSString *)mileage {
    NSMutableArray *miles = [[NSMutableArray alloc] init];
    mileage = [mileage stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSNumber * m = @([mileage integerValue]);
    miles = [[NSMutableArray alloc] init];
    unsigned int i = 0;
    
    for (i=0; i<21; i++) {
        [miles insertObject:@(i * 5000) atIndex:i];
    }
    for (i=1; i<6; i++) {
        [miles insertObject:@(i * 10000 + 100000) atIndex:20+i];
    }
    if ([miles containsObject:m]) {
        return YES;
    }
    return NO;
}

#pragma mark - Toast!
// Toast!
+(void)toastShow:(NSString *)message {
    [ZAActivityBar showWithStatus:message];
}

+(void)toastSuccess:(NSString *)message {
    [ZAActivityBar showSuccessWithStatus:message];
}

+(void)toastFail:(NSString *)message {
    [ZAActivityBar showErrorWithStatus:message];
}

+(void)toastDismiss {
    [ZAActivityBar dismiss];
}

@end
