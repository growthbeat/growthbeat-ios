//
//  GPImageMessageHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPImageMessageHandler.h"
#import "GPImageMessageRenderer.h"
#import "GrowthPush.h"

@interface GPImageMessageHandler () {
    
    NSMutableDictionary *imageMessageRenderers;
    
}

@property (nonatomic, strong) NSMutableDictionary *imageMessageRenderers;

@end

@implementation GPImageMessageHandler

@synthesize imageMessageRenderers;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.imageMessageRenderers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark --
#pragma mark GMMessageHandler

- (BOOL) handleMessage:(GPMessage *)message {
    
    if (message.type != GPMessageTypeImage) {
        return NO;
    }
    
    if (![message isKindOfClass:[GPImageMessage class]]) {
        return NO;
    }
    
    GPImageMessage *imageMessage = (GPImageMessage *)message;
    
    GPImageMessageRenderer *imageMessageRenderer = [[GPImageMessageRenderer alloc] initWithImageMessage:imageMessage];
    imageMessageRenderer.delegate = self;
    [imageMessageRenderer show];
    [imageMessageRenderers setObject:imageMessageRenderer forKey:[NSValue valueWithNonretainedObject:message]];
    
    return YES;
    
}

#pragma mark --
#pragma mark GMMessageRendererDelegate

- (void) clickedButton:(GPButton *)button message:(GPMessage *)message {
    
    [[GrowthPush sharedInstance] selectButton:button message:message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [GrowthPush sharedInstance].messageInterval * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[GrowthPush sharedInstance] notifyClose];
        [[GrowthPush sharedInstance] openMessageIfExists];
    });
    [imageMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

@end
