//
//  GPSwipeMessageHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeMessageHandler.h"
#import "GPSwipeMessageRenderer.h"
#import "GPSwipeMessage.h"
#import "GrowthPush.h"

@interface GPSwipeMessageHandler () {
    
    NSMutableDictionary *swipeMessageRenderers;
    
}

@property (nonatomic, strong) NSMutableDictionary *swipeMessageRenderers;

@end

@implementation GPSwipeMessageHandler

@synthesize swipeMessageRenderers;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.swipeMessageRenderers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark --
#pragma mark GMMessageHandler

- (BOOL) handleMessage:(GPMessage *)message {
    
    if (message.type != GPMessageTypeSwipe) {
        return NO;
    }
    
    if (![message isKindOfClass:[GPSwipeMessage class]]) {
        return NO;
    }
    
    GPSwipeMessage *swipeMessage = (GPSwipeMessage *)message;
    
    GPSwipeMessageRenderer *swipeMessageRenderer = [[GPSwipeMessageRenderer alloc] initWithSwipeMessage:swipeMessage];
    swipeMessageRenderer.delegate = self;
    [swipeMessageRenderer show];
    [swipeMessageRenderers setObject:swipeMessageRenderer forKey:[NSValue valueWithNonretainedObject:message]];
    
    return YES;
    
}

#pragma mark --
#pragma mark GPSwipeMessageRendererDelegate

- (void) clickedButton:(GPButton *)button message:(GPMessage *)message {
    
    [[GrowthPush sharedInstance] selectButton:button message:message];
    [[GrowthPush sharedInstance] notifyClose];
    [swipeMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

- (void)backgroundTouched:(GPMessage *)message {
    [[GrowthPush sharedInstance] notifyClose];
    [swipeMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
}

@end