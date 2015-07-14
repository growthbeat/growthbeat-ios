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
@synthesize pictures;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"pictures"] && [dictionary objectForKey:@"pictures"] != [NSNull null]) {
//            self.pictures = [NSArray domainWithDictionary:[dictionary objectForKey:@"pictures"]];
        }
        if ([dictionary objectForKey:@"swipeType"] && [dictionary objectForKey:@"swipeType"] != [NSNull null]) {
            self.swipeType = GMSwipeMessageTypeFromNSString([dictionary objectForKey:@"swipeType"]);
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"pictures"]) {
            self.pictures = [aDecoder decodeObjectForKey:@"pictures"];
        }
        if ([aDecoder containsValueForKey:@"swipeType"]) {
            self.swipeType = GMSwipeMessageTypeFromNSString([aDecoder decodeObjectForKey:@"swipeType"]);
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:pictures forKey:@"pictures"];
    [aCoder encodeObject:NSStringFromGMSwipeMessageType(swipeType) forKey:@"swipeType"];
}

@end
