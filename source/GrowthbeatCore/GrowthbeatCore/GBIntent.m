//
//  GBIntent.m
//  GrowthbeatCore
//
//  Created by 堀内 暢之 on 2015/03/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBIntent.h"
#import "GBDateUtils.h"
#import "GBCustomIntent.h"
#import "GBNoopIntent.h"
#import "GBUrlIntent.h"

@implementation GBIntent

@synthesize id;
@synthesize applicationId;
@synthesize name;
@synthesize type;
@synthesize created;

+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {

    GBIntent *intent = [[self alloc] initWithDictionary:dictionary];

    switch (intent.type) {
        case GBIntentTypeCustom:
            if ([intent isKindOfClass:[GBCustomIntent class]]) {
                return intent;
            } else {
                return [GBCustomIntent domainWithDictionary:dictionary];
            }
        case GBIntentTypeNoop:
            if ([intent isKindOfClass:[GBNoopIntent class]]) {
                return intent;
            } else {
                return [GBNoopIntent domainWithDictionary:dictionary];
            }
        case GBIntentTypeUrl:
            if ([intent isKindOfClass:[GBUrlIntent class]]) {
                return intent;
            } else {
                return [GBUrlIntent domainWithDictionary:dictionary];
            }
        default:
            return nil;
    }

}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"applicationId"] && [dictionary objectForKey:@"applicationId"] != [NSNull null]) {
            self.applicationId = [dictionary objectForKey:@"applicationId"];
        }
        if ([dictionary objectForKey:@"name"] && [dictionary objectForKey:@"name"] != [NSNull null]) {
            self.name = [dictionary objectForKey:@"name"];
        }
        if ([dictionary objectForKey:@"type"] && [dictionary objectForKey:@"type"] != [NSNull null]) {
            self.type = GBIntentTypeFromNSString([dictionary objectForKey:@"type"]);
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
        if ([aDecoder containsValueForKey:@"applicationId"]) {
            self.applicationId = [aDecoder decodeObjectForKey:@"applicationId"];
        }
        if ([aDecoder containsValueForKey:@"name"]) {
            self.name = [aDecoder decodeObjectForKey:@"name"];
        }
        if ([aDecoder containsValueForKey:@"type"]) {
            self.type = [aDecoder decodeIntegerForKey:@"type"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:applicationId forKey:@"applicationId"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeInteger:type forKey:@"type"];
    [aCoder encodeObject:created forKey:@"created"];
}

@end
