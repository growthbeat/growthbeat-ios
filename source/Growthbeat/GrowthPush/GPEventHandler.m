//
//  GPEventHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/20.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPEventHandler.h"

@interface GPEventHandler() {

}

@end

@implementation GPEventHandler

@synthesize handleMessage;

- (instancetype)initWithBlock:(void(^)(GPMessage *message))newHandleMessage {
    self = [super init];
    if (self) {
        self.handleMessage = newHandleMessage;
    }
    return self;
}


@end
