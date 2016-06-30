//
//  GBCustomIntent.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBCustomIntent.h"

@implementation GBCustomIntent

@synthesize extra;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"extra"] && [dictionary objectForKey:@"extra"] != [NSNull null]) {
            self.extra = [dictionary objectForKey:@"extra"];
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"extra"]) {
            self.extra = [aDecoder decodeObjectForKey:@"extra"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:extra forKey:@"extra"];
}

@end
