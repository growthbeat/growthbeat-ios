//
//  GLPattern.m
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/06/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLPattern.h"
#import "GBUtils.h"

@implementation GLPattern

@synthesize id;
@synthesize url;
@synthesize link;
@synthesize intent;
@synthesize created;
@synthesize updated;

- (id) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"url"] && [dictionary objectForKey:@"url"] != [NSNull null]) {
            self.url = [dictionary objectForKey:@"url"];
        }
        if ([dictionary objectForKey:@"link"] && [dictionary objectForKey:@"link"] != [NSNull null]) {
            self.link = [GLLink domainWithDictionary:[dictionary objectForKey:@"link"]];
        }
        if ([dictionary objectForKey:@"intent"] && [dictionary objectForKey:@"intent"] != [NSNull null]) {
            self.intent = [GBIntent domainWithDictionary:[dictionary objectForKey:@"intent"]];
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
        if ([aDecoder containsValueForKey:@"url"]) {
            self.url = [aDecoder decodeObjectForKey:@"url"];
        }
        if ([aDecoder containsValueForKey:@"link"]) {
            self.link = [aDecoder decodeObjectForKey:@"link"];
        }
        if ([aDecoder containsValueForKey:@"intent"]) {
            self.intent = [aDecoder decodeObjectForKey:@"intent"];
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
    [aCoder encodeObject:url forKey:@"url"];
    [aCoder encodeObject:link forKey:@"link"];
    [aCoder encodeObject:intent forKey:@"intent"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:updated forKey:@"updated"];
}


@end
