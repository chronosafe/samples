//
//  CHRVehicleTableViewController.m
//  VINHunterPro
//
//  Created by Richard Brown on 12/19/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "CHRVehicleTableViewController.h"
#import "ADVTheme.h"
#import "RestKit.h"
#import "Vehicle.h"
#import "Vehicle+VIN.h"
#import "Photo+VIN.h"
#import "CHRVehicleCell.h"
#import "CHRDetailViewController.h"
#import "NSArray+objectsAccessors.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CHRHelper.h"
#import <AudioToolbox/AudioServices.h>
#import <ZAActivityBar.h>
#import "CHRMigration.h"
#import <Parse/Parse.h>
#import "VHPVehicle.h"
#import "TestFlight.h"

@interface CHRVehicleTableViewController ()


@end

@implementation CHRVehicleTableViewController {
    Vehicle *vehicle;
    NSArray *colors;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)refreshTable {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UITabBar *tabBarAppearance = [UITabBar appearance];
    [tabBarAppearance setBackgroundImage:[[ADVThemeManager sharedTheme] tabBarBackground]];
    [tabBarAppearance setSelectionIndicatorImage:[[ADVThemeManager sharedTheme] tabBarSelectionIndicator]];
    [self refreshTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [[AppDelegate sharedDelegate] managedObjectContext];
    [ADVThemeManager customizeTableView:self.tableView];
    self.tableView.nxEV_emptyView = [[CHREmptyView alloc] initWithFrame:self.view.frame];
    self.tableView.nxEV_emptyView.backgroundColor = [UIColor whiteColor];
    [self refreshTable];
    colors = [CHRHelper colors];

    // Migrate the database if needed
    [self migrateDatabase];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInputModal)
                                                 name:@"kCenterTabbarItemTapped"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable)
                                                 name:@"kUpdateVehicleTable"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInputModal)
                                                 name:kInputModeScanner
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScanner)
                                                 name:kInputModeScannerForced
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VehicleCell";
    CHRVehicleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CHRVehicleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Vehicle *v = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item"]];

    cell.vinNumber.text = v.vin;
    cell.vehicleName.text = v.fullNameWOTrim;
    cell.noteText.text = v.notes;
    Photo __block *photo = [v defaultPhoto];
    if (!photo.image) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:photo.url]
                       placeholderImage:[UIImage imageNamed:@"placeholder"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (!error){
                // Save the image to core data
                photo.image = UIImagePNGRepresentation(image);
                NSError *error;
                [photo.managedObjectContext save:&error];
                if (error) {
                    NSLog(@"Error saving image");
                }
                //NSLog(@"Setting image");
            } else {
                NSLog(@"Error retrieving image: %@", [error localizedDescription]);
            }
        }];
    } else {
        // If the image has previously been saved then just display it.
        [cell.imageView setImage:[UIImage imageWithData:[photo image]]];
    }
    if ([[v color] length]) {
        cell.colorView.backgroundColor = [CHRHelper colorForName:[v color]];
        cell.colorView.image = [UIImage imageNamed:@"colorBlock"];
    } else {
        cell.colorView.backgroundColor = [UIColor clearColor];
        cell.colorView.image = nil;
    }
    if ([v.carfaxUrl length]) {
        cell.carfaxView.hidden = NO;
    } else {
        cell.carfaxView.hidden = YES;
    }
    if ([[v mileage] length]) {
        cell.mileage.text = [NSString stringWithFormat:@"%@ mi.", v.mileage];
    } else {
        cell.mileage.text = @"";
    }
    
    if ([[v trimName] length]) {
        cell.trimText.text = v.trimName;
    }
    else {
        cell.trimText.text = @"";
    }
    
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, tableView.bounds.size.width - 10, 18)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];

    // Convert the section label from a string to a date and back again to format it correctly
    id <NSFetchedResultsSectionInfo> theSection = [[_fetchedResultsController sections] objectAtIndex:section];
    NSString *dateString = [theSection name];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss zzz"];
    NSDate *myDate = [df dateFromString: dateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, YYYY"];
    NSString *date = [formatter stringFromDate:myDate];
    label.text = [date uppercaseString];
    
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

#pragma mark - Notification for Input popup

-(void)displayInputModal {
    
    if (![CHRHelper internetIsAvailable:nil isSilent:NO]) {
        return;
    }
    // You can only use the decoder with an active subscription
    if (![CHRHelper isValidSubscription])    {
        [CHRHelper require:@"Tap this button to scan and decode a vehicle. An active subscription is required; please sign in on the Accounts tab."];
        return;
    }

    NSNumber *defaultInput = [[NSUserDefaults standardUserDefaults] valueForKey:kBarcodeDefault];
    BOOL barcode;
    if (defaultInput == nil)
        barcode = YES;
    else
        barcode = [defaultInput boolValue];
    
    // No matter what the setting, if no camera then display the keyboard
    BOOL hasCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    if (!hasCamera) {
        barcode = NO;
    }
    
    if (barcode) {
        [self presentScanner];
    } else {
        [self performSegueWithIdentifier:@"InputSeque" sender:self];
    }
    

}

-(void)displayModalKeyboard {
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"InputSeque" sender:self];
    }];
}

-(void)displayModalScanner {
    [self dismissViewControllerAnimated:YES completion:^{
         [self presentScanner];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Vehicle *v = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if (!v.data) {
        [ZAActivityBar showWithStatus:@"Loading vehicle"];
        [Vehicle decodeVehicle:v success:^(Vehicle *vdata) {
            NSLog(@"Loaded data: %@", vdata.data);
            [ZAActivityBar dismiss];
            [self performSegueWithIdentifier:@"DetailSegue" sender:self];
        } failure:^(NSString *error) {
            //[
            NSLog(@"Unable to load data: %@",error);
            [ZAActivityBar showErrorWithStatus:@"Unable to load vehicle data"];
        }];
    } else {
//        if (![CHRHelper currentUser])    {
//            [CHRHelper require:@"A valid user account is required.  Please sign up on the Accounts tab."];
//        } else {
//            [self performSegueWithIdentifier:@"DetailSegue" sender:self];
//        }
        
        [self performSegueWithIdentifier:@"DetailSegue" sender:self];
        
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath: [self.tableView indexPathForSelectedRow]];
        [cell setSelected:NO];
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

//    if (![CHRHelper currentUser])    {
//        [CHRHelper require:@"A valid user account is required.  Please sign up on the Accounts tab."];
//        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath: [self.tableView indexPathForSelectedRow]];
//        [cell setSelected:NO];
//        return NO;
//    }
    
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath: [self.tableView indexPathForSelectedRow]];
    [cell setSelected:NO];
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        //Vehicle *v = _vehicles[(NSUInteger) [self.tableView indexPathForSelectedRow].row];
        Vehicle *v = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];

        UINavigationController *controller = [segue destinationViewController];
        CHRDetailViewController *detailViewController = [controller childViewControllers].first;
        [detailViewController setVehicle:v];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vehicle" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"dayCreated" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(CHRVehicleCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

-(void)presentScanner {
    
    if (![CHRHelper internetIsAvailable:nil isSilent:NO]) {
        return;
    }

    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;

    UIView* subView1 = [reader.view.subviews objectAtIndex:2];
    UIToolbar* toolbar = [subView1.subviews objectAtIndex:0];
    
    NSArray *buttons = [toolbar items];
    UIBarButtonItem *keyboardButton = [[UIBarButtonItem alloc] initWithTitle:@"keyboard" style:UIBarButtonItemStyleBordered target:self action:@selector(displayModalKeyboard)];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:buttons];
    [array addObject:[[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
              target: nil
                      action: nil]];
    [array addObject:keyboardButton];
    
    keyboardButton.title = @"Keyboard";
    [toolbar setItems:array];
    
    reader.cameraOverlayView = [[UIImageView alloc] initWithImage:iPhone568Image(@"barcodeOverlay.png")];
    
    // Disable all barcode types besides CODE39 for speed
    
    [reader.scanner setSymbology: ZBAR_CODE128
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_QRCODE
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_I25
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_EAN13
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_EAN8
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_UPCA
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_UPCE
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_QRCODE
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
    [reader.scanner setSymbology: ZBAR_ISBN10
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_ISBN13
						  config: ZBAR_CFG_ENABLE
							  to: 0];
	
	[reader.scanner setSymbology: ZBAR_CODE39
						  config: ZBAR_CFG_ENABLE
							  to: 1];
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // Get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    NSString *barcode;
    ZBarSymbol *symbol = nil;
    for(symbol in results) {
        // EXAMPLE: just grab the first barcode
        barcode = symbol.data;
        barcode = [barcode stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        while ([barcode length] > 17) {
            barcode = [barcode substringFromIndex:1];
        }
    
        if ([barcode length] == 17) {
             NSLog(@"VIN = %@", barcode);
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); // vibrate the phone
            [self addVehicleWithVIN:barcode];
            PFUser *user = [CHRHelper currentUser];
            if (user) {
                if ([[user valueForKey:@"barcodeDebug"] boolValue]) {
                    // If we're debugging then save the image of the barcode...
                    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
                    [self debugSaveScannerImage:image forVIN:barcode];
                    NSLog(@"Saving barcode debug image");
                }
            }
            
            break;
        }
        NSLog(@"Barcode %@", barcode);
    }
    
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
}

- (void)addVehicleWithVIN:(NSString *)vin {
    if (![Vehicle validate:vin])  {
        [CHRHelper showAlertWithTitle:NSLocalizedString(@"Invalid VIN", @"Invalid VIN")
                           andMessage:NSLocalizedString(@"VIN Checksum digit is invalid", @"VIN Checksum digit is invalid")];
        return;
    }
    
    if ([vin length] == 17) {
        [ZAActivityBar showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Decoding VIN %@", @"Decoding VIN %@"), vin]];
        
        [Vehicle decodeVIN:vin success:^(Vehicle *v) {

            [ZAActivityBar showSuccessWithStatus:[NSString stringWithFormat:NSLocalizedString(@"VIN %@ is a:\n %@", @"VIN %@ is a:\n %@"), vin, v.fullName]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateVehicleTable" object:nil];
        } failure:^(NSString *error) {

            [ZAActivityBar dismiss];
            [CHRHelper showAlertWithTitle:NSLocalizedString(@"Service Error", @"Service error")
                               andMessage:error];
        }];
    }
}

- (void)debugSaveScannerImage:(UIImage *)image forVIN:(NSString *)vin {
    // Save PFFile
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg", vin]
                                        data:UIImageJPEGRepresentation(image, 0.7)];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *userPhoto = [PFObject objectWithClassName:@"barcodePhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            [userPhoto setObject:user.username forKey:@"userName"];
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                }
                else{
                    // Log details of the failure
                    NSLog(@"debugSaveScannerImage Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
           
            // Log details of the failure
            NSLog(@"debugSaveScannerImage Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:nil];
}



-(void)keyboard {
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss barcode
    [self performSegueWithIdentifier:@"InputSeque" sender:self]; // Segue to the keyboard
}

// Perform the database migration, if necessary
- (void)migrateDatabase {
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    NSManagedObjectContext *context = [app managedObjectContext];
    [CHRMigration migrateDatabase:@"decoded.sql" success:^(NSArray *array) {
        if (array) {
            NSLog(@"Success! Migrated %d vehicles", [array count]);
            for (VHPVehicle *vehicleVHP in array) {
                NSLog(@"Creating %@", vehicleVHP.vin);
                [vehicleVHP hydrate]; // Load picture data
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vehicle" inManagedObjectContext:context];
                Vehicle *v = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                [fmt setDateFormat:@"MM/dd/yy"];
                NSDate *date = [fmt dateFromString:vehicleVHP.date];
                v.createdDate = date;
                v.vin = vehicleVHP.vin;
                v.make = vehicleVHP.make;
                v.model = vehicleVHP.model;
                v.year = vehicleVHP.year;
                v.mileage = vehicleVHP.mileage;
                v.notes = vehicleVHP.notes;
                v.trimName = vehicleVHP.trim;
                if (vehicleVHP.picture) {
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
                    Photo *p = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
                    p.image = UIImagePNGRepresentation(vehicleVHP.picture);
                    p.selected = @YES;
                    p.vehicle = v;
                }
                // Save the vehicle and photo
                NSError *error;
                [context save:&error];
                if (error) {
                    NSLog(@"Error saving migrated vehicle: %@", [error localizedDescription]);
                }
            }
            // Successfully migrated the old records so we can now delete the old database files
            [CHRMigration deleteDatabases];
            TFLog(@"Migrated %d vehicles", [array count]);
            [ZAActivityBar showSuccessWithStatus:
                [NSString stringWithFormat:@"Successfully migrated %d vehicles", [array count]]];
            // Refresh the tableview
            [self.tableView reloadData];
        } else {
            //NSLog(@"No migration was needed, no database found");
        }
        
    } failure:^(NSString *string) {
        NSLog(@"Something went wrong with the migration: %@", string);
        [ZAActivityBar showErrorWithStatus:@"Was unsucessful in migrating database"];
    }];

}
@end
