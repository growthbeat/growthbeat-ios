//
//  GPClient.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GPOS.h"
#import "GPEnvironment.h"

@interface GPClient : GBDomain <NSCoding> {

    long long id;
    NSInteger applicationId;
    NSString *code;
    NSString *token;
    GPOS os;
    GPEnvironment environment;
    NSDate *created;

}

@property (nonatomic, assign) long long id;
@property (nonatomic, assign) NSInteger applicationId;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *growthbeatClientId;
@property (nonatomic, retain) NSString *growthbeatApplicationId;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, assign) GPOS os;
@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, retain) NSDate *created;

+ (GPClient *) load;
+ (void) removePreference;
+ (GPClient *) findWithGPClientId:(long long)clientId code:(NSString *)code;

@end
