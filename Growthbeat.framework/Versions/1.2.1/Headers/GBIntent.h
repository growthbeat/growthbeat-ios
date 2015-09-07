//
//  GBIntent.h
//  GrowthbeatCore
//
//  Created by 堀内 暢之 on 2015/03/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GBIntentType.h"

@interface GBIntent : GBDomain <NSCoding> {

    NSString *id;
    NSString *applicationId;
    NSString *name;
    GBIntentType type;
    NSDate *created;
}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) GBIntentType type;
@property (nonatomic, strong) NSDate *created;

@end
