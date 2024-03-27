//
//  GPEventHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/20.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPShowMessageHandler.h>

@interface GPShowMessageHandler() {

}

@end

@implementation GPShowMessageHandler

@synthesize handleMessage;

- (instancetype)initWithBlock:(void(^)(void(^ messageCallback)()))newHandleMessage {
    self = [super init];
    if (self) {
        self.handleMessage = newHandleMessage;
    }
    return self;
}


@end
