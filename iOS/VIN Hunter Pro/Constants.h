//
// Created by chronosafe on 12/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

// Application Constants

/*
 *  Constants.h
 *  VINHunter
 *
 *  Created by Richard Brown on 3/27/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define kNavbarColor [UIColor colorWithRed:.7 green:.2 blue:.2 alpha:1]
#define kToolbarColor [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1]
//#define kNavbarColor [UIColor colorWithRed:.31 green:.4 blue:.47 alpha:1]
//#define kNavbarColor [UIColor colorWithRed:.05 green:.05 blue:.05 alpha:1]
// Constants for Settings
#define kRecordsPref @"records_preference"
#define kUsernamePref @"username_preference"
#define kPasswordPref @"password_preference"
#define kEMailPref @"email_preference"
#define kKeyclickPref @"keyclick_preference"
#define kKeyboardType @"keyboard_preference"
#define kKeyboardTypeDefault YES
#define kInternetCheckPref @"internet_preference"
#define kDealerPref @"dealer_preference"
#define kCarfaxUsername @"carfax_username"
#define kCarfaxPassword @"carfax_password"
#define kVinHunterUsername @"vh_username"
#define kVinHunterPassword @"vh_password"
#define kCarfaxAutobuy @"carfax_autobuy"

#define kBlackBookDefaultState @"bb_defstate"
#define kNADADefaultRegionKey @"nada_defregion"

#define kWelcomeMessageShown @"welcome_key"


/*
 //#define kBBURL @"http://blackbook.vinhunter.com:8890"
 #define kBBURL @"https://vinhunterpro.heroku.com/report/%@/blackbook"
 //#define kNADAURL @"http://blackbook.vinhunter.com:8890/nada.aspx"
 #define kNADAURL @"https://vinhunterpro.heroku.com/report/%@/nada"
 #define kNADARegionURL @"https://vinhunterpro.heroku.com/report/region/nada"
 #define kNADAURL_DRILLDOWN @"https://vinhunterpro.heroku.com/report/%@/nada_drill"
 #define kBBURL_DRILLDOWN @"https://vinhunterpro.heroku.com/report/%@/bb_drill"
 #define kCCCURL @"http://www.carfax.com/cfm/ccc_displayhistoryrpt.cfm?partner=COS_0&vin=%@"
 #define kMessageCount @"kMesssage_Count"
 #define kMessageURL @"http://blackbook.vinhunter.com:8890/message.aspx"
 */

#define CHUNK 16384

//#define kMessageCount @"kMesssage_Count"
//#define kMessageURL @"https://service.vinhunterpro.com/message/show"

//#define kBBURL @"https://service.vinhunterpro.com/report/%@/blackbook"
//#define kNADAURL @"https://service.vinhunterpro.com/report/%@/nada"
//#define kNADARegionURL @"https://service.vinhunterpro.com/report/region/nada"
//#define kNADAURL_DRILLDOWN @"https://service.vinhunterpro.com/report/%@/nada_drill"
//#define kBBURL_DRILLDOWN @"https://service.vinhunterpro.com/report/%@/bb_drill"
//#define kCCCURL @"http://www.carfax.com/cfm/ccc_displayhistoryrpt.cfm?partner=COS_0&vin=%@"
//#define kAccountCreateURL @"http://service.vinhunterpro.com/user/create_iphone/%@"
/*
#define kCarfaxReportURL @"https://vinhunterpro.heroku.com/report/%@"
#define kCarfaxHistoryURL @"https://vinhunterpro.heroku.com/report/%@/%@/history"
*/

#define kCarfaxReportURL @"http://service.vinhunterpro.com/report/%@"
#define kCarfaxHistoryURL @"http://service.vinhunterpro.com/report/%@/%@/history"
#define kCarfaxEmailReportUrl @"http://www.carfax.com/cfm/ccc_displayhistoryrpt.cfm?partner=COS_0&vin="

#define kNADADefaultRegion 10

//#define kBBVersionURL @"https://service.vinhunterpro.com/report/version/bb"
//#define kNADAVersionURL @"https://service.vinhunterpro.com/report/version/nada"
#define kPartnerBB 2
#define kPartnerNADA 1
#define kPartnerCarfax 3


#define kCarfaxUsernameMissingError @"303"
#define kSecurityAccountError @"400"
#define kSecurityCarfaxError @"401"
#define kSecurityBlackBookError @"402"
#define kSecurityNADAError @"403"
#define kSecurityBlackBookAccessError @"1000"
#define kSecurityNADAAccessError @"1001"
#define kErrorNADAVehicleNotFound @"1002"
#define kErrorBlackBookVehicleNotFound @"1003"
#define kErrorNADASanityAccessory @"2000"
#define kErrorNADASanityExclusive @"2001"
#define kErrorNADASanityInclusive @"2002"
#define kErrorNADASanityVehicle @"2003"
#define kErrorNADASanityPricing @"2004"
#define kErrorNADAMissingRegion @"2005"
#define kErrorNADAMissingVIN @"2006"
#define kErrorNADASanityBasic @"2007"
#define kNADASuccess @"200"

#define kDrillDownVIN @"DRILLDOWN"

#define kInternetConnectivityError @"9999"
#define kEmailConfigurationError @"9998"

//to determine version get a count of the pattern table
//#define kCurrentDatabaseCount 146675 // Version 1
#define kCurrentDatabaseCount 233568 // Release version 1
#define kCurrentDatabaseVersion 1

// NADA Values
#define kNADAMinTradeInFloor 120
#define kNADAMinRetailFloor 420
#define kNADAMinLoanFloor 0
#define kNADAMinBase 900

#define kNADA_ERROR_MissingVIN 400
#define kNADA_ERROR_NoMatch 404
#define kNADA_ERROR_NoRegions 403

#define kSecurityKey @"appSecurityKey"
#define kSecurityAccount @"A"
#define kSecurityCarfax @"C"
#define kSecurityBlackBook @"B"
#define kSecurityNADA @"N"
// device values
#define kSecurityDeviceValid @"D"
#define kSecurityDeviceInvalid @"I"
#define kSecurityDeviceNoMatch @"X"
#define kSecurityDeviceNew @"A"
#define kSecurityBlackBookNoWholesale @"b"

//#define kSecurityURL @"http://blackbook.vinhunter.com:8890/security.aspx?id=%@"
//#define kSecurityURL @"https://service.vinhunterpro.com/user/security/%@/%@"
//#define kAccountWebURL @"https://service.vinhunterpro.com/status/%@/%@"
//#define kUpgradeWebURL @"https://service.vinhunterpro.com/upgrade/%@/%@"
#define kHostName @"www.vinhunter.com"

#define func_AppDelegate AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#define kHelpURL @"http://vinhunterpro.com/home/help"
#define kAppId @"109"

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhone568ImageNamed(image) (isPhone568 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhone568Image(image) ([UIImage imageNamed:iPhone568ImageNamed(image)])

#define kInputModeKey @"kInputModeKey"
#define kInputModeKeyboard @"kInputModeKeyboard"
#define kInputModeScanner @"kInputModeScanner"
#define kInputModeScannerForced @"kInputModeScannerForced"
#define kDefaultPhotoMode @"kDefaultPhotoMode"
#define kBarcodeDefault @"kBarcodeDefault"
#define kLastNotified @"kLastNotified"

#define kCurrentUser [[NSUserDefaults standardUserDefaults] valueForKey:@"vh_username"]

// Parse user object keys
#define kpisEnabled @"isEnabled"
#define kpskReceipt @"skReceipt"
#define kpExpiresOn @"expiresOn"
#define kSubscriptionType @"subType"
#define kSubscription @"Subscription"
#define kLifeTimeSubscription @"lifetime_subscription"

// Subscription types
#define kSubTypeiTunes @"iTunes"
#define kSubTypeVINHunter @"VIN Hunter"
#define kSubTypeComp @"Complimentary"

// Subscription names
#define kNADASubscription @"NADA"
#define kBasicSubscription @"CARFAX"

// Product keys
#define kProductNADAFull @"com.vinhunter.vinhunterpro.nadapro2"
#define kProductBasic @"com.vinhunter.vinhunterpro.basic"

// Product notifications
#define kPurchaseNotificationSuccessful @"kPurchaseNotificationSuccessful"
#define kPurchaseNotificationUnsuccessful @"kPurchaseNotificationUnsuccessful"
#define kPurchaseNotificationRestored @"kPurchaseNotificationRestored"
#define kPurchaseNotificationExpired @"kPurchaseNotificationExpired"
#define kPurchaseNotificationRefreshView @"kPurchaseNotificationRefreshView"

#define kValidSubscription @"kValidSubscription"
#define kAutoRenewAvailable 0

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif
