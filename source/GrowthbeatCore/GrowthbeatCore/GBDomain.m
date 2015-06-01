//
//  GBDomain.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GBHttpClient.h"

@implementation GBDomain

+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {

    if (!dictionary) {
        return nil;
    }

    return [[self alloc] initWithDictionary:dictionary];

}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    return [self init];
}

@end
