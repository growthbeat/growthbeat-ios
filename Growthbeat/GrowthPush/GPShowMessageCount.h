//
//  GPShowMessageCount.h
//  Growthbeat
//
//  Created by 尾川 茂 on 2017/03/10.
//  Copyright © 2017年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GPShowMessageCount : GBDomain <NSCoding> {
    
    NSString *clientId;
    NSString *messageId;
    NSString *taskId;
    NSInteger count;
    
}
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, assign) NSInteger count;

+ (GPShowMessageCount *)receiveCount:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId taskId:(NSString *)taskId messageId:(NSString *)messageId;

@end
