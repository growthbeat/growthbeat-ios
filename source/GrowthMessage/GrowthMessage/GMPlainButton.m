//
//  GMPlainButton.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMPlainButton.h"

@implementation GMPlainButton

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
