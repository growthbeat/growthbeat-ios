//
//  GRClientService.h
//  replay
//
//  Created by A13048 on 2014/01/29.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRService.h"
#import "GRClient.h"
#import "GRPicture.h"

@interface GRClientService : GRService

+ (GRClientService *)sharedInstance;
- (void) authorizeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId client:(GRClient *)client success:(void (^)(GRClient *))success fail:(void (^)(NSInteger, NSError *))fail;
- (void)sendPicture:(long long)clientId token:(NSString *)token recordScheduleToken:(NSString *)recordScheduleToken recordedCheck:(BOOL)recordedCheck file:(NSData *)file timestamp:(long long)timestamp success:(void(^) (GRPicture * picture)) success fail:(void(^) (NSInteger status, NSError * error))fail;

@end
