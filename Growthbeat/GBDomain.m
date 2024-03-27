//
//  GBDomain.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>
#import <Growthbeat/GBHttpClient.h>

@implementation GBDomain

+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {

    if (!dictionary) {
        return nil;
    }

    return [[self alloc] initWithDictionary:dictionary];

}

+ (NSArray *) domainArrayFromArray:(NSArray *)array {
    if (!array) {
        return nil;
    }
    NSMutableArray *results = [NSMutableArray array];
    for (id tempObject in array) {
        if (![tempObject isKindOfClass:[NSDictionary class]] ) {
            continue;
        }
        GBDomain *data = [[self alloc] initWithDictionary:(NSDictionary *)tempObject];
        if (!data) {
            continue;
        }
        [results addObject:data];
    }
    return results;
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    return [self init];
}

@end
