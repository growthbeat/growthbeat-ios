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
#import "GPMessageQueue.h"
#import "GPButton.h"
#import "GPShowMessageHandler.h"
#import "GPTagType.h"
#import "GPEventType.h"

#ifdef DEBUG
#define kGrowthPushEnvironment (GPEnvironmentDevelopment)
#else
#define kGrowthPushEnvironment (GPEnvironmentProduction)
#endif


@interface GrowthPush : NSObject {
    
    NSString *applicationId;
    NSString *credentialId;
    NSArray *messageHandlers;

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

}

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;
@property (nonatomic, strong) NSArray *messageHandlers;

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;
@property (nonatomic, strong) GPMessageQueue *messageQueue;
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
- (void)initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment;

- (void)initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment adInfoEnable:(BOOL)adInfoEnable;

/**
 * Request APNS device token.
 * Internally call UIApplication's registerForRemoteNotificationTypes:
 */
- (void)requestDeviceToken;

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
- (void)setTag:(GPTagType)type name:(NSString *)name value:(NSString *)value;
/**
 * Set Event
 */
- (void)trackEvent:(NSString *)name;
- (void)trackEvent:(NSString *)name value:(NSString *)value;
- (void)trackEvent:(NSString *)name value:(NSString *)value messageHandler:(void (^)(void(^renderMessage)()))messageHandler failureHandler:(void (^)(NSString *detail))failureHandler;
- (void)trackEvent:(GPEventType)type name:(NSString *)name value:(NSString *)value messageHandler:(void (^)(void(^renderMessage)()))messageHandler failureHandler:(void (^)(NSString *detail))failureHandler;
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
- (NSMutableDictionary *)showMessageHandlers;

@end
