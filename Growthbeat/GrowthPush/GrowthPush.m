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
#import "GPShowMessageCount.h"
#import "GPNoContentMessage.h"
#import "GPClient.h"

static GrowthPush *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthPush";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.growthpush.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthpush-preferences";
static const char * const kAnalyticsQueueName = "com.growthpush.queue.analytics";

static const NSTimeInterval kMinWaitingTimeForOverrideMessage = 30.0f;
static const char * const kMessageQueueName = "com.growthpush.queue.message";
const NSInteger kMaxQueueSize = 100;
const NSInteger kMessageTimeout = 10;
const CGFloat kDefaultMessageInterval = 1.0f;

@interface GrowthPush () {

    GPEnvironment environment;
    GPClientV4 *client;
    dispatch_semaphore_t semaphore;
    dispatch_queue_t analyticsDispatchQueue;
    NSArray *messageHandlers;
    BOOL initialized;
    BOOL showingMessage;

    GPMessageQueue *messageQueue;
    dispatch_queue_t messageDispatchQueue;
    CGFloat messageInterval;
    NSDate *lastMessageOpened;
    
}

@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, strong) GPClientV4 *client;
@property (nonatomic, strong) NSArray *messageHandlers;
@property (nonatomic, assign) BOOL showingMessage;
@property (nonatomic, strong) NSMutableArray *requestListener;

@end

@implementation GrowthPush

@synthesize applicationId;
@synthesize credentialId;
@synthesize logger;
@synthesize httpClient;
@synthesize preference;
@synthesize showMessageHandlers;

@synthesize environment;
@synthesize client;
@synthesize messageHandlers;
@synthesize showingMessage;
@synthesize requestListener;

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
        semaphore = dispatch_semaphore_create(1);
        analyticsDispatchQueue = dispatch_queue_create(kAnalyticsQueueName, DISPATCH_QUEUE_SERIAL);
        self.showingMessage = NO;
        self.showMessageHandlers = [NSMutableDictionary dictionary];
        
        initialized = NO;
        messageDispatchQueue = dispatch_queue_create(kMessageQueueName, DISPATCH_QUEUE_SERIAL);
        messageQueue = [[GPMessageQueue alloc] initWithSize:kMaxQueueSize];
        messageInterval = kDefaultMessageInterval;
        self.requestListener = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"client" options:NSKeyValueObservingOptionNew context:nil];

    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment {
    [self initializeWithApplicationId:newApplicationId credentialId:newCredentialId environment:newEnvironment adInfoEnable:YES];
}

- (void) initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId environment:(GPEnvironment)newEnvironment adInfoEnable:(BOOL)adInfoEnable {
    
    if(initialized) {
        return;
    }
    
    initialized = YES;

    self.applicationId = newApplicationId;
    self.credentialId = newCredentialId;
    self.environment = newEnvironment;

    [self.logger info:@"Initializing... (applicationId:%@)", applicationId];

    [[Growthbeat sharedInstance] initializeWithApplicationId:applicationId credentialId:newCredentialId];

    self.messageHandlers = [NSArray arrayWithObjects:[[GPPlainMessageHandler alloc] init],[[GPCardMessageHandler alloc] init], [[GPSwipeMessageHandler alloc] init], nil];

   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        GBClient *growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        GPClient *gpClient = [GPClient load];

        if (gpClient) {
            if (gpClient.growthbeatClientId && [gpClient.growthbeatClientId isEqualToString:growthbeatClient.id]) {
                [[self logger] info:[NSString stringWithFormat:@"Client found. To Convert the Client to ClientV4. (id:%@)", gpClient.growthbeatClientId]];
                [self createClient:gpClient.growthbeatClientId token:gpClient.token];
            } else {
                [[self logger] info:[NSString stringWithFormat:@"Disabled Client found. Create a new ClientV4. (id:%@)", growthbeatClient.id]];
                [self.preference removeAll];
                [self createClient:growthbeatClient.id token:nil];
            }
            
            [GPClient removePreference];
            
        } else {
            
            GPClientV4 *clientV4 = [GPClientV4 load];
            if(!clientV4) {
                [[self logger] info:[NSString stringWithFormat:@"Create new ClientV4. (id: %@)", growthbeatClient.id]];
                [self.preference removeAll];
                [self createClient:growthbeatClient.id token:nil];
            } else if (![clientV4.id isEqualToString:growthbeatClient.id]) {
                [self.logger info:@"Disabled ClientV4 found. Create a new ClientV4. (id: %@)", growthbeatClient.id];
                [self.preference removeAll];
                [self clearClient];
                [self createClient:growthbeatClient.id token:nil];
            } else if (clientV4.environment != environment) {
                [self.logger info:@"ClientV4 found. Update environment. (environment: %@)", NSStringFromGPEnvironment(environment)];
                [self updateClient:growthbeatClient.id token:clientV4.token];
            } else {
                [self.logger info:@"ClientV4 found. (id: %@)", clientV4.id];
                self.client = clientV4;
            }
            
        }

        if(adInfoEnable) {
            [self setAdvertisingId];
            [self setTrackingEnabled];
        }
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
        
        if (self.environment == GPEnvironmentUnknown) {
            [self.logger info:@"Environment is not specified. Client has not registred."];
            return;
        }
        
        [self waitClient];
        
        GBClient *growthbeatClient = [[Growthbeat sharedInstance] waitClient];
        if ((self.client && ((token && ![token isEqualToString:self.client.token])))) {
            [self updateClient:growthbeatClient.id token:token];
        }

    });

}

- (void) clearBadge {

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

- (void) createClient:(NSString *)growthbeatClientId token:(NSString *)token {
 
    GPClientV4 *clientV4 = [GPClientV4 load];
    if(clientV4) {
        [self.logger info:[NSString stringWithFormat:@"ClientV4 already created. (growthbeatClientId: %@, token: %@, environment: %@)", clientV4.id, clientV4.token, NSStringFromGPEnvironment(clientV4.environment)]];
        return;
    }
    
    [self.logger info:@"Create client... (growthbeatClientId: %@, token: %@, environment: %@)", growthbeatClientId, token, NSStringFromGPEnvironment(self.environment)];
    GPClientV4 *createdClient = [GPClientV4 attachClient:growthbeatClientId applicationId:self.applicationId credentialId:self.credentialId token:token environment:self.environment];
    if (createdClient) {
        [self.logger info:@"Create client success. (clientId: %@)", createdClient.id];
        self.client = createdClient;
        [GPClientV4 save:createdClient];
    }
    
}

- (void) updateClient:(NSString *)growthbeatClientId token:(NSString *)newToken {
    
    [self.logger info:@"Update client... (growthbeatClientId: %@, token: %@, environment: %@)", growthbeatClientId, newToken, NSStringFromGPEnvironment(self.environment)];
    
    GPClientV4 *updatedClient = [GPClientV4 attachClient:growthbeatClientId applicationId:self.applicationId credentialId:self.credentialId token:newToken environment:self.environment];
    if (updatedClient) {
        [self.logger info:@"Update client success. (clientId: %@)", updatedClient.id];
        self.client = updatedClient;
        [GPClientV4 save:updatedClient];
    }
    
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"client"] && self.client != nil) {
        for (void (^listener)() in self.requestListener) {
            listener();
        }
        [self.requestListener removeAllObjects];
    }
}

- (void) setTag:(NSString *)name {
    [self setTag:name value:nil];
}

- (void) setTag:(NSString *)name value:(NSString *)value {
    [self setTag:GPTagTypeCustom name:name value:value];
}

- (void)setTag:(GPTagType)type name:(NSString *)name value:(NSString *)value {
    
     void (^request)() = ^{
         [self synchronizeSetTag:type name:name value:value];
     };
    
    if(self.client) {
        dispatch_async(analyticsDispatchQueue, request);
    } else{
        [self.requestListener addObject:request];
    }
}

- (void)synchronizeSetTag:(GPTagType)type name:(NSString *)name value:(NSString *)value {
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
        [self.logger info:@"Setting tag success. (name: %@, value: %@)", name, value];
    }
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
    
    if(!name) {
        [logger warn:@"Event name cannot be empty."];
        return;
    }
    
    void (^request)() = ^{
        [self.logger info:@"Set Event... (name: %@, value: %@)", name, value];
        
        GPEvent *event = [GPEvent createWithGrowthbeatClient:[[self waitClient] id] applicationId:self.applicationId credentialId:self.credentialId type:type name:name value:value];
        
        if (event) {
            [self.logger info:@"Setting event success. (name: %@, value: %@)", name, value];
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
    };
    
    if(self.client) {
        dispatch_async(analyticsDispatchQueue, request);
    } else{
        [self.requestListener addObject:request];
    }

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
        
        [messageQueue enqueue:message];
        
        if(showMessageHandler) {
            GPShowMessageHandler *handler = [[GPShowMessageHandler alloc] initWithBlock:showMessageHandler];
            @synchronized (self.showMessageHandlers) {
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
    dispatch_async(messageDispatchQueue, ^{
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:lastMessageOpened];
        if (self.showingMessage && diff < kMinWaitingTimeForOverrideMessage) {
            return;
        }
        GPMessage *message = [messageQueue dequeue];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, messageInterval * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.showingMessage = NO;
        [self openMessageIfExists];
    });
}




- (void) openMessage:(GPMessage *)message {
    
    for (id<GPMessageHandler> handler in self.messageHandlers) {
        
        if (![handler handleMessage:message]) {
            continue;
        }
        
        GPShowMessageCount *showMessageCount = [GPShowMessageCount receiveCount:[[self waitClient] id] applicationId:self.applicationId credentialId:self.credentialId taskId:message.task.id messageId:message.id];
        [[self logger] info:[NSString stringWithFormat:@"Success show message (count: %ld, messageId: %@, taskId: %@)", (long) showMessageCount.count, showMessageCount.messageId, showMessageCount.taskId]];
        
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

    [self trackEvent:GPEventTypeMessage name:@"SelectButton" value:value showMessage:nil failure:nil];
    
}

- (void) setDeviceTags {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([GBDeviceUtils model]) {
        [params setObject:[GBDeviceUtils model] forKey:@"Device"];
    }
    if ([GBDeviceUtils os]) {
        [params setObject:[GBDeviceUtils os] forKey:@"OS"];
    }
    if ([GBDeviceUtils language]) {
        [params setObject:[GBDeviceUtils language] forKey:@"Language"];
    }
    if ([GBDeviceUtils timeZone]) {
        [params setObject:[GBDeviceUtils timeZone] forKey:@"Time Zone"];
    }
    if ([GBDeviceUtils version]) {
        [params setObject:[GBDeviceUtils version] forKey:@"Version"];
    }
    if ([GBDeviceUtils build]) {
        [params setObject:[GBDeviceUtils build] forKey:@"Build"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self waitClient];
        
        for(id key in [params keyEnumerator]) {
            id value = [params objectForKey:key];
            [self synchronizeSetTag:GPTagTypeCustom name:key value:value];
            usleep(500 * 1000);
        }
    });
    
}

- (void) setAdvertisingId {
    [self setTag:@"AdvertisingID" value:[GBDeviceUtils getAdvertisingId]];
}

- (void) setTrackingEnabled {
    [self setTag:@"TrackingEnabled" value:[GBDeviceUtils getTrackingEnabled] ? @"true" : @"false"];
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
