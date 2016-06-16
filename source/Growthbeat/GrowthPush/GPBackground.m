//
//  GPBackground.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/16.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPBackground.h"

@implementation GPBackground

@synthesize color;
@synthesize opacity;
@synthesize outsideClose;

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"color"]) {
            self.color = [aDecoder decodeIntegerForKey:@"color"];
        }
        if ([aDecoder containsValueForKey:@"opacity"]) {
            self.opacity = [aDecoder decodeFloatForKey:@"opacity"];
        }
        if ([aDecoder containsValueForKey:@"outsideClose"]) {
            self.outsideClose = [aDecoder decodeIntegerForKey:@"outsideClose"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:color forKey:@"color"];
    [aCoder encodeFloat:opacity forKey:@"opacity"];
    [aCoder encodeInteger:outsideClose forKey:@"outsideClose"];
}


@end
