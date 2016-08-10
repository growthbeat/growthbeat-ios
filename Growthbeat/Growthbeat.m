//
//  GrowthbeatCore.m
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Growthbeat.h"
#import "GBGPClient.h"

static Growthbeat *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"Growthbeat";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthbeat-preferences";

@interface Growthbeat () {

    GBClient *client;
    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;
    BOOL initialized;

}

@property (nonatomic, strong) GBClient *client;
@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;

@end

@implementation Growthbeat

@synthesize client;
@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize intentHandlers;

+ (Growthbeat *) sharedInstance {
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

- (instancetype) init {
    self = [super init];
    if (self) {
        self.client = nil;
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl] timeout:kGBHttpClientDefaultTimeout];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
        self.intentHandlers = [NSMutableArray arrayWithObjects:[[GBUrlIntentHandler alloc] init], [[GBNoopIntentHandler alloc] init], nil];
        initialized = NO;
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId {

    if (initialized) {
        return;
    }
    initialized = YES;

    [self.logger info:@"Initializing... (applicationId:%@)", applicationId];

    GBClient __block *existingClient = [GBClient load];
    if (existingClient && [existingClient.application.id isEqualToString:applicationId]) {
        [self.logger info:@"Client already exists. (id:%@)", existingClient.id];
        self.client = existingClient;
        return;
    }

    [self.preference removeAll];
    self.client = nil;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        GBGPClient *gbGPClient = [GBGPClient load];
        if (gbGPClient) {
            gbGPClient = [GBGPClient findWithGPClientId:gbGPClient.id code:gbGPClient.code];
            [self.logger info:@"Growth Push Client found. Convert GrowthPush Client into Growthbeat Client. (GrowthPushClientId:%d, GrowthbeatClientId:%@)", gbGPClient.id, gbGPClient.growthbeatClientId];

            GBClient *convertedClient = [GBClient findWithId:gbGPClient.growthbeatClientId credentialId:credentialId];
            if (!convertedClient && ![convertedClient.application.id isEqualToString:applicationId]) {
                [self.logger error:@"Failed to convert client."];
                [GBGPClient removePreference];
                return;
            }

            self.client = convertedClient;
            [GBClient save:convertedClient];
            [GBGPClient removePreference];
            [self.logger info:@"Client converted. (id:%@)", convertedClient.id];

        } else {

            [self.logger info:@"Creating client... (applicationId:%@)", applicationId];
            GBClient *newClient = [GBClient createWithApplicationId:applicationId credentialId:credentialId];
            if (!newClient) {
                [self.logger info:@"Failed to create client."];
                return;
            }

            self.client = newClient;
            [GBClient save:newClient];
            [self.logger info:@"Client created. (id:%@)", newClient.id];

        }

    });

}

- (GBClient *) waitClient {

    while (true) {
        if (self.client != nil) {
            return self.client;
        }
        usleep(100 * 1000);
    }

}

- (void)setLoggerSilent:(BOOL) silent {
    [[self logger] setSilent:silent];
    [[[GrowthPush sharedInstance] logger] setSilent:silent];
    [[[GrowthLink sharedInstance] logger] setSilent:silent];
}

- (BOOL) handleIntent:(GBIntent *)intent {

    for (id <GBIntentHandler> intentHandler in self.intentHandlers) {
        if ([intentHandler handleIntent:intent]) {
            return YES;
        }
    }

    return NO;

}

- (void)addIntentHandler:(NSObject *)intentHandler{
    [intentHandlers addObject:intentHandler];
}

- (void)addCustomIntentHandlerWithBlock:(BOOL(^)(GBCustomIntent *customIntent))block {
    [intentHandlers addObject:[[GBCustomIntentHandler alloc] initWithBlock:block]];
}

@end
