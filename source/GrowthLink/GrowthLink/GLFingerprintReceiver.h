//
//  FingerprintReceiver.h
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2015/09/07.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

@interface GLFingerprintReceiver : NSObject <UIWebViewDelegate>
- (void) getFingerPrint:(UIWindow *)window fingerprintUrl:(NSString*)fingerprintUrl argBlock:(void(^)(NSString *fingerprintParameters))argBlock;
@end
