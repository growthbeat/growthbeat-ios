//
//  GMImageMessageHandler.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/20.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMImageMessageHandler.h"
#import "GMImageMessageRenderer.h"
#import "GrowthMessage.h"

@interface GMImageMessageHandler () {

    NSMutableDictionary *imageMessageRenderers;

}

@property (nonatomic, strong) NSMutableDictionary *imageMessageRenderers;

@end

@implementation GMImageMessageHandler

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

    if (![message isKindOfClass:[GMImageMessage class]]) {
        return NO;
    }

    GMImageMessage *imageMessage = (GMImageMessage *)message;

    GMImageMessageRenderer *imageMessageRenderer = [[GMImageMessageRenderer alloc] initWithImageMessage:imageMessage];
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
