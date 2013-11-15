// InAppPurchaseManager.h
#import <StoreKit/StoreKit.h>
#import "CargoBay.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kiTunesSharedSecret @"e5eaab89ed1d43189f5dc0c14520488e"

@interface CHRSubscriptionHandler : NSObject
{
    NSArray *products;
    BOOL valid;
    BOOL purchasing;
}

+ (instancetype)sharedManager;

// Set up the storekit callbacks
-(void)setup;

- (void)restoreTransactions;

- (void)verifyReceipt:(SKPaymentTransaction *)trans;


- (SKProduct *)productForIdentifier:(NSString *)identifier;

- (void)getProducts;

// Get a list of products

- (void)updateUserWithReceipt:(NSData *)receipt expires:(NSDate *)date forProduct:(NSString *)productId;

// Purchase a subscription
-(BOOL)purchaseSubscriptionForProduct:(SKProduct *)product;

- (void)processReceipt:(NSData *)transactionReceipt withCompletion:(void (^)(BOOL success))completion;

// Save the receipt to PFUser

// Validate a receipt

// Restore previous purchases

// Cancel subscription

// Present Purchase ViewController

//

@end