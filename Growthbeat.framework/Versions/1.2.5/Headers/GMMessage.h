//
//  GMMessage.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GMTask.h"
#import "GMMessageType.h"
#import "GMAnimationType.h"

@interface GMMessage : GBDomain <NSCoding> {

    NSString *id;
    NSInteger version;
    GMMessageType type;
    NSString *eventId;
    NSInteger frequency;
    NSString *segmentId;
    NSInteger cap;
    GMAnimationType animation;
    NSDate *created;
    GMTask *task;
    NSArray *buttons;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) GMMessageType type;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, assign) NSInteger frequency;
@property (nonatomic, strong) NSString *segmentId;
@property (nonatomic, assign) NSInteger cap;
@property (nonatomic, assign) GMAnimationType animation;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) GMTask *task;
@property (nonatomic, strong) NSArray *buttons;

+ (instancetype)receiveWithClientId:(NSString *)clientId eventId:(NSString *)eventId credentialId:(NSString *)credentialId;

@end
