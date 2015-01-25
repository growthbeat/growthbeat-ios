//
//  GrowthReplay.h
//  replay
//
//  Created by A13048 on 2014/01/23.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowthbeatCore.h"

@interface GrowthReplay : NSObject

+ (GrowthReplay *) sharedInstance;

- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

- (void)start;

- (void)stop;

- (void)setSpot:(NSString *)spot;

- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

@end
