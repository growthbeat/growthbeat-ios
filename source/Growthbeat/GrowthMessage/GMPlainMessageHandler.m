//
//  GMPlainMessageHandler.m
//  GrowthMessage
//
//  Created by 堀内 暢之 on 2015/03/03.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMPlainMessageHandler.h"
#import "GMPlainMessage.h"
#import "GMPlainButton.h"

@interface GMPlainMessageHandler () {

    NSMutableDictionary *plainMessages;

}

@property (nonatomic, strong) NSMutableDictionary *plainMessages;

@end

@implementation GMPlainMessageHandler

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

- (BOOL) handleMessage:(GMMessage *)message {

    if (message.type != GMMessageTypePlain) {
        return NO;
    }

    if (![message isKindOfClass:[GMPlainMessage class]]) {
        return NO;
    }

    GMPlainMessage *plainMessage = (GMPlainMessage *)message;

    UIAlertView *alertView = [[UIAlertView alloc] init];
    [plainMessages setObject:plainMessage forKey:[NSValue valueWithNonretainedObject:alertView]];

    alertView.delegate = self;
    alertView.title = plainMessage.caption;
    alertView.message = plainMessage.text;

    for (GMButton *button in plainMessage.buttons) {
        GMPlainButton *plainButton = (GMPlainButton *)button;
        [alertView addButtonWithTitle:plainButton.label];
    }

    [alertView show];

    return YES;

}

#pragma mark --
#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    GMPlainMessage *plainMessage = [plainMessages objectForKey:[NSValue valueWithNonretainedObject:alertView]];
    GMButton *button = [plainMessage.buttons objectAtIndex:buttonIndex];

    [[GrowthMessage sharedInstance] selectButton:button message:plainMessage];

    [plainMessages removeObjectForKey:[NSValue valueWithNonretainedObject:alertView]];

}

@end
