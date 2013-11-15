//
//  CHRVehicleTableViewController.h
//  VINHunterPro
//
//  Created by Richard Brown on 12/19/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+NXEmptyView.h"
#import "CHREmptyView.h"
#import "ZBarSDK.h"

@interface CHRVehicleTableViewController : UITableViewController<NSFetchedResultsControllerDelegate, ZBarReaderDelegate>

@property (nonatomic) NSArray *vehicles;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


-(void)displayModalKeyboard;
-(void)displayModalScanner;
@end
