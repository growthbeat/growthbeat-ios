//
//  GRPicture.h
//  replay
//
//  Created by A13048 on 2014/01/30.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GBDomain.h"

@interface GRPicture : GBDomain<NSCoding> {

    BOOL continuation;
    BOOL status;
    BOOL recordedClient;
}

@property (nonatomic) BOOL continuation;
@property (nonatomic) BOOL status;
@property (nonatomic) BOOL recordedClient;

+ (GRPicture *) sendPicture:(NSString *)clientId credentialId:(NSString *)credentialId recordScheduleToken:(NSString *)recordScheduleToken recordedCheck:(BOOL)recordedCheck file:(NSData *)file timestamp:(long long)timestamp;

@end
