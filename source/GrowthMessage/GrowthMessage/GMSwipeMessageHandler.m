//
//  GMSwipeMessageHandler.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessageHandler.h"
#import "GMSwipeMessageRenderer.h"
#import "GMSwipeMessage.h"
#import "GrowthMessage.h"

@interface GMSwipeMessageHandler () {
    
    NSMutableDictionary *swipeMessageRenderers;
    
}

@property (nonatomic, strong) NSMutableDictionary *swipeMessageRenderers;

@end

@implementation GMSwipeMessageHandler

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

- (BOOL) handleMessage:(GMMessage *)message {
    
    if (message.type != GMMessageTypeSwipe) {
        return NO;
    }
    
    if (![message isKindOfClass:[GMSwipeMessage class]]) {
        return NO;
    }
    
    GMSwipeMessage *swipeMessage = (GMSwipeMessage *)message;
    
//    GMSwipeMessageRenderer *swipeMessageRenderer = [[GMSwipeMessageRenderer alloc] initWithSwipeMessage:swipeMessage];
//    swipeMessageRenderer.delegate = self;
//    [swipeMessageRenderer show];
//    [swipeMessageRenderers setObject:swipeMessageRenderer forKey:[NSValue valueWithNonretainedObject:message]];
    
    return YES;
    
}

#pragma mark --
#pragma mark GMSwipeMessageRendererDelegate

- (void) clickedButton:(GMButton *)button message:(GMMessage *)message {
    
    [[GrowthMessage sharedInstance] selectButton:button message:message];
    
    [swipeMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

@end
