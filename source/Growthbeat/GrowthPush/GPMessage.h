//
//  GPMessage.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GPTask.h"
#import "GPMessageType.h"

@interface GPMessage : GBDomain <NSCoding> {
    
    NSString *id;
    GPMessageType type;
    NSDictionary *extra;
    NSDate *created;
    GPTask *task;
    NSArray *buttons;
    
}
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) GPMessageType type;
@property (nonatomic, strong) NSDictionary *extra;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) GPTask *task;
@property (nonatomic, strong) NSArray *buttons;

+ (GPMessage *)getMessage:(NSString *)taskId clientId:(NSString *)clientId credentialId:(NSString *)credentialId;

@end
