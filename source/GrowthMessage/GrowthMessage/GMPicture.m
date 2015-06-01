//
//  GMPicture.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/20.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMPicture.h"
#import "GBUtils.h"

@implementation GMPicture

@synthesize id;
@synthesize applicationId;
@synthesize extension;
@synthesize width;
@synthesize height;
@synthesize name;
@synthesize created;
@synthesize updated;
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
        if ([dictionary objectForKey:@"extension"] && [dictionary objectForKey:@"extension"] != [NSNull null]) {
            self.extension = GMPictureExtensionFromNSString([dictionary objectForKey:@"extension"]);
        }
        if ([dictionary objectForKey:@"width"] && [dictionary objectForKey:@"width"] != [NSNull null]) {
            self.width = [[dictionary objectForKey:@"width"] integerValue];
        }
        if ([dictionary objectForKey:@"height"] && [dictionary objectForKey:@"height"] != [NSNull null]) {
            self.height = [[dictionary objectForKey:@"height"] integerValue];
        }
        if ([dictionary objectForKey:@"name"] && [dictionary objectForKey:@"name"] != [NSNull null]) {
            self.name = [dictionary objectForKey:@"name"];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
        }
        if ([dictionary objectForKey:@"updated"] && [dictionary objectForKey:@"updated"] != [NSNull null]) {
            self.updated = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"updated"]];
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
        if ([aDecoder containsValueForKey:@"extension"]) {
            self.extension = GMPictureExtensionFromNSString([aDecoder decodeObjectForKey:@"extension"]);
        }
        if ([aDecoder containsValueForKey:@"width"]) {
            self.width = [aDecoder decodeIntegerForKey:@"width"];
        }
        if ([aDecoder containsValueForKey:@"height"]) {
            self.height = [aDecoder decodeIntegerForKey:@"height"];
        }
        if ([aDecoder containsValueForKey:@"name"]) {
            self.name = [aDecoder decodeObjectForKey:@"name"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"updated"]) {
            self.updated = [aDecoder decodeObjectForKey:@"updated"];
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
    [aCoder encodeObject:NSStringFromGMPictureExtension(extension) forKey:@"extension"];
    [aCoder encodeInteger:width forKey:@"width"];
    [aCoder encodeInteger:height forKey:@"height"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:updated forKey:@"updated"];
    [aCoder encodeObject:url forKey:@"url"];
}

@end
