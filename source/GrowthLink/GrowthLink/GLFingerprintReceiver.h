//
//  GLFingerprintReceiver.h
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2015/09/07.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GLFingerprintReceiver : NSObject <UIWebViewDelegate>

- (void)getFingerprintParametersWithFingerprintUrl:(NSString *)fingerprintUrl completion:(void(^)(NSString * fingerprintParameters))completion;

@end
