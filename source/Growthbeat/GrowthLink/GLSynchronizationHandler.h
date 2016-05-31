//
//  GLSynchronizationHandler.h
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2016/01/26.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLSynchronization.h"

@interface GLSynchronizationHandler : NSObject

@property (strong, nonatomic) UIWindow *window;

- (void)synchronizeWithCookie:(GLSynchronization *)synchronization;

- (BOOL)synchronizeWithFingerprint:(GLSynchronization *)synchronization;

- (void)removeWindowIfExists;

@end
