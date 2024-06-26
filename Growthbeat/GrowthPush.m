//
//  GrowthPush.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Growthbeat/GrowthPush.h>
#import <Growthbeat/GPClientV4.h>
#import <Growthbeat/GPTag.h>
#import <Growthbeat/GPEvent.h>
#import <Growthbeat/GPTask.h>
#import <Growthbeat/GBDeviceUtils.h>
#import <Growthbeat/GPMessageHandler.h>
#import <Growthbeat/GPPlainMessageHandler.h>
#import <Growthbeat/GPCardMessageHandler.h>
#import <Growthbeat/GPSwipeMessageHandler.h>
#import <Growthbeat/GPShowMessageHandler.h>
#import <Growthbeat/GPMessage.h>
#import <Growthbeat/GPShowMessageCount.h>
#import <Growthbeat/GPNoContentMessage.h>
#import <Growthbeat/GPClient.h>

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
    NSMutableArray *pendingRequests;
    
}

@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, strong) GPClientV4 *client;
@property (nonatomic, strong) NSArray *messageHandlers;
@property (nonatomic, assign) BOOL showingMessage;

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
        pendingRequests = [NSMutableArray array];

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
                [preference removeAll];
                [self createClient:growthbeatClient.id token:nil];
            }
            
            [GPClient removePreference];
            
        } else {
            
            GPClientV4 *clientV4 = [GPClientV4 load];
            if(!clientV4) {
                [[self logger] info:[NSString stringWithFormat:@"Create new ClientV4. (id: %@)", growthbeatClient.id]];
                [preference removeAll];
                [self createClient:growthbeatClient.id token:nil];
            } else if (![clientV4.id isEqualToString:growthbeatClient.id]) {
                [self.logger info:@"Disabled ClientV4 found. Create a new ClientV4. (id: %@)", growthbeatClient.id];
                [preference removeAll];
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
            [self.logger info:@"AdvertisingId and TrackingEnabled not supported."];
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

- (NSString *) hexadecimalStringFromData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }

    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

- (NSString *) convertToHexToken:(NSData *)targetDeviceToken {
    
    if (!targetDeviceToken) {
        return nil;
    }

    return [self hexadecimalStringFromData:targetDeviceToken];
}


- (void) clearBadge {

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

- (void) createClient:(NSString *)growthbeatClientId token:(NSString *)token {
    
    @synchronized(self) {
        
        GPClientV4 *clientV4 = [GPClientV4 load];
        if(clientV4) {
            [self.logger info:[NSString stringWithFormat:@"ClientV4 already created. (growthbeatClientId: %@, token: %@, environment: %@)", clientV4.id, clientV4.token, NSStringFromGPEnvironment(clientV4.environment)]];
            return;
        }
        
        [self.logger info:@"Create client... (id: %@, token: %@, environment: %@)", growthbeatClientId, token, NSStringFromGPEnvironment(self.environment)];
        GPClientV4 *createdClient = [GPClientV4 attachClient:growthbeatClientId applicationId:self.applicationId credentialId:self.credentialId token:token environment:self.environment];
        if (createdClient) {
            [self.logger info:@"Create client success. (clientId: %@)", createdClient.id];
            self.client = createdClient;
            [GPClientV4 save:createdClient];
        }
        
    }
    
}

- (void) updateClient:(NSString *)growthbeatClientId token:(NSString *)newToken {
    
    @synchronized(self) {
        GPClientV4 *clientV4 = [GPClientV4 load];
        if(clientV4 && clientV4.environment == self.environment && [newToken isEqualToString:clientV4.token]) {
            [self.logger info:@"Already updated client. (id: %@, token: %@, environment: %@)", growthbeatClientId, newToken, NSStringFromGPEnvironment(self.environment)];
            return;
        }
        
        [self.logger info:@"Update client... (id: %@, token: %@, environment: %@)", growthbeatClientId, newToken, NSStringFromGPEnvironment(self.environment)];
        
        GPClientV4 *updatedClient = [GPClientV4 attachClient:growthbeatClientId applicationId:self.applicationId credentialId:self.credentialId token:newToken environment:self.environment];
        if (updatedClient) {
            [self.logger info:@"Update client success. (id: %@)", updatedClient.id];
            self.client = updatedClient;
            [GPClientV4 save:updatedClient];
        }
    }
    
}

#pragma send_tag

- (void) setTag:(NSString *)name {
    [self setTag:name value:nil];
}

- (void) setTag:(NSString *)name value:(NSString *)value {
    [self setTag:GPTagTypeCustom name:name value:value];
}

- (void)setTag:(GPTagType)type name:(NSString *)name value:(NSString *)value {
    
    void (^request)() = ^{
        [self setTagSynchronously:type name:name value:value];
    };
    
    if(self.client) {
        dispatch_async(analyticsDispatchQueue, request);
    } else{
        [pendingRequests addObject:request];
    }
}

- (void)setTagSynchronously:(GPTagType)type name:(NSString *)name value:(NSString *)value {
    
    @synchronized(self) {
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
}

#pragma send_event

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
        [self trackEventSynchronously:type name:name value:value showMessage:showMessageHandler failure:failureHandler];
    };
    
    if(self.client) {
        dispatch_async(analyticsDispatchQueue, request);
    } else{
        [pendingRequests addObject:request];
    }

}

- (void) trackEventSynchronously:(GPEventType)type name:(NSString *)name value:(NSString *)value showMessage:(void (^)(void(^renderMessage)()))showMessageHandler failure:(void (^)(NSString *detail))failureHandler {
    
    @synchronized(self) {
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
    }
    
}

#pragma tag_alias

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

#pragma growthmessage

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

#pragma client_wait

- (GPClientV4 *) waitClient {

    while (true) {
        if (self.client != nil) {
            return self.client;
        }
        usleep(100 * 1000);
    }

}

- (void) setClient:(GPClientV4 *)_clientV4 {
    client = _clientV4;
    for (void (^pendingRequest)() in [pendingRequests reverseObjectEnumerator]) {
        pendingRequest();
        [pendingRequests removeObject:pendingRequest];
    }
}


@end
