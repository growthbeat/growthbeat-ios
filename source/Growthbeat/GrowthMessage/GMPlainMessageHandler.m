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
    if ([UIAlertController class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:plainMessage.caption message:plainMessage.text preferredStyle:UIAlertControllerStyleAlert];
        for (int i = 0; i < [plainMessage.buttons count]; i ++) {
            GMPlainButton *plainButton = (GMPlainButton *)[plainMessage.buttons objectAtIndex:i];
            UIAlertAction* action = [UIAlertAction actionWithTitle:plainButton.label style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                GMButton *button = [plainMessage.buttons objectAtIndex:(NSInteger)i];
                [[GrowthMessage sharedInstance] selectButton:button message:plainMessage];
                [alertController dismissViewControllerAnimated:YES completion:nil];
                
            }];
            [alertController addAction: action];
            
        }
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:[[[[UIApplication sharedApplication] delegate] window] bounds]];
        UIViewController *windowRootController = [[UIViewController alloc] init];
        window.rootViewController = windowRootController;
        [window makeKeyAndVisible];
        [windowRootController presentViewController:alertController animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
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
#pragma clang diagnostic pop
        
    }

    
    return YES;

}

#pragma mark --
#pragma mark UIAlertViewDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    GMPlainMessage *plainMessage = [plainMessages objectForKey:[NSValue valueWithNonretainedObject:alertView]];
    GMButton *button = [plainMessage.buttons objectAtIndex:buttonIndex];

    [[GrowthMessage sharedInstance] selectButton:button message:plainMessage];

    [plainMessages removeObjectForKey:[NSValue valueWithNonretainedObject:alertView]];

}

#pragma clang diagnostic pop

@end
