//
//  GBAppDelegateWrapper.h
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2013/07/14.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBAppDelegateWrapperDelegate.h"

@interface GBAppDelegateWrapper : UIResponder <UIApplicationDelegate>

@property (nonatomic, weak) id <GBAppDelegateWrapperDelegate> delegate;

- (void)setOriginalAppDelegate:(UIResponder <UIApplicationDelegate> *)newOriginalAppDelegate;

@end
