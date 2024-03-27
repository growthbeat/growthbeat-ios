//
//  GPMessage.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>
#import <Growthbeat/GPTask.h>
#import <Growthbeat/GPMessageType.h>
#import <Growthbeat/GPBackground.h>
#import <Growthbeat/GPTag.h>

@interface GPMessage : GBDomain <NSCoding> {
    
    NSString *id;
    GPMessageType type;
    GPBackground *background;
    NSDate *created;
    GPTask *task;
    NSArray *buttons;
    
}
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) GPMessageType type;
@property (nonatomic, strong) GPBackground *background;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) GPTask *task;
@property (nonatomic, strong) NSArray *buttons;

+ (GPMessage *)receive:(NSString *)taskId applicationId:(NSString *)applicationId clientId:(NSString *)clientId credentialId:(NSString *)credentialId;

@end
