//
//  GBCustomIntentHandler.h
//  GrowthbeatCore
//
//  Created by TABATAKATSUTOSHI on 2015/07/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBIntentHandler.h"
#import "GBIntent.h"

@interface GBCustomIntentHandler : NSObject <GBIntentHandler>

@property (copy, nonatomic) void(^block)(GBIntent *intent);

- (void)intentHandlerWithBlock:(void(^)(GBIntent *intent))argBlock;

@end
