//
//  GPPicture.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPPicture.h"
#import "GBUtils.h"

@implementation GPPicture

@synthesize id;
@synthesize applicationId;
@synthesize width;
@synthesize height;
@synthesize created;
@synthesize url;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"applicationId"] && [dictionary objectForKey:@"applicationId"] != [NSNull null]) {
            self.applicationId = [dictionary objectForKey:@"applicationId"];
        }
        if ([dictionary objectForKey:@"width"] && [dictionary objectForKey:@"width"] != [NSNull null]) {
            self.width = [[dictionary objectForKey:@"width"] floatValue];
        }
        if ([dictionary objectForKey:@"height"] && [dictionary objectForKey:@"height"] != [NSNull null]) {
            self.height = [[dictionary objectForKey:@"height"] floatValue];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
        }
        if ([dictionary objectForKey:@"url"] && [dictionary objectForKey:@"url"] != [NSNull null]) {
            self.url = [dictionary objectForKey:@"url"];
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
        if ([aDecoder containsValueForKey:@"width"]) {
            self.width = [aDecoder decodeFloatForKey:@"width"];
        }
        if ([aDecoder containsValueForKey:@"height"]) {
            self.height = [aDecoder decodeFloatForKey:@"height"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"url"]) {
            self.url = [aDecoder decodeObjectForKey:@"url"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:applicationId forKey:@"applicationId"];
    [aCoder encodeObject:@(width) forKey:@"width"];
    [aCoder encodeObject:@(height) forKey:@"height"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:url forKey:@"url"];
}

@end
