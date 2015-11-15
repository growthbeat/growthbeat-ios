//
//  GrowthMessage.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowthbeatCore.h"
#import "GMMessageHandler.h"
#import "GMButton.h"

@interface GrowthMessage : NSObject {

    NSString *applicationId;
    NSString *credentialId;

    NSArray *messageHandlers;

}

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

@property (nonatomic, strong) NSArray *messageHandlers;

- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

- (void)selectButton:(GMButton *)button message:(GMMessage *)message;

- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;


@end
