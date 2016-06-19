//
//  GPSwipeImages.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeImages.h"
#import "GPPicture.h"
#import "GBUtils.h"

@implementation GPSwipeImages

@synthesize pictures;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"pictures"] && [dictionary objectForKey:@"pictures"] != [NSNull null]) {
            NSMutableArray *newPictures = [NSMutableArray array];
            for (NSDictionary *pictureDictionary in [dictionary objectForKey:@"pictures"]) {
                [newPictures addObject:[GPPicture domainWithDictionary:pictureDictionary]];
            }
            self.pictures = newPictures;
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"pictures"]) {
            self.pictures = [aDecoder decodeObjectForKey:@"pictures"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:pictures forKey:@"pictures"];
}

@end

