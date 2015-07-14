//
//  GMSwipeMessage.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessage.h"
#import "GMPicture.h"

@implementation GMSwipeMessage

@synthesize swipeType;
@synthesize pictures;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"swipeType"] && [dictionary objectForKey:@"swipeType"] != [NSNull null]) {
            self.swipeType = GMSwipeMessageTypeFromNSString([dictionary objectForKey:@"swipeType"]);
        }
        if ([dictionary objectForKey:@"pictures"] && [dictionary objectForKey:@"pictures"] != [NSNull null]) {
            NSMutableArray *newPictures = [NSMutableArray array];
            for (NSDictionary *pictureDictionary in [dictionary objectForKey:@"pictures"]) {
                [newPictures addObject:[GMPicture domainWithDictionary:pictureDictionary]];
            }
            self.pictures = newPictures;
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
        if ([aDecoder containsValueForKey:@"pictures"]) {
            self.pictures = [aDecoder decodeObjectForKey:@"pictures"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:NSStringFromGMSwipeMessageType(swipeType) forKey:@"swipeType"];
    [aCoder encodeObject:pictures forKey:@"pictures"];
}

@end
