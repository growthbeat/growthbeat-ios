//
//  GRClient.h
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GBDomain.h"
#import "GRRecordStatus.h"
#import "GRConfiguration.h"

@interface GRClient : GBDomain<NSCoding> {

    long long id;
    NSString *growthbeatClientId;
    NSInteger applicationId;
    NSString *token;
    BOOL recorded;
    NSString *recordScheduleToken;
    GRRecordStatus status;
    GRConfiguration *configuration;

}

@property (nonatomic) long long id;
@property (nonatomic) NSString *growthbeatClientId;
@property (nonatomic) NSInteger applicationId;
@property (nonatomic) NSString *token;
@property (nonatomic) BOOL recorded;
@property (nonatomic) NSString *recordScheduleToken;
@property (nonatomic) GRRecordStatus status;
@property (nonatomic) GRConfiguration *configuration;

+ (GRClient *) authorizeWithClientId:(NSString *)clientId credentialId:(NSString *)credentialId client:(GRClient *)client;

@end
