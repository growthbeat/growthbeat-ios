//
//  GrowthPush.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowthPush.h"
#import "GPClient.h"
#import "GrowthAnalytics.h"
#import "GPTag.h"
#import "GPEvent.h"
#import "GBDeviceUtils.h"

static GrowthPush *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthPush";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.growthpush.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthpush-preferences";
static NSString *const kGPPreferenceClientKey = @"growthpush-client";
static const NSTimeInterval kGPRegisterPollingInterval = 5.0f;

@interface GrowthPush () {

    GPEnvironment environment;
    NSString *token;
    GBClient *growthbeatClient;
    GPClient *client;
    BOOL registeringClient;

}

@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) GBClient *growthbeatClient;
@property (nonatomic, strong) GPClient *client;
@property (nonatomic, assign) BOOL registeringClient;

@end

@implementation GrowthPush

@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize credentialId;
@synthesize environment;
@synthesize token;
@synthesize growthbeatClient;
@synthesize client;
@synthesize registeringClient;

+ (instancetype) sharedInstance {
    @synchronized(self) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) {
            return nil;
        }
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (id) init {
    self = [super init];
    if (self) {
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl] timeout:kGBHttpClientDefaultTimeout];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
        self.environment = GPEnvironmentUnknown;
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)newCredentialId {

    self.credentialId = newCredentialId;
    self.client = [self loadClient];

    [self.logger info:@"Initializing... (applicationId:%@)", applicationId];

    [[GrowthbeatCore sharedInstance] initializeWithApplicationId:applicationId credentialId:self.credentialId];

}

- (void) requestDeviceTokenWithEnvironment:(GPEnvironment)newEnvironment {

    self.environment = newEnvironment;

    if (![[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        return;
    }

    UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

}

- (BOOL) enableNotification {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone;
    } else {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }

}

- (void) setDeviceToken:(id)newDeviceToken {

    if ([newDeviceToken isKindOfClass:[NSString class]])
        self.token = newDeviceToken;
    else
        self.token = [self convertToHexToken:newDeviceToken];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.growthbeatClient = [[GrowthbeatCore sharedInstance] waitClient];
        
        if (self.client && self.client.growthbeatClientId &&
            ![self.client.growthbeatClientId isEqualToString:self.growthbeatClient.id]) {
            [self.logger info:@"GrowthbeatClientId different.Clear cache.\n%@ , %@", self.client.growthbeatClientId, self.growthbeatClient.id];
            [self clearClient];
        }
        
        [self registerClient];
    });

}

- (void) clearBadge {

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

- (void) registerClient {

    if (self.environment == GPEnvironmentUnknown) {
        [self.logger info:@"Environment is not specified. Client has not registred."];
        return;
    }

    if (self.registeringClient) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGPRegisterPollingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self registerClient];
        });
        return;
    }
    self.registeringClient = YES;

    if (!self.client) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            [self.logger info:@"Create client... (growthbeatClientId: %@, token: %@, environment: %@)", self.growthbeatClient.id, self.token, NSStringFromGPEnvironment(self.environment)];

            GPClient *createdClient = [GPClient createWithClientId:self.growthbeatClient.id credentialId:self.credentialId token:self.token environment:self.environment];
            if (createdClient) {
                [self.logger info:@"Create client success. (clientId: %@)", createdClient.growthbeatClientId];
                self.client = createdClient;
                [self saveClient:client];
            }

            self.registeringClient = NO;

        });

        return;

    }

    if ((self.token != self.client.token &&
        ![self.token isEqualToString:self.client.token]) || self.environment != self.client.environment) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            [self.logger info:@"Update client... (growthbeatClientId: %@, token: %@, environment: %@)", self.growthbeatClient.id, self.token, NSStringFromGPEnvironment(self.environment)];

            GPClient *updatedClient = [GPClient updateWithClientId:self.growthbeatClient.id credentialId:self.credentialId token:self.token environment:self.environment];
            if (updatedClient) {
                [self.logger info:@"Update client success. (clientId: %@)", updatedClient.growthbeatClientId];
                self.client = updatedClient;
                [self saveClient:self.client];
            }

            self.registeringClient = NO;

        });

        return;

    }

    [self.logger info:@"Client already registered."];

}

- (GPClient *) loadClient {

    return [self.preference objectForKey:kGPPreferenceClientKey];

}

- (void) saveClient:(GPClient *)newClient {

    [self.preference setObject:newClient forKey:kGPPreferenceClientKey];

}

- (void) clearClient {

    self.client = nil;
    [preference removeAll];

}

- (NSString *) convertToHexToken:(NSData *)targetDeviceToken {

    if (!targetDeviceToken) {
        return nil;
    }

    return [[[[targetDeviceToken description]
              stringByReplacingOccurrencesOfString:@"<" withString:@""]
             stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];

}

- (void) setTag:(NSString *)name {
    [self setTag:name value:nil];
}

- (void) setTag:(NSString *)name value:(NSString *)value {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [self.logger info:@"Set Tag... (name: %@, value: %@)", name, value];

        GPTag *existingTag = [GPTag load:name];
        if (existingTag) {
            if (value && [value isEqualToString:existingTag.value]) {
                [self.logger info:@"Tag exists with the same value. (name: %@, value: %@)", name, value];
                return;
            }
            [self.logger info:@"Tag exists with the other value. (name: %@, value: %@)", name, value];
        }

        [self waitClient];
        GPTag *tag = [GPTag createWithGrowthbeatClient:self.growthbeatClient.id credentialId:self.credentialId name:name value:value];

        if (tag) {
            [GPTag save:tag name:name];
            [self.logger info:@"Setting tag success. (name: %@)", name];
        }

    });

}

- (void) trackEvent:(NSString *)name {
    [self trackEvent:name value:nil];
}

- (void) trackEvent:(NSString *)name value:(NSString *)value {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [self.logger info:@"Set Event... (name: %@, value: %@)", name, value];

        [self waitClient];
        GPEvent *event = [GPEvent createWithGrowthbeatClient:self.growthbeatClient.id credentialId:self.credentialId name:name value:value];

        if (event) {
            [self.logger info:@"Setting event success. (name: %@)", name];
        }

    });

}

- (void) setDeviceTags {

    if ([GBDeviceUtils model]) {
        [self setTag:@"Device" value:[GBDeviceUtils model]];
    }
    if ([GBDeviceUtils os]) {
        [self setTag:@"OS" value:[GBDeviceUtils os]];
    }
    if ([GBDeviceUtils language]) {
        [self setTag:@"Language" value:[GBDeviceUtils language]];
    }
    if ([GBDeviceUtils timeZone]) {
        [self setTag:@"Time Zone" value:[GBDeviceUtils timeZone]];
    }
    if ([GBDeviceUtils version]) {
        [self setTag:@"Version" value:[GBDeviceUtils version]];
    }
    if ([GBDeviceUtils build]) {
        [self setTag:@"Build" value:[GBDeviceUtils build]];
    }

}

- (GPClient *) waitClient {

    while (true) {
        if (self.client != nil) {
            return self.client;
        }
        usleep(100 * 1000);
    }

}

@end
