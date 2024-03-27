//
//  GBUrlIntent.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBUrlIntent.h>

@implementation GBUrlIntent

@synthesize url;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"url"] && [dictionary objectForKey:@"url"] != [NSNull null]) {
            self.url = [dictionary objectForKey:@"url"];
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"url"]) {
            self.url = [aDecoder decodeObjectForKey:@"url"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:url forKey:@"url"];
}

@end
