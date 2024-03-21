//
//  Growthbeat.h
//  Growthbeat
//
//  Created by 片岡 直之 on 2024/03/21.
//

#import <Foundation/Foundation.h>
#import "GBLogger.h"
#import "GBHttpClient.h"
#import "GBPreference.h"
#import "GBUtils.h"
#import "GBClient.h"
#import "GBAppDelegateWrapper.h"
#import "GrowthPush.h"
#import "GBIntent.h"
#import "GBIntentHandler.h"
#import "GBUrlIntentHandler.h"
#import "GBNoopIntentHandler.h"
#import "GBCustomIntentHandler.h"
#import "GBCustomIntent.h"

//! Project version number for Growthbeat.
FOUNDATION_EXPORT double GrowthbeatVersionNumber;

//! Project version string for Growthbeat.
FOUNDATION_EXPORT const unsigned char GrowthbeatVersionString[];

@interface Growthbeat : NSObject {

    NSMutableArray *intentHandlers;

}

@property (nonatomic, strong) NSArray *intentHandlers;

+ (Growthbeat *)sharedInstance;

- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

- (GBClient *)client;
- (GBClient *)waitClient;

- (void)setLoggerSilent:(BOOL) silent;
- (BOOL)handleIntent:(GBIntent *)intent;
- (void)addIntentHandler:(NSObject *)intentHandler;
- (void)addCustomIntentHandlerWithBlock:(BOOL(^)(GBCustomIntent *customIntent))block;


@end
