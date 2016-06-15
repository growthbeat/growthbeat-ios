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
#import "GPMessage.h"
#import "GPQueue.h"
#import "GPButton.h"

#ifdef DEBUG
#define kGrowthPushEnvironment (GPEnvironmentDevelopment)
#else
#define kGrowthPushEnvironment (GPEnvironmentProduction)
#endif

#if NS_BLOCKS_AVAILABLE
typedef void (^ShowMessageHandler)(GPMessage *message, NSError *error);
#endif

@interface GrowthPush : NSObject {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;
@property (nonatomic, strong) GPQueue *messageQueue;
@property (nonatomic, assign) CGFloat messageInterval;


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
- (void)setDeviceToken:(id)deviceToken;

/**
 * Get enable remoete notification
 *
 * @param YES is notification enabled
 */
- (BOOL)enableNotification;

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
- (void)trackEvent:(NSString *)name value:(NSString *)value messageHandler:(ShowMessageHandler)messageHandler;

/**
 * Set DefaultTags
 */
- (void)setDeviceTags;

- (void) openMessageIfExists;
- (void) openMessage:(GPMessage *)message;
- (void) selectButton:(GPButton *)button message:(GPMessage *)message;
- (void) notifyClose;


- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

@end
