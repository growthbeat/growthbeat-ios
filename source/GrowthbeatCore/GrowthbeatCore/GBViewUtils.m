//
//  GBViewUtils.m
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/09/10.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBViewUtils.h"

@implementation GBViewUtils

+ (UIWindow *)getWindow {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    return window;
    
}

@end
