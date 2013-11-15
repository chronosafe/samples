//
//  CHRDetailViewController.h
//  VINHunterPro
//
//  Created by Richard Brown on 12/19/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoBox.h"
@class Vehicle;

@interface CHRDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) Vehicle *vehicle;
@property (nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) IBOutlet UILabel *mileage;
@property (nonatomic) IBOutlet UILabel *vehicleName;
@property (nonatomic) IBOutlet UILabel *color;
@property (nonatomic) IBOutlet UILabel *transmission;
@property (nonatomic) IBOutlet UILabel *vin;
@property (nonatomic) IBOutlet UILabel *trimName;
@property (nonatomic) IBOutlet UIImageView *mpg;
@property (nonatomic) IBOutlet UILabel *cityMPG;
@property (nonatomic) IBOutlet UILabel *hwyMPG;

@property (nonatomic) IBOutlet UIImageView *titleBackground;
@property (nonatomic) IBOutlet UITableView *tableView;
-(IBAction)doneAction:(id)sender;
-(IBAction)displayNotes:(id)sender;
-(IBAction)displayShare:(id)sender;
-(IBAction)addPhoto:(id)sender;

@end
