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

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"swipeType"] && [dictionary objectForKey:@"swipeType"] != [NSNull null]) {
            self.swipeType = GPSwipeMessageTypeFromNSString([dictionary objectForKey:@"swipeType"]);
        }
        if ([dictionary objectForKey:@"swipeImages"] && [dictionary objectForKey:@"swipeImages"] != [NSNull null]) {
            self.swipeImages = [GPSwipeImages domainWithDictionary:[dictionary objectForKey:@"swipeImages"]];
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
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:NSStringFromGPSwipeMessageType(swipeType) forKey:@"swipeType"];
    [aCoder encodeObject:swipeImages forKey:@"swipeImages"];
}

@end
