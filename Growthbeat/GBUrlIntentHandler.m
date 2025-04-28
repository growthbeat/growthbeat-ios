//
//  GBUrlIntentHandler.m
//  GrowthbeatCore
//
//  Created by 堀内 暢之 on 2015/03/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBUrlIntentHandler.h>
#import <UIKit/UIKit.h>
#import <Growthbeat/Growthbeat.h>
#import <Growthbeat/GBUrlIntent.h>

@implementation GBUrlIntentHandler

- (BOOL) handleIntent:(GBIntent *)intent {

    if (intent.type != GBIntentTypeUrl) {
        return NO;
    }

    if (![intent isKindOfClass:[GBUrlIntent class]]) {
        return NO;
    }

    GBUrlIntent *urlIntent = (GBUrlIntent *)intent;

    NSURL *url = [NSURL URLWithString:urlIntent.url];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
    }];
    return YES;

}

@end
