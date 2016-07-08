//
//  GrowthPush.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Growthbeat.h"
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
 *
 * @param applicationId Application ID
 * @param credentialId Credential ID for application
 */
- (void)initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment;

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
 * Set DefaultTags
 */
- (void)setDeviceTags;

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
