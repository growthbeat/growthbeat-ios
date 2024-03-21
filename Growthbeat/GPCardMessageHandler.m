//
//  GPImageMessageHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPCardMessageHandler.h>
#import <Growthbeat/GPCardMessageRenderer.h>
#import <Growthbeat/GrowthPush.h>

@interface GPCardMessageHandler () {
    
    NSMutableDictionary *cardMessageRenderers;
    
}

@property (nonatomic, strong) NSMutableDictionary *cardMessageRenderers;

@end

@implementation GPCardMessageHandler

@synthesize cardMessageRenderers;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.cardMessageRenderers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark --
#pragma mark GMMessageHandler

- (BOOL) handleMessage:(GPMessage *)message {
    
    if (message.type != GPMessageTypeCard) {
        return NO;
    }
    
    if (![message isKindOfClass:[GPCardMessage class]]) {
        return NO;
    }
    
    GPCardMessage *cardMessage = (GPCardMessage *)message;
    
    GPCardMessageRenderer *cardMessageRenderer = [[GPCardMessageRenderer alloc] initWithCardMessage:cardMessage];
    cardMessageRenderer.delegate = self;
    [cardMessageRenderer show];
    [cardMessageRenderers setObject:cardMessageRenderer forKey:[NSValue valueWithNonretainedObject:message]];
    
    return YES;
    
}

#pragma mark --
#pragma mark GMMessageRendererDelegate

- (void) clickedButton:(GPButton *)button message:(GPMessage *)message {
    
    [[GrowthPush sharedInstance] selectButton:button message:message];
    [[GrowthPush sharedInstance] notifyClose];
    [cardMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
    
}

- (void)backgroundTouched:(GPMessage *)message {
    [[GrowthPush sharedInstance] notifyClose];
    [cardMessageRenderers removeObjectForKey:[NSValue valueWithNonretainedObject:message]];
}

@end
