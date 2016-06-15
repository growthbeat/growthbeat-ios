//
//  GPImageMessageHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPImageMessageHandler.h"
#import "GPImageMessageRenderer.h"
#import "GrowthMessage.h"

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

- (BOOL) handleMessage:(GMMessage *)message {
    
    if (message.type != GMMessageTypeImage) {
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

- (void) clickedButton:(GMButton *)button message:(GMMessage *)message {
    
    [[GrowthMessage sharedInstance] selectButton:button message:message];
    
    [imageMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

@end
