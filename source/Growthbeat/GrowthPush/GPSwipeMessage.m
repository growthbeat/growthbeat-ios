//
//  GPSwipeMessage.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeMessage.h"

@implementation GPSwipeMessage

@synthesize swipeType;
@synthesize swipeImages;
@synthesize baseWidth;
@synthesize baseHeight;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"swipeType"] && [dictionary objectForKey:@"swipeType"] != [NSNull null]) {
            self.swipeType = GPSwipeMessageTypeFromNSString([dictionary objectForKey:@"swipeType"]);
        }
        if ([dictionary objectForKey:@"swipeImages"] && [dictionary objectForKey:@"swipeImages"] != [NSNull null]) {
            self.swipeImages = [GPSwipeImages domainWithDictionary:[dictionary objectForKey:@"swipeImages"]];
        }
        if ([dictionary objectForKey:@"baseWidth"] && [dictionary objectForKey:@"baseWidth"] != [NSNull null]) {
            self.baseWidth = [[dictionary objectForKey:@"baseWidth"] integerValue];
        }
        if ([dictionary objectForKey:@"baseHeight"] && [dictionary objectForKey:@"baseHeight"] != [NSNull null]) {
            self.baseHeight = [[dictionary objectForKey:@"baseHeight"] integerValue];
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
            self.swipeType = GPSwipeMessageTypeFromNSString([aDecoder decodeObjectForKey:@"swipeType"]);
        }
        if ([aDecoder containsValueForKey:@"swipeImages"]) {
            self.swipeImages = [aDecoder decodeObjectForKey:@"swipeImages"];
        }
        if ([aDecoder containsValueForKey:@"baseWidth"]) {
            self.baseWidth = [aDecoder decodeIntegerForKey:@"baseWidth"];
        }
        if ([aDecoder containsValueForKey:@"baseHeight"]) {
            self.baseHeight = [aDecoder decodeIntegerForKey:@"baseHeight"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:NSStringFromGPSwipeMessageType(swipeType) forKey:@"swipeType"];
    [aCoder encodeObject:swipeImages forKey:@"swipeImages"];
    [aCoder encodeInteger:baseWidth forKey:@"baseWidth"];
    [aCoder encodeInteger:baseHeight forKey:@"baseHeight"];
}

@end
