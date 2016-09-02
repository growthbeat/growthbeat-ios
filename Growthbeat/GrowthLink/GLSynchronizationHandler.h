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

- (void)synchronizeByCookie:(GLSynchronization *)synchronization synchronizationUrl:(NSString *)synchronizationUrl;

- (BOOL)synchronizeByFingerprint:(GLSynchronization *)synchronization;

- (void)removeWindowIfExists;

@end
