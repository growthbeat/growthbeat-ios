//
//  GPImageMessageHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPCardMessageHandler.h"
#import "GPCardMessageRenderer.h"
#import "GrowthPush.h"

@interface GPCardMessageHandler () {
    
    NSMutableDictionary *imageMessageRenderers;
    
}

@property (nonatomic, strong) NSMutableDictionary *imageMessageRenderers;

@end

@implementation GPCardMessageHandler

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
    
    if (![message isKindOfClass:[GPCardMessage class]]) {
        return NO;
    }
    
    GPCardMessage *imageMessage = (GPCardMessage *)message;
    
    GPCardMessageRenderer *imageMessageRenderer = [[GPCardMessageRenderer alloc] initWithImageMessage:imageMessage];
    imageMessageRenderer.delegate = self;
    [imageMessageRenderer show];
    [imageMessageRenderers setObject:imageMessageRenderer forKey:[NSValue valueWithNonretainedObject:message]];
    
    return YES;
    
}

#pragma mark --
#pragma mark GMMessageRendererDelegate

- (void) clickedButton:(GPButton *)button message:(GPMessage *)message {
    
    [[GrowthPush sharedInstance] selectButton:button message:message];
    [[GrowthPush sharedInstance] notifyClose];
    [imageMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

- (void)backgroundTouched:(GPMessage *)message {
    [[GrowthPush sharedInstance] notifyClose];
    [imageMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
}

@end
