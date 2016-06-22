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
static NSString *const kDefaultSynchronizationUrlTmplete = @"https://%@/l/synchronize";
static NSString *const kDefaultHost = @"gbt.io";
static NSString *const kGBLoggerDefaultTag = @"GrowthLink";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.link.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthlink-preferences";

@interface GrowthLink () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

    BOOL initialized;
    BOOL fingerPrintSuccess;
    BOOL isFirstSession;

}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL isFirstSession;

@end

@implementation GrowthLink

@synthesize synchronizationUrl;

@synthesize logger;
@synthesize httpClient;
@synthesize preference;
@synthesize synchronizationHandler;
@synthesize host;

@synthesize applicationId;
@synthesize credentialId;

@synthesize initialized;
@synthesize isFirstSession;

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
        self.host = kDefaultHost;
        self.synchronizationUrl = [NSString stringWithFormat:kDefaultSynchronizationUrlTmplete,self.host];
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl] timeout:kGBHttpClientDefaultTimeout];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
        self.synchronizationHandler = [[GLSynchronizationHandler alloc] init];
        self.initialized = NO;
        self.isFirstSession = NO;
        self.synchronizationCallback = ^(GLSynchronization *synchronization) {
            if (synchronization.cookieTracking) {
                [[GrowthLink sharedInstance].synchronizationHandler synchronizeWithCookie:synchronization];
                return;
            }

            if (synchronization.deviceFingerprint && synchronization.clickId) {
                [[GrowthLink sharedInstance].synchronizationHandler synchronizeWithFingerprint:synchronization];
            }
        };
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
    if (![[Growthbeat sharedInstance] client] || ![[[[[Growthbeat sharedInstance] client] application] id] isEqualToString:applicationId]) {
        [preference removeAll];
    }

    [self synchronize];
}


- (void)handleUniversalLinks:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURLComponents *component = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:true];
        if ( [self canHandleUniversalLinks:component]){
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
            } else {
                NSString *path = component.path;
                NSString* pattern = @"/ul/.*?/(.*)";
                NSError* error = nil;
                NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
                if (error != nil){
                    return;
                }
                NSTextCheckingResult *match= [regex firstMatchInString:path options:NSMatchingReportProgress range:NSMakeRange(0, path.length)];
                NSString *alias =  [path substringWithRange:[match rangeAtIndex:1]];
                [logger info:@"Deeplinking...(Universal Link)"];
                GLClick *click = [GLClick deeplinkUniversalLink:[[[Growthbeat sharedInstance] waitClient] id] alias:alias credentialId:credentialId queryItems:component.queryItems];
                //If the link has a landing page url, open it in safari adding required params.
                if (click.pattern.url) {
                    NSURLComponents *urlComponent = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:click.pattern.url] resolvingAgainstBaseURL:true];
                    NSMutableArray *newParameters = [NSMutableArray array];
                    for (NSURLQueryItem *queryItem in urlComponent.queryItems) {
                        [newParameters addObject:queryItem];
                    }
                    NSURLComponents *newComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@://%@%@", urlComponent.scheme, urlComponent.host , urlComponent.path]];
                    [newParameters addObject:[NSURLQueryItem queryItemWithName:@"universalLink" value:[NSString stringWithFormat:@"https://%@/l/universallink/%@?clickId=%@",component.host, [GrowthLink sharedInstance].applicationId, click.id]]];
                    [newParameters addObject:[NSURLQueryItem queryItemWithName:@"deepLinkUrl" value:[NSString stringWithFormat:@"https://%@/l/%@", component.host, alias]]];
                    newComponents.queryItems = newParameters;
                    [[UIApplication sharedApplication] openURL:newComponents.URL];
                } else {
                    [self handleClick:click];
                }
            }
        }
    });
}

- (BOOL) canHandleUniversalLinks:(NSURLComponents*) component{
    if (!component || !component.host) return false;
    if ([self.host isEqualToString:component.host] ) {
        return true;
    }
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
    
    if (click.pattern.intent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Growthbeat sharedInstance] handleIntent:click.pattern.intent];
        });
    }

}

- (void) synchronize {

    [logger info:@"Check initialization..."];
    if ([GLSynchronization load]) {
        [logger info:@"Already initialized."];
        return;
    }

    isFirstSession = YES;

    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [logger info:@"Synchronizing..."];

        GLSynchronization *synchronization = [GLSynchronization synchronizeWithApplicationId:applicationId version:[GBDeviceUtils version]  userAgent:userAgent credentialId:credentialId];
        if (!synchronization) {
            [logger error:@"Failed to Synchronize."];
            return;
        }

        [GLSynchronization save:synchronization];
        [logger info:@"Synchronize success. (cookieTracking: %@, deviceFingerprint: %@, clickId: %@)", synchronization.cookieTracking ? @"YES" : @"NO", synchronization.deviceFingerprint ? @"YES" : @"NO", synchronization.clickId];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (synchronizationCallback) {
                synchronizationCallback(synchronization);
            }
        });
    });
}


@end
