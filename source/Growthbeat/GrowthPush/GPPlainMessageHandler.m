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
#import "GPPlainMessage.h"
#import "GPPlainButton.h"
#import "GPButton.h"
#import "GrowthPush.h"
#import "GBViewUtils.h"

@interface GPPlainMessageHandler () {
    
    NSMutableDictionary *plainMessages;
    
}
@property (nonatomic, strong) NSMutableDictionary *plainMessages;
@property (nonatomic, strong) UIWindow *alertWindow;

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
    
    void(^renderCallback)(void) = ^() {
        [self generateAlertView:plainMessage];
    };
    
    GPShowMessageHandler *showMessageHandler = [[[GrowthPush sharedInstance] showMessageHandlers] objectForKey:plainMessage.id];
    if(showMessageHandler) {
        showMessageHandler.handleMessage(^{
            renderCallback();
        });
    } else {
        renderCallback();
    }
    
    return YES;
    
}

- (void) generateAlertView:(GPPlainMessage *)plainMessage {
    
    if ([UIAlertController class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:plainMessage.caption message:plainMessage.text preferredStyle:UIAlertControllerStyleAlert];
        for (int i = 0; i < [plainMessage.buttons count]; i ++) {
            GPPlainButton *plainButton = (GPPlainButton *)[plainMessage.buttons objectAtIndex:i];
            UIAlertAction* action = [UIAlertAction actionWithTitle:plainButton.label style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                GPButton *button = [plainMessage.buttons objectAtIndex:(NSInteger)i];
                [[GrowthPush sharedInstance] selectButton:button message:plainMessage];
                [[GrowthPush sharedInstance] notifyClose];
                [alertController dismissViewControllerAnimated:YES completion:nil];
                self.alertWindow.hidden = YES;
                self.alertWindow = nil;
                
            }];
            [alertController addAction: action];
        }
        
        self.alertWindow = [[UIWindow alloc] initWithFrame:[[GBViewUtils getWindow] bounds]];
        
        UIViewController *windowRootController = [[UIViewController alloc] init];
        self.alertWindow .rootViewController = windowRootController;
        [self.alertWindow  makeKeyAndVisible];
        [windowRootController presentViewController:alertController animated:YES completion:nil];
        
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
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
#pragma clang diagnostic pop
        
    }
}

#pragma mark --
#pragma mark UIAlertViewDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    GPPlainMessage *plainMessage = [plainMessages objectForKey:[NSValue valueWithNonretainedObject:alertView]];
    GPButton *button = [plainMessage.buttons objectAtIndex:buttonIndex];
    
    [[GrowthPush sharedInstance] selectButton:button message:plainMessage];
    [[GrowthPush sharedInstance] notifyClose];
    [plainMessages removeObjectForKey:[NSValue valueWithNonretainedObject:alertView]];
    
}

#pragma clang diagnostic pop

@end

