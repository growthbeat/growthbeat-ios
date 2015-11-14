//
//  GMImageButton.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMImageButton.h"

@implementation GMImageButton

@synthesize picture;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"picture"] && [dictionary objectForKey:@"picture"] != [NSNull null]) {
            self.picture = [GMPicture domainWithDictionary:[dictionary objectForKey:@"picture"]];
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"picture"]) {
            self.picture = [aDecoder decodeObjectForKey:@"picture"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:picture forKey:@"picture"];
}

@end
