//
//  GrowthPush.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowthPush.h"
#import "GPClientV4.h"
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
static NSString *const kGPPreferenceClientV4Key = @"growthpush-client-v4";
static const NSTimeInterval kGPRegisterPollingInterval = 5.0f;
static const NSTimeInterval kMinWaitingTimeForOverrideMessage = 30.0f;
static const char * const kInternalQueueName = "com.growthpush.Queue";
const NSInteger kMaxQueueSize = 100;
const NSInteger kMessageTimeout = 10;
const CGFloat kDefaultMessageInterval = 1.0f;

@interface GrowthPush () {

    GPEnvironment environment;
    GPClientV4 *client;
    NSArray *messageHandlers;
    BOOL registeringClient;
    BOOL showingMessage;
    
    dispatch_queue_t _internalQueue;
    GPMessageQueue *messageQueue;
    CGFloat messageInterval;
    
    NSDate *lastMessageOpened;
    
}

@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, strong) GPClientV4 *client;
@property (nonatomic, strong) NSArray *messageHandlers;
@property (nonatomic, assign) BOOL registeringClient;
@property (nonatomic, assign) BOOL showingMessage;
@property (nonatomic, assign) CGFloat messageInterval;
@property (nonatomic, strong) GPMessageQueue *messageQueue;

@end

@implementation GrowthPush

@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize applicationId;
@synthesize credentialId;
@synthesize messageHandlers;

@synthesize environment;
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
        GBClient *growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        
        if (self.client && self.client.id &&
            ![self.client.id isEqualToString:growthbeatClient.id]) {
            [self.logger info:@"GrowthbeatClientId different.Clear cache.\n%@ , %@", self.client.id, growthbeatClient.id];
            [self clearClient];
        }
        
    });

    self.messageHandlers = [NSArray arrayWithObjects:[[GPPlainMessageHandler alloc] init],[[GPCardMessageHandler alloc] init], [[GPSwipeMessageHandler alloc] init], nil];

   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self registerClient:nil];
        [self waitClient];

        [self setAdvertisingId];
        [self setTrackingEnabled];
        [self setDeviceTags];
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
    
}

- (BOOL) enableNotification {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone;
    } else {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }

}

- (void) setDeviceToken:(id)newDeviceToken {
    
    NSString __block *token = nil;
    if ([newDeviceToken isKindOfClass:[NSString class]])
        token = newDeviceToken;
    else
        token = [self convertToHexToken:newDeviceToken];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        GBClient *growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        
        if (self.client && self.client.id &&
            ![self.client.id isEqualToString:growthbeatClient.id]) {
            [self.logger info:@"GrowthbeatClientId different.Clear cache.\n%@ , %@", self.client.id, growthbeatClient.id];
            [self clearClient];
        }
        
        [self registerClient:token];
    });

}

- (void) clearBadge {

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

- (void) registerClient:(NSString *)token {


    if (self.environment == GPEnvironmentUnknown) {
        [self.logger info:@"Environment is not specified. Client has not registred."];
        return;
    }

    if (self.registeringClient) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGPRegisterPollingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self registerClient:token];
        });
        return;
    }
    self.registeringClient = YES;
    
    
    if (self.client && ((token && ![token isEqualToString:self.client.token]) || self.environment != self.client.environment)) {
        
        [self updateClient:token environment:self.environment];
        
        return;
        
    }
    
    GPClient *gbgpClient = [GPClient loadGBGPClient];
    if (gbgpClient && (!self.client || !self.client.token || ![self.client.token isEqualToString:gbgpClient.token] || self.client.environment != gbgpClient.environment)) {
        
        [self updateClient:gbgpClient.token environment:gbgpClient.environment];
        [GPClient removeGBGPClientPreference];
        
        return;
        
    }
    
    GPClient *gpClient = [[Growthbeat sharedInstance] gpClient];
    if (gpClient && (!self.client || !self.client.token || ![self.client.token isEqualToString:gpClient.token] || self.client.environment != gpClient.environment)) {
        
        [self updateClient:gpClient.token environment:gpClient.environment];
        
        return;
        
    }
    
    if (!self.client) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            GBClient *growthbeatClient = [[Growthbeat sharedInstance] waitClient];
            [self.logger info:@"Create client... (growthbeatClientId: %@, token: %@, environment: %@)", growthbeatClient.id, token, NSStringFromGPEnvironment(self.environment)];

            GPClientV4 *createdClient = [GPClientV4 createWithClientId:growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId token:token environment:self.environment];
            if (createdClient) {
                [self.logger info:@"Create client success. (clientId: %@)", createdClient.id];
                self.client = createdClient;
                [self saveClient:client];
            }

            self.registeringClient = NO;

        });
        
        return;

    }

    self.registeringClient = NO;
    [self.logger info:@"Client already registered."];

}

- (void) updateClient:(NSString *)newToken environment:(GPEnvironment) newEnvironment {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        GBClient *growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        [self.logger info:@"Update client... (growthbeatClientId: %@, token: %@, environment: %@)", growthbeatClient.id, newToken, NSStringFromGPEnvironment(newEnvironment)];
        
        GPClientV4 *updatedClient = [GPClientV4 updateWithClientId:growthbeatClient.id applicationId:self.applicationId credentialId:self.credentialId token:newToken environment:newEnvironment];
        if (updatedClient) {
            [self.logger info:@"Update client success. (clientId: %@)", updatedClient.id];
            self.client = updatedClient;
            [self saveClient:self.client];
        }
        
        self.registeringClient = NO;
        
    });
    
}

- (GPClientV4 *) loadClient {

    return [self.preference objectForKey:kGPPreferenceClientV4Key];

}

- (void) saveClient:(GPClientV4 *)newClient {

    [self.preference setObject:newClient forKey:kGPPreferenceClientV4Key];

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
        
        GPTag *tag = [GPTag createWithGrowthbeatClient:[[self waitClient] id] applicationId:self.applicationId credentialId:self.credentialId type:type name:name value:value];
        
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
    [self trackEvent:name value:value showMessage:nil failure:nil];
}

- (void)trackEvent:(NSString *)name value:(NSString *)value showMessage:(void (^)(void(^renderMessage)()))showMessageHandler failure:(void (^)(NSString *detail))failureHandler {
    [self trackEvent:GPEventTypeCustom name:name value:value showMessage:showMessageHandler failure:failureHandler];
}

- (void)trackEvent:(GPEventType)type name:(NSString *)name value:(NSString *)value showMessage:(void (^)(void(^renderMessage)()))showMessageHandler failure:(void (^)(NSString *detail))failureHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self.logger info:@"Set Event... (name: %@, value: %@)", name, value];
        
        GPClientV4 *clientV4 = [self waitClient];
        GPEvent *event = [GPEvent createWithGrowthbeatClient:clientV4.id applicationId:self.applicationId credentialId:self.credentialId type:type name:name value:value];
        
        
        if (event) {
            [self.logger info:@"Setting event success. (name: %@)", name];
            if (type == GPEventTypeMessage || type == GPEventTypeUnknown) {
                return;
            }
            
            [self receiveMessage:event showMessage:showMessageHandler failure:failureHandler];
            
        } else {
            if (failureHandler) {
                failureHandler(@"event not found");
            }
            return;
        }
        
        
    });

}

- (void) receiveMessage:(GPEvent *)event showMessage:(void (^)(void(^renderMessage)()))showMessageHandler failure:(void (^)(NSString *detail))failureHandler {
    
    [self.logger info:@"Receive message..."];
    
    NSArray *taskArray = [GPTask getTasks:self.applicationId credentialId:self.credentialId goalId:event.goalId];
    if (!taskArray || taskArray.count == 0) {
        if (failureHandler) {
            failureHandler(@"task not found");
        }
        return;
    }
    
    [self.logger info:[NSString stringWithFormat:@"Task exist %lu from goalId: %ld", (unsigned long)taskArray.count, (long)event.goalId]];
    
    int count = 0;
    for (GPTask *task in taskArray) {
        GPMessage *message = [GPMessage receive:task.id applicationId:self.applicationId clientId:self.client.id credentialId:self.credentialId];
        
        if (!message || [message isKindOfClass:[GPNoContentMessage class]]) {
            [[self logger] info:@"This message no target client."];
            continue;
        }
        
        [self.messageQueue enqueue:message];
        
        if(showMessageHandler) {
            GPShowMessageHandler *handler = [[GPShowMessageHandler alloc] initWithBlock:showMessageHandler];
            
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
        
        [GPMessage receiveCount:[[self waitClient] id] applicationId:self.applicationId credentialId:self.credentialId taskId:message.task.id messageId:message.id];
        
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

- (GPClientV4 *) waitClient {

    while (true) {
        if (self.client != nil) {
            return self.client;
        }
        usleep(100 * 1000);
    }

}

@end
