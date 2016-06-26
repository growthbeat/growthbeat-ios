//
//  Growthbeat.h
//  Growthbeat
//
//  Created by Shigeru Ogawa on 2016/01/29.
//  Copyright © 2016年 Shigeru Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Growthbeat.
FOUNDATION_EXPORT double GrowthbeatVersionNumber;

//! Project version string for Growthbeat.
FOUNDATION_EXPORT const unsigned char GrowthbeatVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Growthbeat/PublicHeader.h>

#import "GrowthbeatCore.h"
#import "GrowthAnalytics.h"
#import "GrowthMessage.h"
#import "GrowthPush.h"

@interface Growthbeat : NSObject {
    
    NSString *applicationId;
    NSString *credentialId;
    
}

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

+ (instancetype)sharedInstance;

- (void)initializeWithApplicationId:(NSString *)initialApplicationId credentialId:(NSString *)initialCredentialId;
- (void)initializeWithApplicationId:(NSString *)initialApplicationId credentialId:(NSString *)initialCredentialId adInfoEnable:(BOOL)adInfoEnable;

- (void)start;
- (void)stop;
- (void)setLoggerSilent:(BOOL)silent;
- (void) getClient:(void(^)(GBClient *client))callback;

@end
