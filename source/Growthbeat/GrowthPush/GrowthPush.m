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
#import "GPTag.h"
#import "GPEvent.h"
#import "GPTask.h"
#import "GBDeviceUtils.h"
#import "GPMessageHandler.h"
#import "GPPlainMessageHandler.h"
#import "GPCardMessageHandler.h"
#import "GPSwipeMessageHandler.h"
#import "GPShowMessageHandler.h"
#import "GPMessage.h"
#import "GPNoContentMessage.h"

static GrowthPush *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthPush";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.growthpush.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthpush-preferences";
static NSString *const kGPPreferenceClientKey = @"growthpush-client";
static const NSTimeInterval kGPRegisterPollingInterval = 5.0f;
static const NSTimeInterval kMinWaitingTimeForOverrideMessage = 30.0f;
static const char * const kInternalQueueName = "com.growthpush.Queue";
const NSInteger kMaxQueueSize = 100;
const NSInteger kMessageTimeout = 10;
const CGFloat kDefaultMessageInterval = 1.0f;



@interface GrowthPush () {

    GPEnvironment environment;
    NSString *token;
    GBClient *growthbeatClient;
    GPClient *client;
    BOOL registeringClient;
    BOOL showingMessage;
    
    dispatch_queue_t _internalQueue;
    GPMessageQueue *messageQueue;
    CGFloat messageInterval;
    
    NSDate *lastMessageOpened;
    
    NSMutableDictionary *showMessageHandlers;
}

@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) GBClient *growthbeatClient;
@property (nonatomic, strong) GPClient *client;
@property (nonatomic, assign) BOOL registeringClient;
@property (nonatomic, assign) BOOL showingMessage;
@property (nonatomic, strong) NSMutableDictionary *showMessageHandlers;

@end

@implementation GrowthPush

@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize applicationId;
@synthesize credentialId;
@synthesize messageHandlers;

@synthesize environment;
@synthesize token;
@synthesize growthbeatClient;
@synthesize client;
@synthesize registeringClient;
@synthesize showingMessage;
@synthesize messageQueue;
@synthesize messageInterval;
@synthesize showMessageHandlers;

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
        self.messageQueue = [[GPMessageQueue alloc] initWithSize:kMaxQueueSize];
        self.messageInterval = kDefaultMessageInterval;
        self.showingMessage = NO;
        
        self.showMessageHandlers = [NSMutableDictionary dictionary];
        
        _internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment{

    self.client = [self loadClient];
    self.applicationId = newApplicationId;
    self.credentialId = newCredentialId;
    self.environment = newEnvironment;

    [self.logger info:@"Initializing... (applicationId:%@)", applicationId];

    [[Growthbeat sharedInstance] initializeWithApplicationId:applicationId credentialId:newCredentialId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        
        if (self.client && self.client.id &&
            ![self.client.id isEqualToString:self.growthbeatClient.id]) {
            [self.logger info:@"GrowthbeatClientId different.Clear cache.\n%@ , %@", self.client.id, self.growthbeatClient.id];
            [self clearClient];
        }
        
    });

    self.messageHandlers = [NSArray arrayWithObjects:[[GPPlainMessageHandler alloc] init],[[GPCardMessageHandler alloc] init], [[GPSwipeMessageHandler alloc] init], nil];

   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[Growthbeat sharedInstance] waitClient];
        [self registerClient];
        [self waitClient];

        [self setAdvertisingId];
        [self setTrackingEnabled];
        [self trackEvent:GPEventTypeDefault name:@"Install" value:nil messageHandler:nil failureHandler:nil];
    });

    
}

- (void) requestDeviceToken {

    if (![[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        return;
    }

    UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [self registerClient];

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
        self.growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        
        if (self.client && self.client.id &&
            ![self.client.id isEqualToString:self.growthbeatClient.id]) {
            [self.logger info:@"GrowthbeatClientId different.Clear cache.\n%@ , %@", self.client.id, self.growthbeatClient.id];
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

            GPClient *createdClient = [GPClient createWithClientId:self.growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId token:self.token environment:self.environment];
            if (createdClient) {
                [self.logger info:@"Create client success. (clientId: %@)", createdClient.id];
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

            GPClient *updatedClient = [GPClient updateWithClientId:self.growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId token:self.token environment:self.environment];
            if (updatedClient) {
                [self.logger info:@"Update client success. (clientId: %@)", updatedClient.id];
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
    [self setTag:GPTagTypeCustom name:name value:value];
}

- (void)setTag:(GPTagType)type name:(NSString *)name value:(NSString *)value {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self.logger info:@"Set Tag... (name: %@, value: %@)", name, value];
        
        GPTag *existingTag = [GPTag load:type name:name];
        if (existingTag) {
            if ((value == nil && existingTag.value == nil ) || (value && [value isEqualToString:existingTag.value])) {
                [self.logger info:@"Tag exists with the same value. (name: %@, value: %@)", name, value];
                return;
            }
            [self.logger info:@"Tag exists with the other value. (name: %@, value: %@)", name, value];
        }
        
        [self waitClient];
        GPTag *tag = [GPTag createWithGrowthbeatClient:self.growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId type:type name:name value:value];
        
        if (tag) {
            [GPTag save:tag type:type name:name];
            [self.logger info:@"Setting tag success. (name: %@)", name];
        }
        
    });
}

- (void) trackEvent:(NSString *)name {
    [self trackEvent:name value:nil];
}

- (void) trackEvent:(NSString *)name value:(NSString *)value {
    [self trackEvent:name value:value messageHandler:nil failureHandler:nil];
}

- (void)trackEvent:(NSString *)name value:(NSString *)value messageHandler:(void (^)(void(^renderMessage)()))messageHandler failureHandler:(void (^)(NSString *detail))failureHandler {
    [self trackEvent:GPEventTypeCustom name:name value:value messageHandler:messageHandler failureHandler:failureHandler];
}

- (void)trackEvent:(GPEventType)type name:(NSString *)name value:(NSString *)value messageHandler:(void (^)(void(^renderMessage)()))messageHandler failureHandler:(void (^)(NSString *detail))failureHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self.logger info:@"Set Event... (name: %@, value: %@)", name, value];
        
        [self waitClient];
        GPEvent *event = [GPEvent createWithGrowthbeatClient:self.growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId type:type name:name value:value];
        
        
        if (event) {
            [self.logger info:@"Setting event success. (name: %@)", name];
            if (type == GPEventTypeMessage || type == GPEventTypeUnknown) {
                return;
            }
            
            [self.logger info:@"Receive message..."];
            
            NSArray *taskArray = [GPTask getTasks:self.applicationId credentialId:self.credentialId goalId:event.goalId];
            if (!taskArray || taskArray.count == 0) {
                if (failureHandler) {
                    failureHandler(@"task not found");
                }
                return;
            }
            
            [self.logger info:[NSString stringWithFormat:@"Task exist %lu fro goalId: %ld", (unsigned long)taskArray.count, (long)event.goalId]];
            
            int count = 0;
            for (GPTask *task in taskArray) {
                GPMessage *message = [GPMessage receive:task.id applicationId:self.applicationId clientId:self.growthbeatClient.id credentialId:self.credentialId];
                
                if (!message || [message isKindOfClass:[GPNoContentMessage class]]) {
                    [[self logger] info:@"This message no target client."];
                    continue;
                }
                
                [self.messageQueue enqueue:message];
                
                if(messageHandler) {
                    GPShowMessageHandler *handler = [[GPShowMessageHandler alloc] initWithBlock:messageHandler];
                    
                    @synchronized (self.showMessageHandlers)
                    {
                        [self.showMessageHandlers setObject:handler forKey:message.id];
                    }
                }
                
                count = count + 1;
            }
            if (count == 0) {
                if (failureHandler) {
                    failureHandler(@"message not found");
                }
                return;
            }
            
            [self openMessageIfExists];
            
        } else {
            if (failureHandler) {
                failureHandler(@"event not found");
            }
            return;
        }
        
        
    });

}

- (void) openMessageIfExists {
    dispatch_async(_internalQueue, ^{
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:lastMessageOpened];
        if (self.showingMessage && diff < kMinWaitingTimeForOverrideMessage) {
            return;
        }
        GPMessage *message = [self.messageQueue dequeue];
        if (message) {
            self.showingMessage = YES;
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self openMessage:message];
            });
            lastMessageOpened = [NSDate date];
        }
    });
}


- (void) notifyClose {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [GrowthPush sharedInstance].messageInterval * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.showingMessage = NO;
        [self openMessageIfExists];
    });
}




- (void) openMessage:(GPMessage *)message {
    
    for (id<GPMessageHandler> handler in self.messageHandlers) {
        
        if (![handler handleMessage:message]) {
            continue;
        }
        
        [GPMessage receiveCount:self.growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId taskId:message.task.id messageId:message.id];
        
        break;
        
    }
    
}

- (void) selectButton:(GPButton *)button message:(GPMessage *)message {
    
    [[Growthbeat sharedInstance] handleIntent:button.intent];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (message.task.id) {
        [properties setObject:message.task.id forKey:@"taskId"];
    }
    if (message.id) {
        [properties setObject:message.id forKey:@"messageId"];
    }
    if (button.intent.id) {
        [properties setObject:button.intent.id forKey:@"intentId"];
    }
    
    NSString *value = nil;
    if([NSJSONSerialization isValidJSONObject:properties]){
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:properties options:NSJSONWritingPrettyPrinted error:&error];
        value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    [self trackEvent:@"SelectButton" value:value];
    
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

- (void) setAdvertisingId {
    [self setTag:GPTagTypeCustom name:@"AdvertisingID" value:[GBDeviceUtils getAdvertisingId]];
}

- (void) setTrackingEnabled {
    [self setTag:GPTagTypeCustom name:@"TrackingEnabled" value:[GBDeviceUtils getTrackingEnabled] ? @"true" : @"false"];
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
