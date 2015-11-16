//
//  GBApplication.m
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/18.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GBApplication.h"
#import "GBUtils.h"

@implementation GBApplication

@synthesize id;
@synthesize name;
@synthesize created;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"name"] && [dictionary objectForKey:@"name"] != [NSNull null]) {
            self.name = [dictionary objectForKey:@"name"];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {

    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"id"]) {
            self.id = [aDecoder decodeObjectForKey:@"id"];
        }
        if ([aDecoder containsValueForKey:@"name"]) {
            self.name = [aDecoder decodeObjectForKey:@"name"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
    }
    return self;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:created forKey:@"created"];

}

@end
