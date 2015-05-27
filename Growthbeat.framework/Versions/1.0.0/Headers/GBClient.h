//
//  GBClient.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GBApplication.h"

@interface GBClient : GBDomain <NSCoding> {

    NSString *id;
    NSDate *created;
    GBApplication *application;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) GBApplication *application;

+ (GBClient *)createWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;
+ (GBClient *)findWithId:(NSString *)id credentialId:(NSString *)credentialId;
+ (void)save:(GBClient *)client;
+ (GBClient *)load;

@end
