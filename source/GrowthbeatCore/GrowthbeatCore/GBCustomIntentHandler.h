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

@interface GBCustomIntentHandler : NSObject <GBIntentHandler> {
    
    void(^block)(GBIntent *intent);
    
}

@property (copy, nonatomic) void(^block)(GBIntent *intent);

- (id)initWithBlock:(void(^)(GBIntent *intent))argBlock;

@end
