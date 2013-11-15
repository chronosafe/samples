//
//  CHRMigration.h
//  VINHunterPro
//
//  Created by Richard Brown on 12/31/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CHRMigration : NSObject

+(void)migrateDatabase:(NSString *)database success:(void (^)(NSArray *))count failure:(void (^)(NSString *))failure;
+(NSString *)databasePath:(NSString *)dbname;

+ (NSArray *)initializeDatabase;

+ (void)deleteDatabases;

@end
