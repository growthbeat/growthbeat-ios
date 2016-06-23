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

- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"color"] && [dictionary objectForKey:@"color"] != [NSNull null]) {
            self.color = [[dictionary objectForKey:@"color"] integerValue];
        }
        if ([dictionary objectForKey:@"opacity"] && [dictionary objectForKey:@"opacity"] != [NSNull null]) {
            self.opacity = [[dictionary objectForKey:@"opacity"] floatValue];
        }
        if ([dictionary objectForKey:@"outsideClose"] && [dictionary objectForKey:@"outsideClose"] != [NSNull null]) {
            self.outsideClose = [[dictionary objectForKey:@"outsideClose"] boolValue];
        }
    }
    
    return self;
    
}

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
            self.outsideClose = [aDecoder decodeBoolForKey:@"outsideClose"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:color forKey:@"color"];
    [aCoder encodeFloat:opacity forKey:@"opacity"];
    [aCoder encodeBool:outsideClose forKey:@"outsideClose"];
}


@end
