//
//  GMSwipeImages.m
//  Growthbeat
//
//  Created by 尾川 茂 on 2015/08/18.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeImages.h"
#import "GMPicture.h"
#import "GBUtils.h"

@implementation GMSwipeImages

@synthesize pictures;
@synthesize widthRatio;
@synthesize topMargin;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"pictures"] && [dictionary objectForKey:@"pictures"] != [NSNull null]) {
            NSMutableArray *newPictures = [NSMutableArray array];
            for (NSDictionary *pictureDictionary in [dictionary objectForKey:@"pictures"]) {
                [newPictures addObject:[GMPicture domainWithDictionary:pictureDictionary]];
            }
            self.pictures = newPictures;
        }
        if ([dictionary objectForKey:@"widthRatio"] && [dictionary objectForKey:@"widthRatio"] != [NSNull null]) {
            self.widthRatio = [[dictionary objectForKey:@"widthRatio"] floatValue];
        }
        if ([dictionary objectForKey:@"topMargin"] && [dictionary objectForKey:@"topMargin"] != [NSNull null]) {
            self.topMargin = [[dictionary objectForKey:@"topMargin"] floatValue];
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
        if ([aDecoder containsValueForKey:@"widthRatio"]) {
            self.widthRatio = [aDecoder decodeFloatForKey:@"widthRatio"];
        }
        if ([aDecoder containsValueForKey:@"topMargin"]) {
            self.topMargin = [aDecoder decodeFloatForKey:@"topMargin"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:pictures forKey:@"pictures"];
    [aCoder encodeFloat:widthRatio forKey:@"widthRatio"];
    [aCoder encodeFloat:topMargin forKey:@"topMargin"];
}

@end

