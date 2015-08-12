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
static NSString *const kGBLoggerDefaultTag = @"GrowthLink";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.link.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthlink-preferences";

@interface NSURL (dictionaryFromQueryString)
-(NSDictionary *) dictionaryFromQueryString;
@end

@implementation NSURL (dictionaryFromQueryString)
-(NSDictionary *) dictionaryFromQueryString{
    
    NSString *query = [self query];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSRange range = [pair rangeOfString:@"="];
        NSString *key = range.length ? [pair substringToIndex:range.location] : pair;
        NSString *val = range.length ? [pair substringFromIndex:range.location+1] : @"";
        key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        val = [val stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        val = [val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}
@end

@interface GrowthLink () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;
    UIWebView *webView;
    NSString *fingerprintParameters;
    NSString *userAgent;
    NSString *clientWidthHeight;

    BOOL initialized;
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
        self.synchronizationUrl = kDefaultSynchronizationUrl;
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl] timeout:kGBHttpClientDefaultTimeout];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
        self.initialized = NO;
        self.isFirstSession = NO;
        self.synchronizationCallback = ^(GLSynchronization *synchronization) {
            if(!synchronization.browser){
                return;
            }
            NSString* urlString = [NSString stringWithFormat:@"%@?applicationId=%@&advertisingId=%@", [[GrowthLink sharedInstance] synchronizationUrl], [[GrowthLink sharedInstance] applicationId],[GBDeviceUtils getAdvertisingId]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
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
    [self synchronize];
}

- (void) getFingerPrint: (UIWindow *)window {
    webView = [[UIWebView alloc] initWithFrame:window.frame];
    webView.delegate = self;
    webView.hidden = NO;
    NSString *html = @"<html><body>hoge<script>var elementCanvas = document.createElement('canvas');function browserSupportsWebGL(canvas) {var context = null;var names = [\"webgl\", \"experimental-webgl\", \"webkit-3d\", \"moz-webgl\"];for (var i = 0; i < names.length; ++i) {try {context = canvas.getContext(names[i]);    } catch(e) {    }    if (context) {break;}}return context != null;}function browserSupportCanvas(canvas) {try {    return !!(canvas.getContext && canvas.getContext('2d'));} catch(e) {    return false;}}function canvasContent(canvas) {var ctx = canvas.getContext('2d');var txt = 'example_canvas';ctx.textBaseline = \"top\";ctx.font = \"14px 'Arial'\";ctx.textBaseline = \"alphabetic\";ctx.fillStyle = \"#f60\";ctx.fillRect(125,1,62,20);ctx.fillStyle = \"#069\";ctx.fillText(txt, 2, 15);ctx.fillStyle = \"rgba(102, 204, 0, 0.7)\";ctx.fillText(txt, 4, 17);return canvas.toDataURL();}var plugins = [];for(var i=0;i < navigator.plugins.length;i++){plugins.push(navigator.plugins[i].name);}var mimeTypes = [];for(var i=0;i<navigator.mimeTypes.length;i++){ mimeTypes.push(navigator.mimeTypes[i].description);}window.onload = function(){var fingerprint_parameters = {userAgent: navigator.userAgent,language: navigator.language || navigator.userLanguage,platform: navigator.platform,appName: navigator.appName,appVersion: navigator.appVersion,cookieSupport: navigator.cookieEnabled,javaSupport: navigator.javaEnabled(),vendor: navigator.vendor,product: navigator.product,maxTouchPoints: navigator.maxTouchPoints,appCodeName: navigator.appCodeName,currentResolution: window.screen.width + 'x' + window.screen.height,colorDepth: window.screen.colorDepth,timeZone: new Date().getTimezoneOffset(),hasSessionStorage: !!window.sessionStorage,hasLocalStorage: !!window.localStorage,hasIndexedDB: !!window.indexedDB,plugins: plugins.toString(),encoding: document.characterSet,canvasSupport: browserSupportCanvas(elementCanvas),webgl: browserSupportsWebGL(elementCanvas),mineTypes: mimeTypes.toString(),canvasContent: canvasContent(elementCanvas).toString(),clientWidthHeight: document.documentElement.clientWidth + 'x' + document.documentElement.clientHeight};location.href = 'native://js?fingerprint_parameters=' + JSON.stringify(fingerprint_parameters) + '&useragent=' + navigator.userAgent + '&client_width_height=' + document.documentElement.clientWidth + 'x' + document.documentElement.clientHeight }</script></body></html>";
    [webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    [window addSubview:webView];
   

    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
}


-(BOOL)webView:(UIWebView *)argWebView shouldStartLoadWithRequest:(NSURLRequest *)
request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([ request.URL.scheme isEqualToString:@"native" ]) {
        if ([request.URL.host isEqualToString:@"js"]) {
            NSDictionary *dict = request.URL.dictionaryFromQueryString;
            fingerprintParameters = [dict valueForKey:@"fingerprint_parameters"];
            userAgent = [dict valueForKey:@"useragent"];
            clientWidthHeight = [dict valueForKey:@"client_width_height"];
            [webView removeFromSuperview];
        }
        return NO;
    }
    else {
        return YES;
    }
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
        
        GLSynchronization *synchronization = [GLSynchronization synchronizeWithApplicationId:applicationId version:[GBDeviceUtils version]  credentialId:credentialId userAgent:userAgent clientWidthHeight:clientWidthHeight fingerprintParameters:fingerprintParameters];
        if (!synchronization) {
            [logger error:@"Failed to Synchronize."];
            return;
        }
        
        [GLSynchronization save:synchronization];
        [logger info:@"Synchronize success. (browser: %@)", synchronization.browser?@"YES":@"NO"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(synchronizationCallback) {
                synchronizationCallback(synchronization);
            }
        });
        
    });
    
}

@end
