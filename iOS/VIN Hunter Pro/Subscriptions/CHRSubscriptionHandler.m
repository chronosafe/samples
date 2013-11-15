//
// Created by chronosafe on 1/7/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CHRSubscriptionHandler.h"
#import "CHRHelper.h"
#import "NSArray+objectsAccessors.h"
#import "CargoBay.h"
#import <StoreKit/StoreKit.h>



@implementation CHRSubscriptionHandler {
    BOOL restored;
}

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    
    return _sharedManager;
}


- (void)setup {

    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        [self updateTransations:transactions];
    }];

    [[CargoBay sharedManager] setPaymentQueueRemovedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        [self removeTransactions:transactions];
    }];

    [[CargoBay sharedManager] setPaymentQueueRestoreCompletedTransactionsWithSuccess:^(SKPaymentQueue *queue) {
        NSLog(@"Restore success");
        if (restored) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseNotificationRefreshView object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [CHRHelper showAlertWithTitle:@"Subscription successful"
                                   andMessage:@"Thank you for subscribing to VIN Hunter Pro."];
                [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseNotificationRefreshView object:nil];
            });
        } else {
            // If this user has an iTunes subscription then disable it
            if ([CHRHelper isiTunesSubscription]) {
                PFUser *user = [CHRHelper currentUser];
                user[kpisEnabled] = @NO; // Disable user since there are no valid receipts
                [user saveInBackground];
                // Make the view refresh it's data
                [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseNotificationRefreshView object:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CHRHelper showAlertWithTitle:@"Subscription failure"
                                       andMessage:@"No valid subscriptions currently available."];
                });
            }
        }

        [CHRHelper toastDismiss];

    } failure:^(SKPaymentQueue *queue, NSError *error) {
        
        // Failed connecting.  This might be because the user canceled
        NSLog(@"Restore error = %@", [error localizedDescription]);
        [CHRHelper toastDismiss];
    }];
    
    restored = NO;

    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];

}

// Main method to process transactions as they come in
-(void)updateTransations:(NSArray *)transactions {
    NSLog(@"Updated Transactions: %@", transactions);
    for (SKPaymentTransaction *trans in transactions) {
        
        if ([trans transactionState] == SKPaymentTransactionStatePurchasing) {
            NSLog(@"Processing a purchasing transaction...");
        }
        // Verify the receipt
        if ([trans transactionState] == SKPaymentTransactionStatePurchased) {
            NSLog(@"Processing a purchased transaction");
            [self verifyPurchaseReceipt:trans];
            // Finish the transaction so it's removed from the queue
        }
        
        if ([trans transactionState] == SKPaymentTransactionStateRestored) {
            NSLog(@"Processing a restored transaction");
            [self verifyReceipt:trans];
            
        }
        // Somehow the transaction failed
        if ([trans transactionState] == SKPaymentTransactionStateFailed) {
            if (!purchasing) {
                NSLog(@"Processing failed for transaction");
                [CHRHelper showAlertWithTitle:@"Transaction failed"
                                   andMessage:[NSString stringWithFormat:@"Error processing transaction: %@", [trans.error localizedDescription]]];
            } else {
                NSLog(@"Canceled transaction");
                purchasing = NO;
                
            }
            [CHRHelper toastDismiss];
            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
        }
        
    }
}

-(void)removeTransactions:(NSArray *)transactions {
    NSLog(@"Removed Transactions = %@", transactions);
}

-(void)restoreTransactions {
    NSLog(@"Forcing a restore of transactions");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)processReceipt:(NSData *)transactionReceipt withCompletion:(void (^)(BOOL success))completion {
    [[CargoBay sharedManager] verifyTransactionReceipt:transactionReceipt password:kiTunesSharedSecret success:^(NSDictionary *responseObject) {
               NSNumber *status = [responseObject valueForKey:@"status"];
               if (status) {
                   switch ([status integerValue]) {
                       case 0: {
                           NSLog(@"Successful verification");
                           NSDictionary *receipt;
                           NSData *receiptData;
                           NSLog(@"responseObject: %@", responseObject);
                           // Grab the expiration date and correct receipt
                           if (responseObject[@"latest_receipt_info"]) {
                               NSLog(@"latest info:");
                               receipt = responseObject[@"latest_receipt_info"];
                               receiptData = responseObject[@"latest_receipt"];
                           } else {
                               NSLog(@"original info:");
                               receipt = responseObject[@"receipt"];
                               receiptData = transactionReceipt;
                           }

                           [self updateUserWithReceipt:transactionReceipt
                                               expires:[self expirationDateFromReceipt:receipt]
                                            forProduct:[self productNameFromTransaction:responseObject]];
                           if (completion) {
                               completion(YES);
                           }
                           return; // Done processing
                       }
                           
                           break;
                       case 21006:
                           NSLog(@"Receipt is valid but expired");
                           break;
                       default:
                           NSLog(@"Error validating receipt: %@", status);
                           break;
                   }
               }
               if (completion) {
                   completion(NO);
               }
               
           }

           failure:^(NSError *error) {
               NSLog(@"Error verifying receipt %@", [error localizedDescription]);
               if (completion) {
                   completion(NO);
               }
               
           }];
}


-(void)verifyPurchaseReceipt:(SKPaymentTransaction *)trans {
    [self processReceipt:trans.transactionReceipt withCompletion:^(BOOL success) {
        PFUser *user = [CHRHelper currentUser];
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseNotificationRefreshView object:nil];
            if (!restored) {
                // Successfully purchased subscription, so notify user
                [CHRHelper showAlertWithTitle:@"Subscription Purchase" andMessage:@"Thank you for subscribing to VIN Hunter Pro"];
                // Refresh view
                
                restored = YES;
            }
            user[kpisEnabled] = @YES;
            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
        } else {
            
            user[kpisEnabled] = @NO; // Disable user since there are no valid receipts
            [user saveInBackground];
            // Make the view refresh it's data
            [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseNotificationRefreshView object:nil];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [CHRHelper showAlertWithTitle:@"Subscription failure"
//                                   andMessage:@"No valid subscriptions currently available."];
//            });
            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
        }
        [CHRHelper toastDismiss];
    }];
}

// Verify that the receipt is valid
-(void)verifyReceipt:(SKPaymentTransaction *)trans {
    
    [self processReceipt:trans.transactionReceipt withCompletion:^(BOOL success) {
        // Receipt has been processed
        if (success) {
            restored = YES;
        }
        [[SKPaymentQueue defaultQueue] finishTransaction:trans];
    }];
}


// Get the product name from the receipt data
-(NSString *)productNameFromTransaction:(NSDictionary *)responseObject {
    NSDictionary *dict = [responseObject valueForKey:@"receipt"];
    NSString *prod = [dict valueForKey:@"product_id"];
    if ([prod isEqualToString:kProductNADAFull]) {
        return kNADASubscription;
    }
    if ([prod isEqualToString:kProductBasic]) {
        return kBasicSubscription;
    }
    return nil;
}

// Get the expiration date from the receipt
-(NSDate *)expirationDateFromReceipt:(NSDictionary *)receipt {
    NSString *dateString;
    if (kAutoRenewAvailable) {
        dateString = [receipt valueForKey:@"expires_date_formatted"];
    } else {
        // No expiration date, so we'll have to use the original create date + 30 days. :p
        dateString = [receipt valueForKey:@"original_purchase_date"];
    }
    
    dateString = [dateString stringByReplacingOccurrencesOfString:@"Etc/" withString:@""]; // Remove the annoying Etc/
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *expiration = [fmt dateFromString:dateString];
    // Find the begining of the next month since purchase as the expiration date
    if (!kAutoRenewAvailable) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setMonth:1];
        // If the current subscription is active then we need to extend it instead of setting it
        if ([CHRHelper isValidSubscription]) {
            expiration = [[CHRHelper currentUser] valueForKey:kpExpiresOn];
        }
        NSDate *beginningOfNextMonth = [cal dateByAddingComponents:comps toDate:expiration options:0];
        expiration = beginningOfNextMonth;
    }
    if (expiration) {
        NSLog(@"Expiration date is %@", expiration);
        return expiration;
    }
    return nil;
}

// The receipt is valid, so update the user record accordingly
-(void)updateUserWithReceipt:(NSData *)receipt expires:(NSDate *)date forProduct:(NSString *)productId {
    PFUser *user = [CHRHelper currentUser];
    NSLog(@"Updating user information");
    //restored = YES;
    // Save the valid receipt to the user object
    if (user) {
        
        if (!date) {
            date = [NSDate date];
        }
        // if the date on the receipt is later than the expiration date then use it
        [user setValue:date forKey:kpExpiresOn];
        [user setValue:receipt forKey:kpskReceipt];
        [user setValue:@YES forKey:kpisEnabled];        
        [user setValue:kSubTypeiTunes forKey:kSubscriptionType];
        [user setValue:productId forKey:kSubscription];
        [user saveInBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseNotificationRefreshView object:nil];
        
    } else {
        NSLog(@"User not logged on?");
        dispatch_async(dispatch_get_main_queue(), ^{
            [CHRHelper showAlertWithTitle:@"purchaseErrorTitle"
                               andMessage:@"No user logged in.  Please login before purchasing subscriptions"];
        });
    }
}

-(BOOL)purchaseSubscriptionForProduct:(SKProduct *)product {
    
    if (![SKPaymentQueue canMakePayments]) { // Can't make payments, so say it was not successfully added to queue
        NSLog(@"Payments disabled");
        return NO;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    if (payment) {
        purchasing = YES;  // Potentially any error is really a cancel on purchase
        [[SKPaymentQueue defaultQueue] addPayment:payment]; // Add payment to Queue
        return YES;
    }
    NSLog(@"Problems with SKPayment");
    return NO;
}

-(SKProduct *)productForIdentifier:(NSString *)identifier {
    if (!products) {
        [self getProducts];
    }
    if (products) {
        for (SKProduct *prod in products) {
            if ([prod.productIdentifier isEqualToString:identifier]) {
                return prod;
            }
        }
    }
    return nil;
}

- (void)getProducts {
    // List of products to look for (hardcoded for now)
    // TODO: Move list of products to some kind of refreshable source (Parse?)
    NSArray *identifiers = @[
    kProductNADAFull
    ];
    
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *productList, NSArray *invalidIdentifiers) {
                                                  NSLog(@"Products: %@", productList);
                                                  products = [productList copy];
                                                  NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
                                              } failure:^(NSError *error) {
                                                  NSLog(@"Error: %@", error);
                                                  products = nil;

                                              }];
}

@end