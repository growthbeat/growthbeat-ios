//
//  GMTask.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/15.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMTask.h"
#import "GBDateUtils.h"

@implementation GMTask

@synthesize id;
@synthesize applicationId;
@synthesize name;
@synthesize description;
@synthesize orientation;
@synthesize availableFrom;
@synthesize availableTo;
@synthesize disabled;
@synthesize created;
@synthesize updated;

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
        if ([dictionary objectForKey:@"description"] && [dictionary objectForKey:@"description"] != [NSNull null]) {
            self.description = [dictionary objectForKey:@"description"];
        }
        if ([dictionary objectForKey:@"orientation"] && [dictionary objectForKey:@"orientation"] != [NSNull null]) {
            self.orientation = GMMessageOrientationFromNSString([dictionary objectForKey:@"orientation"]);
        }
        if ([dictionary objectForKey:@"availableFrom"] && [dictionary objectForKey:@"availableFrom"] != [NSNull null]) {
            self.availableFrom = [dictionary objectForKey:@"availableFrom"];
        }
        if ([dictionary objectForKey:@"availableTo"] && [dictionary objectForKey:@"availableTo"] != [NSNull null]) {
            self.availableTo = [dictionary objectForKey:@"availableTo"];
        }
        if ([dictionary objectForKey:@"disabled"] && [dictionary objectForKey:@"disabled"] != [NSNull null]) {
            self.disabled = [[dictionary objectForKey:@"disabled"] boolValue];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
        }
        if ([dictionary objectForKey:@"updated"] && [dictionary objectForKey:@"updated"] != [NSNull null]) {
            self.updated = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"updated"]];
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
        if ([aDecoder containsValueForKey:@"description"]) {
            self.description = [aDecoder decodeObjectForKey:@"description"];
        }
        if ([aDecoder containsValueForKey:@"orientation"]) {
            self.orientation = [aDecoder decodeIntegerForKey:@"orientation"];
        }
        if ([aDecoder containsValueForKey:@"availableFrom"]) {
            self.availableFrom = [aDecoder decodeObjectForKey:@"availableFrom"];
        }
        if ([aDecoder containsValueForKey:@"availableTo"]) {
            self.availableTo = [aDecoder decodeObjectForKey:@"availableTo"];
        }
        if ([aDecoder containsValueForKey:@"disabled"]) {
            self.disabled = [aDecoder decodeBoolForKey:@"disabled"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"updated"]) {
            self.updated = [aDecoder decodeObjectForKey:@"updated"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:applicationId forKey:@"applicationId"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:description forKey:@"description"];
    [aCoder encodeInteger:orientation forKey:@"orientation"];
    [aCoder encodeObject:availableFrom forKey:@"availableFrom"];
    [aCoder encodeObject:availableTo forKey:@"availableTo"];
    [aCoder encodeBool:disabled forKey:@"disabled"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:updated forKey:@"updated"];
}

@end
