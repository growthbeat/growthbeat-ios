//
//  GrowthLink.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/05/29.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GrowthLink.h"
#import "GBCustomIntentHandler.h"
#import <SafariServices/SafariServices.h>
#import "GLClick.h"

static GrowthLink *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthLink";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.link.growthbeat.com/";
static NSString *const kDefaultHost = @"gbt.io";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthlink-preferences";

@interface GrowthLink () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

    BOOL initialized;
    BOOL isFirstSession;

}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;
@property (nonatomic, strong) GLSynchronizationHandler *synchronizationHandler;

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL isFirstSession;

@end

@implementation GrowthLink

@synthesize logger;
@synthesize httpClient;
@synthesize preference;
@synthesize synchronizationHandler;

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
        self.synchronizationHandler = [[GLSynchronizationHandler alloc] init];
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

    [[Growthbeat sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        GBClient *client = [Growthbeat sharedInstance].waitClient;
        if (!client || ![client.application.id isEqualToString:applicationId]) {
            [preference removeAll];
        }
        
        [logger info:@"Check initialization..."];
        if ([GLSynchronization load]) {
            [logger info:@"Already initialized."];
            return;
        }
        
        isFirstSession = YES;
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
        [logger info:@"Synchronizing..."];
        
        GLSynchronization *synchronization = [GLSynchronization synchronizeWithApplicationId:applicationId version:[GBDeviceUtils version]  userAgent:userAgent credentialId:credentialId];
        if (!synchronization) {
            [logger error:@"Failed to Synchronize."];
            return;
        }
        
        [GLSynchronization save:synchronization];
        [logger info:@"Synchronize success. (cookieTracking: %@, deviceFingerprint: %@, clickId: %@)", synchronization.cookieTracking ? @"YES" : @"NO", synchronization.deviceFingerprint ? @"YES" : @"NO", synchronization.clickId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (synchronization.cookieTracking)
                [self.synchronizationHandler synchronizeWithCookie:synchronization];
            else if (synchronization.deviceFingerprint && synchronization.clickId)
                [self.synchronizationHandler synchronizeWithFingerprint:synchronization];
            
        });
        
    });
    
}


- (void)handleUniversalLinks:(NSURL *)url {

    NSURLComponents *component = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:true];
    if ([self canHandleUniversalLinks:component]) {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        BOOL hasClickId = NO;
        for (NSURLQueryItem *queryItem in component.queryItems) {
            if ([queryItem.name isEqualToString:@"clickId"]) {
                hasClickId = YES;
            } else {
                [parameters setObject:queryItem.name forKey:queryItem.value];
            }
        }
        
        if (hasClickId) {
            [[GrowthLink sharedInstance] handleOpenUrl:url];
            return;
        }
        
        NSString *path = component.path;
        NSString* pattern = @"/ul/.*?/(.*)";
        NSError* error = nil;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        if (error != nil)
            return;
        
        NSTextCheckingResult *match= [regex firstMatchInString:path options:NSMatchingReportProgress range:NSMakeRange(0, path.length)];
        NSString *alias =  [path substringWithRange:[match rangeAtIndex:1]];
        
        [logger info:@"Deeplinking...(Universal Link)"];
        GLClick *click = [GLClick deeplinkUniversalLink:[Growthbeat sharedInstance].waitClient.id alias:alias credentialId:credentialId queryItems:component.queryItems];
        if (!click.pattern.url) {
            [self handleClick:click];
            return;
        }
        
        NSURLComponents *clickPatternUrlComponent = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:click.pattern.url] resolvingAgainstBaseURL:true];
        NSMutableArray *universalLinkUrlParameters = [NSMutableArray array];
        for (NSURLQueryItem *queryItem in clickPatternUrlComponent.queryItems)
            [universalLinkUrlParameters addObject:queryItem];
        
        NSURLComponents *universalLinkUrlComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@://%@%@", clickPatternUrlComponent.scheme, clickPatternUrlComponent.host , clickPatternUrlComponent.path]];
        [universalLinkUrlParameters addObject:[NSURLQueryItem queryItemWithName:@"universalLink" value:[NSString stringWithFormat:@"https://%@/l/universallink/%@?clickId=%@",component.host, self.applicationId, click.id]]];
        [universalLinkUrlParameters addObject:[NSURLQueryItem queryItemWithName:@"deepLinkUrl" value:[NSString stringWithFormat:@"https://%@/l/%@", component.host, alias]]];
        universalLinkUrlComponents.queryItems = universalLinkUrlParameters;
        
        [[UIApplication sharedApplication] openURL:universalLinkUrlComponents.URL];
        
    }
    
}

- (BOOL) canHandleUniversalLinks:(NSURLComponents*)component {
    if (!component || !component.host)
        return false;
    
    if ([kDefaultHost isEqualToString:component.host])
        return true;
    
    return false;
}


- (void) handleOpenUrl:(NSURL *)url {
    [self.synchronizationHandler removeWindowIfExists];

    NSDictionary *query = [GBHttpUtils dictionaryWithQueryString:url.query];
    NSString *clickId = [query objectForKeyedSubscript:@"clickId"];

    if (!clickId) {
        [logger info:@"Unabled to get clickId from url."];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [logger info:@"Deeplinking..."];

        GLClick *click = [GLClick deeplinkWithClientId:[[[Growthbeat sharedInstance] waitClient] id] clickId:clickId install:isFirstSession credentialId:credentialId];
        [self handleClick:click];
        
    });

}

- (void) handleClick:(GLClick *) click{
    isFirstSession = NO;
    if (!click || !click.pattern || !click.pattern.link) {
        [logger error:@"Failed to deeplink."];
        return;
    }
    
    [logger info:@"Deeplink success. (clickId: %@)", click.id];
    
    if (click.pattern.intent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Growthbeat sharedInstance] handleIntent:click.pattern.intent];
        });
    }

}


@end
