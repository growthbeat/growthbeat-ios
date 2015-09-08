//
//  GrowthLink.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/05/29.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GrowthLink.h"
#import <Growthbeat/GrowthAnalytics.h>
#import "GLClick.h"

static GrowthLink *sharedInstance = nil;
static NSString *const kDefaultSynchronizationUrl = @"http://gbt.io/l/synchronize";
static NSString *const kDefaultFingerprintUrl = @"http://gbt.io/l/fingerprint";
static NSString *const kGBLoggerDefaultTag = @"GrowthLink";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.link.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthlink-preferences";

@interface GrowthLink () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;
    UIWebView *webView;
    NSString *fingerprintParameters;

    BOOL initialized;
    BOOL fingerPrintSuccess;
    BOOL isFirstSession;
    
}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL isFirstSession;
@property (nonatomic, assign) BOOL fingerPrintSuccess;

@end

@implementation GrowthLink

@synthesize synchronizationUrl;
@synthesize fingerprintUrl;

@synthesize logger;
@synthesize httpClient;
@synthesize preference;

@synthesize applicationId;
@synthesize credentialId;

@synthesize initialized;
@synthesize isFirstSession;
@synthesize fingerPrintSuccess;

@synthesize synchronizationCallback;

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
        self.synchronizationUrl = kDefaultSynchronizationUrl;
        self.fingerprintUrl = kDefaultFingerprintUrl;
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl] timeout:kGBHttpClientDefaultTimeout];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
        self.initialized = NO;
        self.isFirstSession = NO;
        self.fingerPrintSuccess = NO;
        self.synchronizationCallback = ^(GLSynchronization *synchronization, GrowthLink *growthLink) {
            if(synchronization.cookieTracking){
                NSString* urlString = [NSString stringWithFormat:@"%@?applicationId=%@&advertisingId=%@", [[GrowthLink sharedInstance] synchronizationUrl], [[GrowthLink sharedInstance] applicationId],[GBDeviceUtils getAdvertisingId]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                return;
            }
           
            if (synchronization.deviceFingerprint && synchronization.clickId) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"?clickId=%@",synchronization.clickId ]];
                [growthLink handleOpenUrl:url];
            }
        };
    }
    return self;
}

- (void)initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId {
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
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [self getFingerPrint:window];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!fingerPrintSuccess) {
            [self synchronize];
        }
    });
}



- (void) handleOpenUrl:(NSURL *)url {
    
    NSDictionary *query = [GBHttpUtils dictionaryWithQueryString:url.query];
    NSString *clickId = [query objectForKeyedSubscript:@"clickId"];
    if(!clickId) {
        [logger info:@"Unabled to get clickId from url."];
        return;
    }
    
    NSString *uuid = [query objectForKeyedSubscript:@"uuid"];
    if(uuid) {
        [[GrowthAnalytics sharedInstance] setUUID:uuid];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [logger info:@"Deeplinking..."];
        
        GLClick *click = [GLClick deeplinkWithClientId:[[[GrowthbeatCore sharedInstance] waitClient] id] clickId:clickId install:isFirstSession credentialId:credentialId];
        if (!click || !click.pattern || !click.pattern.link) {
            [logger error:@"Failed to deeplink."];
            return;
        }
        
        [logger info:@"Deeplink success. (clickId: %@)", click.id];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        if (click.pattern.link.id) {
            [properties setObject:click.pattern.link.id forKey:@"linkId"];
        }
        if (click.pattern.id) {
            [properties setObject:click.pattern.id forKey:@"patternId"];
        }
        if (click.pattern.intent.id) {
            [properties setObject:click.pattern.intent.id forKey:@"intentId"];
        }
        
        if(isFirstSession) {
            [[GrowthAnalytics sharedInstance] track:@"GrowthLink" name:@"Install" properties:properties option:GATrackOptionDefault completion:nil];
            if(click.pattern.link.id) {
                [[GrowthAnalytics sharedInstance] tag:@"GrowthLink" name:@"InstallLink" value:click.pattern.link.id completion:nil];
            }
        }
        
        [[GrowthAnalytics sharedInstance] track:@"GrowthLink" name:@"Open" properties:properties option:GATrackOptionDefault completion:nil];
        
        isFirstSession = NO;
        
        if(click.pattern.intent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GrowthbeatCore sharedInstance] handleIntent:click.pattern.intent];
            });
        }
        
    });
    
}

- (void) synchronize {
    
    [logger info:@"Check initialization..."];
    if([GLSynchronization load]) {
        [logger info:@"Already initialized."];
        return;
    }
    
    isFirstSession = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [logger info:@"Synchronizing..."];
        
        GLSynchronization *synchronization = [GLSynchronization synchronizeWithApplicationId:applicationId version:[GBDeviceUtils version]  fingerprintParameters:fingerprintParameters credentialId:credentialId];
        if (!synchronization) {
            [logger error:@"Failed to Synchronize."];
            return;
        }
        
        [GLSynchronization save:synchronization];
        [logger info:@"Synchronize success. (cookieTracking: %@, deviceFingerprint: %@, clickId: %@)", synchronization.cookieTracking?@"YES":@"NO", synchronization.deviceFingerprint?@"YES":@"NO",synchronization.clickId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(synchronizationCallback) {
                synchronizationCallback(synchronization, self);
            }
        });
        
    });
    
}

- (void) getFingerPrint: (UIWindow *)window {
    webView = [[UIWebView alloc] initWithFrame:window.frame];
    webView.delegate = self;
    webView.hidden = NO;
    [window addSubview:webView];
    NSURL *websiteUrl = [NSURL URLWithString:self.fingerprintUrl];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [webView loadRequest:urlRequest];
    
    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
}


-(BOOL)webView:(UIWebView *)argWebView shouldStartLoadWithRequest:(NSURLRequest *)
request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([ request.URL.scheme isEqualToString:@"native" ]) {
        if ([request.URL.host isEqualToString:@"fingerprint"]) {
            NSDictionary *dict = request.URL.dictionaryFromQueryString;
            fingerprintParameters = [dict valueForKey:@"fingerprintParameters"];
            fingerPrintSuccess = YES;
            [webView removeFromSuperview];
            if (!isFirstSession) {
                [self synchronize];
            }
        }
        return NO;
    }
    else {
        return YES;
    }
}

@end
