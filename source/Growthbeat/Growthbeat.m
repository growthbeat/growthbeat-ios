//
//  GrowthbeatCore.m
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Growthbeat.h"
#import "GBUrlIntentHandler.h"
#import "GBNoopIntentHandler.h"
#import "GBCustomIntentHandler.h"

static Growthbeat *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthbeatCore";
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
@property (nonatomic, assign) BOOL initialized;

@end

@implementation Growthbeat

@synthesize client;
@synthesize logger;
@synthesize httpClient;
@synthesize preference;
@synthesize initialized;

@synthesize intentHandlers;
@synthesize gpClient;

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
        self.gpClient = nil;
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl] timeout:kGBHttpClientDefaultTimeout];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
        self.initialized = NO;
        self.intentHandlers = [NSMutableArray arrayWithObjects:[[GBUrlIntentHandler alloc] init], [[GBNoopIntentHandler alloc] init], nil];
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId {

    if (self.initialized) {
        return;
    }
    self.initialized = YES;

    [self.logger info:@"Initializing... (applicationId:%@)", applicationId];

    GPClient __block *existingGpClient = [GPClient load];
    GBClient __block *existingClient = [GBClient load];
    
    if (!existingGpClient) {
        if (existingClient && [existingClient.application.id isEqualToString:applicationId]) {
            [self.logger info:@"Client already exists. (id:%@)", existingClient.id];
            self.client = existingClient;
            return;
        }
    }

    [self.preference removeAll];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        if (existingGpClient) {
            existingGpClient = [GPClient findWithGPClientId:existingGpClient.id code:existingGpClient.code];
            [self.logger info:@"convert client... (GrowthPushClientId:%d, GrowthbeatClientId:%@)", existingGpClient.id, existingGpClient.growthbeatClientId];

            existingClient = [GBClient findWithId:existingGpClient.growthbeatClientId credentialId:credentialId];
            if (!existingClient && ![existingClient.application.id isEqualToString:applicationId]) {
                [self.logger error:@"Failed to convert client."];
                [GPClient removePreference];
                return;
            }

            self.client = existingClient;
            self.gpClient = existingGpClient;
            [GBClient save:existingClient];
            [GPClient removePreference];
            [self.logger info:@"Client converted. (id:%@)", existingClient.id];

        } else {

            [self.logger info:@"Creating client... (applicationId:%@)", applicationId];
            existingClient = [GBClient createWithApplicationId:applicationId credentialId:credentialId];
            if (!existingClient) {
                [self.logger info:@"Failed to create client."];
                return;
            }

            self.client = existingClient;
            [GBClient save:existingClient];
            [self.logger info:@"Client created. (id:%@)", existingClient.id];

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
