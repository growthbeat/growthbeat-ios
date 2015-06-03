//
//  GMBannerMessageHandler.m
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMBannerMessageHandler.h"
#import "GMBannerMessageRenderer.h"
#import "GMBannerMessage.h"
#import "GrowthMessage.h"

@interface GMBannerMessageHandler () {
    
    NSMutableDictionary *bannerMessageRenderers;
    
}

@property (nonatomic, strong) NSMutableDictionary *BannerMessageRenderers;

@end

@implementation GMBannerMessageHandler

@synthesize BannerMessageRenderers;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.BannerMessageRenderers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark --
#pragma mark GMMessageHandler

- (BOOL) handleMessage:(GMMessage *)message {
    
    if (message.type != GMMessageTypeBanner) {
        return NO;
    }
    
    if (![message isKindOfClass:[GMBannerMessage class]]) {
        return NO;
    }
    
    GMBannerMessage *bannerMessage = (GMBannerMessage *)message;
    
    GMBannerMessageRenderer *bannerMessageRenderer = [[GMBannerMessageRenderer alloc] initWithBannerMessage:bannerMessage];
    bannerMessageRenderer.delegate = self;
    [bannerMessageRenderer show];
    [BannerMessageRenderers setObject:bannerMessageRenderer forKey:[NSValue valueWithNonretainedObject:message]];
    
    return YES;
    
}

#pragma mark --
#pragma mark GMBannerMessageRendererDelegate

- (void) clickedButton:(GMButton *)button message:(GMMessage *)message {
    
    [[GrowthMessage sharedInstance] selectButton:button message:message];
    
    [bannerMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

@end
