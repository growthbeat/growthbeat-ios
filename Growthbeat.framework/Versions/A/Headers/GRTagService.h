//
//  GRTagService.h
//  replay
//
//  Created by A13048 on 2014/01/29.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRService.h"

@interface GRTagService : GRService

+ (GRTagService *)sharedInstance;

- (void) setTag:(NSString *)clientId credentialId:(NSString *)credentialId name:(NSString *)name value:(NSString *)value success:(void (^)(void))success fail:(void (^)(NSInteger, NSError *))fail;

@end
