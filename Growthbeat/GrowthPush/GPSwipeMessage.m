//
//  GPSwipeMessage.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeMessage.h"
#import "GPPicture.h"

@implementation GPSwipeMessage

@synthesize swipeType;
@synthesize pictures;
@synthesize baseWidth;
@synthesize baseHeight;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"swipeType"] && [dictionary objectForKey:@"swipeType"] != [NSNull null]) {
            self.swipeType = GPSwipeMessageTypeFromNSString([dictionary objectForKey:@"swipeType"]);
        }
        if ([dictionary objectForKey:@"pictures"] && [dictionary objectForKey:@"pictures"] != [NSNull null]) {
            NSMutableArray *pictureArray = [NSMutableArray array];
            NSArray *array  = (NSArray*)[dictionary objectForKey:@"pictures"];
            for (NSDictionary *dictionary in array) {
                [pictureArray addObject:[GPPicture domainWithDictionary:dictionary]];
            }
            self.pictures = pictureArray;
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
        if ([aDecoder containsValueForKey:@"pictures"]) {
            self.pictures = [aDecoder decodeObjectForKey:@"pictures"];
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
    [aCoder encodeObject:pictures forKey:@"pictures"];
    [aCoder encodeInteger:baseWidth forKey:@"baseWidth"];
    [aCoder encodeInteger:baseHeight forKey:@"baseHeight"];
}

@end
