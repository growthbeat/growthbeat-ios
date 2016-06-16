//
//  GPPlainMessageHandler.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPPlainMessageHandler.h"
#import "GPPlainMessage.h"
#import "GPMessageType.h"
#import "GPPlainButton.h"
#import "GrowthPush.h"

@interface GPPlainMessageHandler () {
    
    NSMutableDictionary *plainMessages;
    
}
@property (nonatomic, strong) NSMutableDictionary *plainMessages;

@end

@implementation GPPlainMessageHandler
@synthesize plainMessages;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.plainMessages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark --
#pragma mark GMMessageHandler

- (BOOL) handleMessage:(GPMessage *)message {
    
    if (message.type != GPMessageTypePlain) {
        return NO;
    }
    
    if (![message isKindOfClass:[GPPlainMessage class]]) {
        return NO;
    }
    
    GPPlainMessage *plainMessage = (GPPlainMessage *)message;
    
    UIAlertView *alertView = [[UIAlertView alloc] init];
    [plainMessages setObject:plainMessage forKey:[NSValue valueWithNonretainedObject:alertView]];
    
    alertView.delegate = self;
    alertView.title = plainMessage.caption;
    alertView.message = plainMessage.text;
    
    for (GPButton *button in plainMessage.buttons) {
        GPPlainButton *plainButton = (GPPlainButton *)button;
        [alertView addButtonWithTitle:plainButton.label];
    }
    
    [alertView show];
    
    return YES;
    
}

#pragma mark --
#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    GPPlainMessage *plainMessage = [plainMessages objectForKey:[NSValue valueWithNonretainedObject:alertView]];
    GPButton *button = [plainMessage.buttons objectAtIndex:buttonIndex];
    
    [[GrowthPush sharedInstance] selectButton:button message:plainMessage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [GrowthPush sharedInstance].messageInterval * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[GrowthPush sharedInstance] notifyClose];
        [[GrowthPush sharedInstance] openMessageIfExists];
    });
    [plainMessages removeObjectForKey:[NSValue valueWithNonretainedObject:alertView]];
    
}

@end

