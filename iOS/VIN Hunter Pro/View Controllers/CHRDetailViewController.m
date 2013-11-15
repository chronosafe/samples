//
//  CHRDetailViewController.m
//  VINHunterPro
//
//  Created by Richard Brown on 12/19/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "CHRDetailViewController.h"
#import "ADVTheme.h"
#import "CustomCellBackgroundView.h"
#import "CHRHelper.h"
#import "TDBadgedCell.h"
#import "Vehicle.h"
#import "Vehicle+VIN.h"
#import "CHRBasicViewController.h"
#import "ZAActivityBar.h"
#import "NADAValues.h"
#import "VHPVehicle.h"
#import "NADATabView.h"
#import "Report.h"
#import "WebBrowserController.h"
#import "WCAlertView.h"
#import "EquipmentViewController.h"
#import "CHRNotesViewController.h"
#import "Photo.h"
#import "Photo+VIN.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NLViewController.h"
#import "AppDelegate.h"
#import "TestFlight.h"
#import "CHREngine.h"
#import "CHRFuelEconomy.h"
#import "CHRHighLow.h"
#import "CHRSharingViewController.h"

#define ALPHAFADE 0.5


@interface CHRDetailViewController ()
{
    CHRVehicleDescription *desc;
}

@end

@implementation CHRDetailViewController

{
    NSArray *list;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    Photo *photo = [_vehicle defaultPhoto];
    if ([photo image]) {
        self.image.image = [photo imageFromData];
    }
    if ([_vehicle color] && [[_vehicle color] length]) {
        self.color.text = [_vehicle color];
        self.color.textColor = [CHRHelper colorForName:[_vehicle color]];
        // White and Yellow are too light to be used.  Green too maybe?
        if (self.color.textColor == [UIColor whiteColor] ||
            self.color.textColor == [UIColor yellowColor ]) {
            self.color.textColor = [UIColor blackColor];
        }
        self.color.alpha = 1;
    } else {
        self.color.text = @"";
        self.color.alpha = ALPHAFADE;
    }
    
    
    if ([_vehicle trimName] && [[_vehicle trimName] length]) {
        self.trimName.text = [_vehicle trimName];
        self.trimName.alpha = 1;
    } else {
        self.trimName.text = NSLocalizedString(@"Trim not selected", @"Trim not selected");
        self.trimName.alpha = ALPHAFADE;
    }
    
    if ([_vehicle mileage] && [[_vehicle mileage] length]) {
        self.mileage.text = [NSString stringWithFormat:NSLocalizedString(@"%@ miles", @"%@ miles"), [_vehicle mileage]];
        self.mileage.alpha = 1;
    } else {
        self.mileage.text = @"";
        self.mileage.alpha = ALPHAFADE;
    }
    
    if ([_vehicle trans] && [[_vehicle trans] length]) {
        self.transmission.text =  [_vehicle trans];
        self.transmission.alpha = 1;
    } else {
        self.transmission.text = @"";
        self.transmission.alpha = ALPHAFADE;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ADVThemeManager customizeView:self.view];
    //NSLog(@"Vehicle in detail is: %@", _vehicle);
    self.vehicleName.text = [_vehicle fullNameWOTrim];
    self.vin.text = [_vehicle vin];
    if (![_vehicle data]) {
        
    }
    list = @[NSLocalizedString(@"Configuration", @"Configuration"),
            NSLocalizedString(@"Buy CARFAX Report", @"Buy CARFAX Report"),
            NSLocalizedString(@"NADA Values", @"NADA Values"),
            NSLocalizedString(@"Equipment", @"Equipment"),
            NSLocalizedString(@"Photos",@"Photos"),
            NSLocalizedString(@"Sharing", @"Sharing tab")];
    Photo *photo = [_vehicle defaultPhoto];
    //[self.image loadPhoto:[[[_vehicle photos] fetchRecords] first]];
    // ***
    Vehicle __block * v = _vehicle;
    Photo __block *p = photo;
    if ([[photo image] length] == 0 && [[photo url] length] > 0) {
    [self.image setImageWithURL:[NSURL URLWithString:photo.url] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (!error){
            BOOL defaultPhoto = (BOOL)[[NSUserDefaults standardUserDefaults] valueForKey:kDefaultPhotoMode];
            
            // Save the image to core data
            photo.image = UIImagePNGRepresentation(image);
            
            if (defaultPhoto) {
                [v clearDefault];
                p.selected = @YES;
            }
            
            NSError *errCode;
            [photo.managedObjectContext save:&errCode];
            if (errCode) {
                NSLog(@"Error saving image");
            }
            //NSLog(@"Setting image");
        }
    }];
    } else {
        self.image.image = [photo imageFromData];
    }

    self.image.layer.borderColor = [UIColor grayColor].CGColor;
    self.image.layer.borderWidth = 1;
    self.image.layer.shadowColor = [UIColor blackColor].CGColor;
    self.image.layer.shadowOffset = CGSizeMake(1, 2);
    self.image.layer.shadowOpacity = 0.4;
    self.image.layer.shadowRadius = 2.0;
    //self.image.layer.masksToBounds = YES;
    //self.image.clipsToBounds = NO;
    self.image.layer.shouldRasterize = YES;
    self.titleBackground.image = [UIImage imageNamed:@"list-item"];
    self.titleBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleBackground.layer.shadowOffset = CGSizeMake(0, 2);
    self.titleBackground.layer.shadowOpacity = 0.25;
    self.titleBackground.layer.shadowRadius = 2.0;
    
    UIView *clearView = [[UIView alloc] initWithFrame:[self.tableView bounds]];
    clearView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = clearView;
    
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tableView.layer.shadowOffset = CGSizeMake(0, 2);
    self.tableView.layer.shadowOpacity = 0.35;
    self.tableView.layer.shadowRadius = 3.0;
    self.tableView.scrollEnabled = NO;

    
    self.tableView.backgroundView = nil;
    
    // MPG stuff
    desc = [CHRVehicleDescription vehicleForXML:_vehicle.data];
    CHREngine *engine = [desc engines][0];
    NSString *city = engine.fuelEconomy.city.high;
    NSString *hwy = engine.fuelEconomy.hwy.high;
    
    if (city == nil) {
        city = @"NA";
    } else {
        city = [NSString stringWithFormat:@"%d",[city integerValue]];
    }
    // Making sure the value is formatted correctly
    if (hwy == nil) {
        hwy = @"NA";
    } else {
        hwy = [NSString stringWithFormat:@"%d",[hwy integerValue]];
    }
    _cityMPG.text = city;
    _hwyMPG.text = hwy;
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [list count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActionCell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...

    CustomCellBackgroundViewPosition pos;
	
	pos = CustomCellBackgroundViewPositionBottom;
	
	NSArray *cellListForSection = list;
	
	if (indexPath.row == 0) {
		pos = CustomCellBackgroundViewPositionTop;
	} else {
		if (indexPath.row < [cellListForSection count]-1) {
			pos = CustomCellBackgroundViewPositionMiddle;
		}
	}
	
	if ([cellListForSection count] == 1) {
		pos = CustomCellBackgroundViewPositionSingle;
	}
	[_tableView setSeparatorColor:[UIColor whiteColor]];
	CustomCellBackgroundView *bkgView = [[CustomCellBackgroundView alloc] initWithFrame:cell.frame];
	bkgView.fillColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
	bkgView.borderColor = [UIColor grayColor];
	cell.backgroundColor = [UIColor clearColor];
	bkgView.position = pos;
	cell.backgroundView = bkgView;
	cell.textLabel.text = list[(NSUInteger) indexPath.row];
	cell.textLabel.textColor = [UIColor blackColor];
    cell.imageView.image = [UIImage imageNamed:@"icon-list"];
    if ([list[(NSUInteger) indexPath.row] isEqualToString:@"Photos"]) {
        cell.badge.radius = 9;
        cell.badgeString = [NSString stringWithFormat:@"%d", [[_vehicle photos] count]];
    }
    // If there is already a CARFAX report purchased show it in the link
    if ([list[(NSUInteger) indexPath.row] isEqualToString:NSLocalizedString(@"Buy CARFAX Report", @"Buy CARFAX Report")]
            && [[_vehicle carfaxUrl] length]) {
        cell.textLabel.text = NSLocalizedString(@"Show CARFAX Report", @"Show CARFAX Report");
    } 
    

    return cell;
}

- (void)showCARFAX:(NSString *)confirm {
    
    Report *report = [[Report alloc] init];
    
    if ([_vehicle.carfaxUrl length] == 0) { // No report stored
        [ZAActivityBar showWithStatus:NSLocalizedString(@"Purchasing CARFAX Report", @"Purchasing CARFAX Report")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [report getReportWithCount:@"0" vin:_vehicle.vin autobuy:confirm];
            if ([report.code isEqualToString:@"500"] || // The report has already been purchased
                [report.code isEqualToString:@"501"]) {
                _vehicle.carfaxUrl = report.report_url;
                _vehicle.carfaxData = report.response;
                [_vehicle.managedObjectContext save:nil];
                [ZAActivityBar dismiss];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"CARFAXSegue" sender:self];
                });
            } else if ([report.code isEqualToString:@"600"]) { // Need to purchase report
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ZAActivityBar dismiss];
                    [WCAlertView showAlertWithTitle:NSLocalizedString(@"Purchase Required", @"Purchase Required")
                                            message:NSLocalizedString(@"Do you approve the purchase of this CARFAX Report?", @"Do you approve the purchase of this CARFAX Report?")
                                 customizationBlock:^(WCAlertView *alertView) {

                        alertView.style = WCAlertViewStyleBlackHatched;

                    }               completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 1) {
                            [self showCARFAX:@"Y"];
                        }

                    }             cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                  otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ZAActivityBar dismiss];
                    // Something went wrong, display it
                    NSLog(@"Report %@", report.code);
                    [CHRHelper showAlertWithTitle:[NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"CARFAX Error", @"CARFAX Error"), report.code]
                                       andMessage:[CHRHelper descriptionForCode:report.code]];
                });
            }
            
        });
    } else {
        [self performSegueWithIdentifier:@"CARFAXSegue" sender:self];
    }
}

- (void)showNADA {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NADATabView *tab = [[NADATabView alloc] init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        VHPVehicle *v = [[VHPVehicle alloc] init];
        
        v.nada = [[NADAValues alloc] init];
        v.vin = _vehicle.vin;
        // Remove the ,
        v.mileage = [_vehicle.mileage stringByReplacingOccurrencesOfString:@"," withString:@""];

        [v.nada setupWithVIN:v];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        v.year = _vehicle.year;
        v.make = _vehicle.make;
        v.model = _vehicle.model;
        v.trim = _vehicle.trimName;

        tab.vehicle = v;
        tab.managedVehicle = _vehicle; // TODO: Refactor this so we don't need to pass the VHPVehicle anymore
        if ([v.nada.vehicles count] > 0) {
            // Save the data for the future
            _vehicle.nadaData = v.nada.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ZAActivityBar dismiss];
                [self presentViewController:tab animated:YES completion:nil];
            });

        } else {
            NSLog(@"OOPS: No vehicles in drill down return");
            dispatch_async(dispatch_get_main_queue(), ^{
                [ZAActivityBar showErrorWithStatus:NSLocalizedString(@"Error loading data", @"Error loading data")];
                [CHRHelper showAlertWithTitle:NSLocalizedString(@"NADA Error", @"NADA Error")
                                   andMessage:NSLocalizedString(@"Unable to retrieve vehicle data.", @"Unable to retrieve vehicle data.")];
            });
        }

    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"BasicSegue"]) {
        CHRBasicViewController *basic = [segue destinationViewController];
        [basic setVehicle:_vehicle];
    }
    if ([[segue identifier] isEqualToString:@"CARFAXSegue"]) {
        WebBrowserController *web = [segue destinationViewController];
        [web setUrl:_vehicle.carfaxUrl];
    }
    if ([[segue identifier] isEqualToString:@"EquipmentSegue"]) {
        EquipmentViewController *equip = [segue destinationViewController];
        [equip setVehicle:_vehicle];
    }
    if ([[segue identifier] isEqualToString:@"NoteSegue"]) {
        CHRNotesViewController  *note = [segue destinationViewController];
        [note setVehicle:_vehicle];
    }
    if ([[segue identifier] isEqualToString:@"PhotoSegue"]) {
        NLViewController  *pics = [segue destinationViewController];
        [pics setVehicle:_vehicle];
    }
    if ([[segue identifier] isEqualToString:@"SharingSegue"]) {
        [TestFlight passCheckpoint:@"Sharing vehicle"];
        CHRSharingViewController *sharing = [segue destinationViewController];
        [sharing setVehicle:_vehicle];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    if ([list[indexPath.row] isEqualToString:@"Configuration"]) {
        [self performSegueWithIdentifier:@"BasicSegue" sender:self];
    }

    if ([list[indexPath.row] isEqualToString:@"NADA Values"]) {
        if ([CHRHelper isNADA] || [[_vehicle sample] boolValue]) {
            if (![CHRHelper internetIsAvailable:nil isSilent:NO]) {
                return;
            }
            [ZAActivityBar showWithStatus:@"Loading NADA data"];
            [self showNADA];
            return;
        } else {
            [CHRHelper require:@"Access to this service requires a valid NADA subscription.  Please upgrade on the Accounts tab."];
        }
    }

    if ([list[indexPath.row] isEqualToString:@"Buy CARFAX Report"]) {
        if (![CHRHelper internetIsAvailable:nil isSilent:NO]) {
            return;
        }
        // If not logged in to carfax then don't allow check
        if ([CHRHelper carfaxLoggedIn]) {
            NSString *autobuy = [CHRHelper carfaxAutoBuy] ? @"Y" : @"N";
            [self showCARFAX:autobuy];
        } else {
            if ([_vehicle carfaxUrl]) {
                [self performSegueWithIdentifier:@"CARFAXSegue" sender:self];
            } else {
                [CHRHelper require:@"Please enter your CARFAX Login information in order to purchase CARFAX reports."];
            }
        }
        
    }

    if ([list[indexPath.row] isEqualToString:@"Equipment"]) {
        [self performSegueWithIdentifier:@"EquipmentSegue" sender:self];
    }

    if ([list[indexPath.row] isEqualToString:@"Photos"]) {
        [self performSegueWithIdentifier:@"PhotoSegue" sender:self];
    }

    if ([list[indexPath.row] isEqualToString:@"Sharing"]) {
        if (![CHRHelper internetIsAvailable:nil isSilent:NO]) {
            return;
        }
        [self performSegueWithIdentifier:@"SharingSegue" sender:self];
    }
    
}

#pragma mark - Button actions

-(IBAction)displayNotes:(id)sender {
    [self performSegueWithIdentifier:@"NoteSegue" sender:self];
}
-(IBAction)displayShare:(id)sender {
    
}

-(IBAction)addPhoto:(id)sender {
    
    BOOL camera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    if (camera) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select the source of the photo:", @"Select the source of the photo:")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Camera", @"Camera"), NSLocalizedString(@"Photo Library", @"Photo Library"), nil];
        [sheet showInView:self.view];
    } else {
        // No camera?  Then no need to throw up a sheet
        [self showLibrary];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Display the camera
    if (buttonIndex == 0) {
        [self showCamera];
    }
    // Display the library
    if (buttonIndex == 1) {
        [self showLibrary];
    }
}

- (void)showCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    [TestFlight passCheckpoint:@"Adding Photo"];

    if (image) {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        Photo *photo = [[appDelegate managedObjectContext] insertNewObjectForEntityForName:@"Photo"];
        photo.image = UIImagePNGRepresentation(image);
        [_vehicle addPhotosObject:photo];
        // If the flag to make new pictures default is set then make this the default photo
        NSNumber *photoDefault = [[NSUserDefaults standardUserDefaults] valueForKey:kDefaultPhotoMode];
        if (photoDefault && [photoDefault boolValue]) {
            [_vehicle clearDefault];
            [photo setSelected:@(YES)];
        }
        NSError *error;
        [_vehicle.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error saving photo: %@", [error localizedDescription]);
            return;
        }
        [self.tableView reloadData];
        [ZAActivityBar showSuccessWithStatus:@"Image saved"];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
