//
//  GMSwipeMessage.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessage.h"

@implementation GMSwipeMessage

@synthesize swipeType;
@synthesize swipeImages;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"swipeType"] && [dictionary objectForKey:@"swipeType"] != [NSNull null]) {
            self.swipeType = GMSwipeMessageTypeFromNSString([dictionary objectForKey:@"swipeType"]);
        }
        if ([dictionary objectForKey:@"swipeImages"] && [dictionary objectForKey:@"swipeImages"] != [NSNull null]) {
            self.swipeImages = [GMSwipeImages domainWithDictionary:[dictionary objectForKey:@"swipeImages"]];
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"swipeType"]) {
            self.swipeType = GMSwipeMessageTypeFromNSString([aDecoder decodeObjectForKey:@"swipeType"]);
        }
        if ([aDecoder containsValueForKey:@"swipeImages"]) {
            self.swipeImages = [aDecoder decodeObjectForKey:@"swipeImages"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:NSStringFromGMSwipeMessageType(swipeType) forKey:@"swipeType"];
    [aCoder encodeObject:swipeImages forKey:@"swipeImages"];
}

@end
