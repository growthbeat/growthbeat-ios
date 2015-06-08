//
//  GrowthLink.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/05/29.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GrowthLink.h"
#import "GrowthAnalytics.h"
#import "GLSynchronize.h"
#import "GLIntent.h"

static GrowthLink *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthLink";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.link.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthlink-preferences";

@interface GrowthLink () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

    NSString *applicationId;
    NSString *credentialId;

    BOOL initialized;
    BOOL isFirstSession;

}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL isFirstSession;

@end

@implementation GrowthLink

@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize applicationId;
@synthesize credentialId;

@synthesize initialized;
@synthesize isFirstSession;

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
        self.isFirstSession = NO;
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
    
    [self synchronize];
    
}

- (void) handleOpenUrl:(NSURL *)url {
    
    NSString *token = url.host;
    if(!token) {
        [logger error:@"Unabled to get token from url."];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [logger info:@"Get synchronize..."];
        
        GLIntent *intent = [GLIntent createWithClientId:[[[GrowthbeatCore sharedInstance] client] id] token:token install:(isFirstSession?1:0) credentialId:credentialId];
        if (!intent) {
            [logger error:@"Failed to get intent."];
        }
        
        [logger info:@"Get intent success. (intent.intent.id: %@)", intent.intent.id];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        if ([intent.link objectForKey:@"id"]) {
            [properties setObject:[intent.link objectForKey:@"id"] forKey:@"linkId"];
        }
        if ([intent.pattern objectForKey:@"id"]) {
            [properties setObject:[intent.pattern objectForKey:@"id"] forKey:@"patternId"];
        }
        if (intent.intent.id) {
            [properties setObject:intent.intent.id forKey:@"intentId"];
        }
        
        if(isFirstSession) {
            [[GrowthAnalytics sharedInstance] track:@"GrowthLink" name:@"Install" properties:properties option:GATrackOptionDefault completion:nil];
        }
        
        [[GrowthAnalytics sharedInstance] track:@"GrowthLink" name:@"Open" properties:properties option:GATrackOptionDefault completion:nil];
        
        isFirstSession = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[GrowthbeatCore sharedInstance] handleIntent:intent.intent];
        });
        
    });
    
}

- (void) synchronize {
    
    [logger info:@"Check initialization..."];
    if([GLSynchronize load]) {
        [logger info:@"Already initialized."];
        return;
    }
    
    isFirstSession = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [logger info:@"Get synchronize..."];
        
        GLSynchronize *synchronize = [GLSynchronize getWithApplicationId:applicationId os:1 version:[GBDeviceUtils version]  credentialId:credentialId];
        if (!synchronize) {
            [logger error:@"Failed to get synchronize."];
        }
        
        [GLSynchronize save:synchronize];
        [logger info:@"Get synchronize success. (configuration.browser: %d)", synchronize.browser];
        
        if(synchronize.browser == 1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://stg.link.growthbeat.com/l/synchronize"]];
            });
        }
        
    });
    
}

@end
