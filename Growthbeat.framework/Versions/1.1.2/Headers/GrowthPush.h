//
//  GrowthPush.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowthbeatCore.h"
#import "GPEnvironment.h"

#ifdef DEBUG
#define kGrowthPushEnvironment (GPEnvironmentDevelopment)
#else
#define kGrowthPushEnvironment (GPEnvironmentProduction)
#endif

@interface GrowthPush : NSObject

/**
 * Get shared instance of GrowthPush
 *
 */
+ (instancetype)sharedInstance;

/**
 * Initialize GrowthPush instance and register the client device if not yet been registered
 *
 * @param applicationId Application ID
 * @param credentialId Credential ID for application
 */
- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

/**
 * Request APNS device token.
 * Internally call UIApplication's registerForRemoteNotificationTypes:
 */
- (void)requestDeviceTokenWithEnvironment:(GPEnvironment)newEnvironment;

/**
 * Set device token obtained in AppDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken:
 *
 * @param deviceToken Device token
 */
- (void)setDeviceToken:(NSData *)deviceToken;

/**
 * Clear badge of app icon
 */
- (void)clearBadge;

/**
 * Set Tag
 */
- (void)setTag:(NSString *)name;
- (void)setTag:(NSString *)name value:(NSString *)value;

/**
 * Set Event
 */
- (void)trackEvent:(NSString *)name;
- (void)trackEvent:(NSString *)name value:(NSString *)value;

/**
 * Set DefaultTags
 */
- (void)setDeviceTags;


- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

@end
