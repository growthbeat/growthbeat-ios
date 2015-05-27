//
//  GrowthAnalytics.m
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GrowthAnalytics.h"
#import "GAClientEvent.h"
#import "GAClientTag.h"
#import <AdSupport/AdSupport.h>

#define ARC4RANDOM_MAX (0x100000000)

static GrowthAnalytics *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthAnalytics";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.analytics.growthbeat.com/";
static NSTimeInterval const kGBHttpClientDefaultTimeout = 60;
static NSString *const kGBPreferenceDefaultFileName = @"growthanalytics-preferences";

static NSString *const kGADefaultNamespace = @"Default";
static NSString *const kGACustomNamespace = @"Custom";

@interface GrowthAnalytics () {

    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;

    NSString *applicationId;
    NSString *credentialId;

    BOOL initialized;
    NSDate *openTime;
    NSMutableArray *eventHandlers;

}

@property (nonatomic, strong) GBLogger *logger;
@property (nonatomic, strong) GBHttpClient *httpClient;
@property (nonatomic, strong) GBPreference *preference;

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, strong) NSDate *openTime;
@property (nonatomic, strong) NSMutableArray *eventHandlers;

@end

@implementation GrowthAnalytics

@synthesize logger;
@synthesize httpClient;

@synthesize preference;
@synthesize applicationId;
@synthesize credentialId;

@synthesize initialized;
@synthesize openTime;
@synthesize eventHandlers;

+ (GrowthAnalytics *) sharedInstance {
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
        self.eventHandlers = [NSMutableArray array];
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

    [self setBasicTags];

}

- (void) track:(NSString *)name {
    [self track:kGACustomNamespace name:name properties:nil option:GATrackOptionDefault completion:nil];
}

- (void) track:(NSString *)name properties:(NSDictionary *)properties {
    [self track:kGACustomNamespace name:name properties:properties option:GATrackOptionDefault completion:nil];
}

- (void) track:(NSString *)name option:(GATrackOption)option {
    [self track:kGACustomNamespace name:name properties:nil option:option completion:nil];
}

- (void) track:(NSString *)name properties:(NSDictionary *)properties option:(GATrackOption)option {
    [self track:kGACustomNamespace name:name properties:properties option:option completion:nil];
}

- (void) track:(NSString *)namespace name:(NSString *)name properties:(NSDictionary *)properties option:(GATrackOption)option completion:(void (^)(GAClientEvent *clientEvent))completion {


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSString *eventId = [self generateEventIdWithNamespace:namespace name:name];
        [logger info:@"Track event... (eventId: %@)", eventId];

        NSMutableDictionary *processedProperties = [NSMutableDictionary dictionaryWithDictionary:properties];

        GAClientEvent *existingClientEvent = [GAClientEvent load:eventId];

        if (option == GATrackOptionOnce) {
            if (existingClientEvent) {
                [logger info:@"Event already sent with once option. (eventId: %@)", eventId];
                return;
            }
        }

        if (option == GATrackOptionCounter) {
            int counter = 0;
            if (existingClientEvent && existingClientEvent.properties) {
                counter = [[existingClientEvent.properties objectForKey:@"counter"] intValue];
            }
            [processedProperties setValue:[NSString stringWithFormat:@"%d", (counter + 1)] forKey:@"counter"];
        }

        GAClientEvent *clientEvent = [GAClientEvent createWithClientId:[[[GrowthbeatCore sharedInstance] waitClient] id] eventId:eventId properties:processedProperties credentialId:credentialId];
        if (clientEvent) {
            [GAClientEvent save:clientEvent];
            [logger info:@"Tracking event success. (id: %@, eventId: %@, properties: %@)", clientEvent.id, eventId, processedProperties];
        }

        for (GAEventHandler *eventHandler in [eventHandlers objectEnumerator]) {
            if (eventHandler.callback) {
                eventHandler.callback(eventId, processedProperties);
            }
        }

        if (completion) {
            completion(clientEvent);
        }

    });

}

- (void) addEventHandler:(GAEventHandler *)eventHandler {
    [eventHandlers addObject:eventHandler];
}

- (void) tag:(NSString *)name {
    [self tag:kGACustomNamespace name:name value:nil completion:nil];
}

- (void) tag:(NSString *)name value:(NSString *)value {
    [self tag:kGACustomNamespace name:name value:value completion:nil];
}

- (void) tag:(NSString *)namespace name:(NSString *)name value:(NSString *)value completion:(void (^)(GAClientTag *clientTag))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSString *tagId = [self generateTagIdWithNamespace:namespace name:name];

        [logger info:@"Set tag... (tagId: %@, value: %@)", tagId, value];

        GAClientTag *existingClientTag = [GAClientTag load:tagId];
        if (existingClientTag) {
            if (value == existingClientTag.value || (value && [value isEqualToString:existingClientTag.value])) {
                [logger info:@"Tag exists with the same value. (tagId: %@, value: %@)", tagId, value];
                return;
            }
            [logger info:@"Tag exists with the other value. (tagId: %@, value: %@)", tagId, value];
        }

        GAClientTag *clientTag = [GAClientTag createWithClientId:[[[GrowthbeatCore sharedInstance] waitClient] id] tagId:tagId value:value credentialId:credentialId];
        if (clientTag) {
            [GAClientTag save:clientTag];
            [logger info:@"Setting tag success. (tagId: %@)", tagId];
        }

        if (completion) {
            completion(clientTag);
        }

    });

}


- (void) open {
    openTime = [NSDate date];
    [self track:kGADefaultNamespace name:@"Open" properties:nil option:GATrackOptionCounter completion:nil];
    [self track:kGADefaultNamespace name:@"Install" properties:nil option:GATrackOptionOnce completion:nil];
}

- (void) close {

    if (!openTime) {
        return;
    }

    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:openTime];
    openTime = nil;

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:[NSString stringWithFormat:@"%d", (int)time] forKey:@"time"];

    UIBackgroundTaskIdentifier __block backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
            backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self track:kGADefaultNamespace name:@"Close" properties:properties option:GATrackOptionDefault completion:^(GAClientEvent *clientEvent) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
            backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    });

}

- (void) purchase:(int)price setCategory:(NSString *)category setProduct:(NSString *)product {

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];

    [properties setObject:[NSString stringWithFormat:@"%d", price] forKey:@"price"];
    if (category) {
        [properties setObject:category forKey:@"category"];
    }
    if (product) {
        [properties setObject:product forKey:@"product"];
    }

    [self track:kGADefaultNamespace name:@"Purchase" properties:properties option:GATrackOptionDefault completion:nil];

}

- (void) setUserId:(NSString *)userId {
    [self tag:kGADefaultNamespace name:@"UserId" value:userId completion:nil];
}

- (void) setName:(NSString *)name {
    [self tag:kGADefaultNamespace name:@"Name" value:name completion:nil];
}

- (void) setAge:(int)age {
    [self tag:kGADefaultNamespace name:@"Age" value:[NSString stringWithFormat:@"%d", age] completion:nil];
}

- (void) setGender:(GAGender)gender {
    switch (gender) {
        case GAGenderMale:
            [self tag:kGADefaultNamespace name:@"Gender" value:@"male" completion:nil];
            break;
        case GAGenderFemale:
            [self tag:kGADefaultNamespace name:@"Gender" value:@"female" completion:nil];
            break;
        default:
            break;
    }
}

- (void) setLevel:(int)level {
    [self tag:kGADefaultNamespace name:@"Level" value:[NSString stringWithFormat:@"%d", level] completion:nil];
}

- (void) setDevelopment:(BOOL)development {
    [self tag:kGADefaultNamespace name:@"Development" value:development ? @"true" : @"false" completion:nil];
}

- (void) setDeviceModel {
    [self tag:kGADefaultNamespace name:@"DeviceModel" value:[GBDeviceUtils model] completion:nil];
}

- (void) setOS {
    [self tag:kGADefaultNamespace name:@"OS" value:[GBDeviceUtils os] completion:nil];
}

- (void) setLanguage {
    [self tag:kGADefaultNamespace name:@"Language" value:[GBDeviceUtils language] completion:nil];
}

- (void) setTimeZone {
    [self tag:kGADefaultNamespace name:@"TimeZone" value:[GBDeviceUtils timeZone] completion:nil];
}

- (void) setTimeZoneOffset {
    [self tag:kGADefaultNamespace name:@"TimeZoneOffset" value:[NSString stringWithFormat:@"%ld", (long)[GBDeviceUtils timeZoneOffset]] completion:nil];
}

- (void) setAppVersion {
    [self tag:kGADefaultNamespace name:@"AppVersion" value:[GBDeviceUtils version] completion:nil];
}

- (void) setRandom {
    double random = (double)arc4random() / ARC4RANDOM_MAX;

    [self tag:kGADefaultNamespace name:@"Random" value:[NSString stringWithFormat:@"%lf", random] completion:nil];
}

- (void) setAdvertisingId {
    ASIdentifierManager *identifierManager = [ASIdentifierManager sharedManager];

    if ([identifierManager isAdvertisingTrackingEnabled]) {
        [self tag:kGADefaultNamespace name:@"AdvertisingID" value:identifierManager.advertisingIdentifier.UUIDString completion:nil];
    }
}

- (void) setTrackingEnabled {
    ASIdentifierManager *identifierManager = [ASIdentifierManager sharedManager];

    [self tag:kGADefaultNamespace name:@"TrackingEnabled" value:[identifierManager isAdvertisingTrackingEnabled] ? @"true" : @"false" completion:nil];
}

- (void) setBasicTags {
    [self setDeviceModel];
    [self setOS];
    [self setLanguage];
    [self setTimeZone];
    [self setTimeZoneOffset];
    [self setAppVersion];
    [self setAdvertisingId];
    [self setTrackingEnabled];
}

- (NSString *) generateEventIdWithNamespace:(NSString *)namespace name:(NSString *)name {
    return [NSString stringWithFormat:@"Event:%@:%@:%@", applicationId, namespace, name];
}

- (NSString *) generateTagIdWithNamespace:(NSString *)namespace name:(NSString *)name {
    return [NSString stringWithFormat:@"Tag:%@:%@:%@", applicationId, namespace, name];
}

@end
