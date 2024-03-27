//
//  GrowthPush.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growthbeat/Growthbeat.h>
#import <Growthbeat/GPEnvironment.h>
#import <Growthbeat/GPMessage.h>
#import <Growthbeat/GPMessageQueue.h>
#import <Growthbeat/GPButton.h>
#import <Growthbeat/GPShowMessageHandler.h>
#import <Growthbeat/GPTagType.h>
#import <Growthbeat/GPEventType.h>

#ifdef DEBUG
#define kGrowthPushEnvironment (GPEnvironmentDevelopment)
#else
#define kGrowthPushEnvironment (GPEnvironmentProduction)
#endif


@interface GrowthPush : NSObject {
    
    NSString *applicationId;
    NSString *credentialId;

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;
    NSMutableDictionary *showMessageHandlers;
    
}

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;
@property (nonatomic, strong) NSMutableDictionary *showMessageHandlers;


/**
 * Get shared instance of GrowthPush
 *
 */
+ (instancetype)sharedInstance;

/**
 * Initialize GrowthPush instance and register the client device if not yet been registered
 */
- (void)initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment;

/**
 * Initialize GrowthPush instance and register the client device if not yet been registered
 */
- (void) initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment adInfoEnable:(BOOL)adInfoEnable;

/**
 * Request APNS device token.
 * Internally call UIApplication's registerForRemoteNotificationTypes:
 */
- (void)requestDeviceToken;

/**
 * Set device token obtained in AppDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken:
 */
- (void)setDeviceToken:(id)deviceToken;

/**
 * Get enable remoete notification
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
- (void)trackEvent:(NSString *)name value:(NSString *)value showMessage:(void (^)(void(^renderMessage)()))showMessageHandler failure:(void (^)(NSString *detail))failureHandler;

- (void) selectButton:(GPButton *)button message:(GPMessage *)message;
- (void) notifyClose;


- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;
- (NSMutableDictionary *)showMessageHandlers;

@end
