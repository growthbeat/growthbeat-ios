//
//  GPPlainButton.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPPlainButton.h"

@implementation GPPlainButton

@synthesize label;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"label"] && [dictionary objectForKey:@"label"] != [NSNull null]) {
            self.label = [dictionary objectForKey:@"label"];
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"label"]) {
            self.label = [aDecoder decodeObjectForKey:@"label"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:label forKey:@"label"];
}

@end
