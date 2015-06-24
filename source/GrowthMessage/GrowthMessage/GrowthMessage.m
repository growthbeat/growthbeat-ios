//
//  GrowthMessage.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GrowthMessage.h"
#import "GrowthAnalytics.h"
#import "GMMessage.h"
#import "GMMessageHandler.h"
#import "GMPlainMessageHandler.h"
#import "GMImageMessageHandler.h"
#import "GMBannerMessageHandler.h"

static GrowthMessage *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthMessage";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.message.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 10;
static NSString *const kGBPreferenceDefaultFileName = @"growthmessage-preferences";

@interface GrowthMessage () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

    NSString *applicationId;
    NSString *credentialId;

    BOOL initialized;

}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

@property (nonatomic, assign) BOOL initialized;

- (void) openMessage:(GMMessage *)message;

@end

@implementation GrowthMessage

@synthesize messageHandlers;

@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize applicationId;
@synthesize credentialId;

@synthesize initialized;

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
        self.initialized = NO;
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId {

    if (initialized) {
        return;
    }
    initialized = YES;

    self.applicationId = newApplicationId;
    self.credentialId = newCredentialId;

    [[GrowthbeatCore sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];
    if (![[GrowthbeatCore sharedInstance] client] || ![[[[[GrowthbeatCore sharedInstance] client] application] id] isEqualToString:applicationId]) {
        [preference removeAll];
    }
    
    [[GrowthAnalytics sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];

    [[GrowthAnalytics sharedInstance] addEventHandler:[[GAEventHandler alloc] initWithCallback:^(NSString *eventId, NSDictionary *properties) {
        if ([eventId hasPrefix:[NSString stringWithFormat:@"Event:%@:GrowthMessage", applicationId]]) {
            return;
        }
        [self receiveMessageWithEventId:eventId];
    }]];

    self.messageHandlers = [NSArray arrayWithObjects:[[GMPlainMessageHandler alloc] init], [[GMImageMessageHandler alloc] init], [[GMBannerMessageHandler alloc] init], nil];

}

- (void) receiveMessageWithEventId:(NSString *)eventId {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [logger info:@"Receive message..."];

        GMMessage *message = [GMMessage receiveWithClientId:[[[GrowthbeatCore sharedInstance] waitClient] id] eventId:eventId credentialId:credentialId];
        if (message) {
            [logger info:@"Message is found. (id: %@)", message.id];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openMessage:message];
            });
        } else {
            [logger info:@"Message is not found."];
        }

    });

}

- (void) openMessage:(GMMessage *)message {

    for (id<GMMessageHandler> handler in messageHandlers) {

        if (![handler handleMessage:message]) {
            continue;
        }

        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        if (message.task.id) {
            [properties setObject:message.task.id forKey:@"taskId"];
        }
        if (message.id) {
            [properties setObject:message.id forKey:@"messageId"];
        }

        [[GrowthAnalytics sharedInstance] track:@"GrowthMessage" name:@"ShowMessage" properties:properties option:GATrackOptionDefault completion:nil];

        break;

    }

}

- (void) selectButton:(GMButton *)button message:(GMMessage *)message {

    [[GrowthbeatCore sharedInstance] handleIntent:button.intent];

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

    [[GrowthAnalytics sharedInstance] track:@"GrowthMessage" name:@"SelectButton" properties:properties option:GATrackOptionDefault completion:nil];

}

@end
