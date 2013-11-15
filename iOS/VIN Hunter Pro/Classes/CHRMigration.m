//
//  CHRMigration.m
//  VINHunterPro
//
//  Created by Richard Brown on 12/31/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "CHRMigration.h"
#import "sqlite3.h"
#import "VHPVehicle.h"
#import "ZAActivityBar.h"

@implementation CHRMigration
// Main method.  Used to check for the need for a migation, and if so, perform it.
// Success means that the vehicles will be returned in an array that can be cycled through and saved
// Failure means that the migration was unsuccessful
// If there is no database to migrate an nil is returned
+ (void)migrateDatabase:(NSString *)database success:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure {
    NSString *path = [self databasePath:database];
    NSFileManager *fileman = [NSFileManager defaultManager];
    if ([fileman fileExistsAtPath:path]) {
        [ZAActivityBar showWithStatus:@"Migrating database"];
        NSLog(@"found database at: %@", path);
        // The database was found, so let's initialize it
        NSArray *vehicles = [self initializeDatabase];
        // If there are any vehicles let's cycle through them and migrate them to core data
        if (vehicles) {
            for (VHPVehicle * vehicle in vehicles) {
                NSLog(@"Migrating vehicle %@", vehicle.vin);
                [self migrateVehicle:vehicle];
            }
            if (success)
                success(vehicles);
        }
    } else{
        if (success)
            success(nil);
    }

}

+(void)migrateVehicle:(VHPVehicle *)vehicle {
    NSLog(@"Migrating %@", [vehicle vin]);
}

+ (NSString *)databasePath:(NSString *)dbname
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"Finding db %@", [documentsDirectory stringByAppendingPathComponent:dbname]);
    return [documentsDirectory stringByAppendingPathComponent:dbname];
}

// Open the database connection and retrieve minimal information for all objects.
+ (NSArray *)initializeDatabase {

    sqlite3 *database;
	NSMutableArray *vehicles = [[NSMutableArray alloc] init];
	
	NSString *path = [self databasePath:@"decoded.sql"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for all books.
        const char *sql = "SELECT id FROM vehicles ORDER BY id DESC";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
				
				VHPVehicle *vehicle = [[VHPVehicle alloc] initWithPrimaryKey:primaryKey database:database];
				[vehicles addObject:vehicle];
            }
			
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }

    return vehicles;
}

+ (void)deleteDatabases {
    NSString *path = [self databasePath:@"decoded.sql"];
    NSString *archivePath = [self databasePath:@"archive.sql"];
    NSFileManager *fileman = [NSFileManager defaultManager];
    // Remove decoded database
    if ([fileman fileExistsAtPath:path]) {
        NSError *error;
        [fileman removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"Unable to delete decoded database file");
        }
    }
    // Remove archive database
    if ([fileman fileExistsAtPath:archivePath]) {
        NSError *error;
        [fileman removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"Unable to delete archive database file");
        }
    }
}

@end
