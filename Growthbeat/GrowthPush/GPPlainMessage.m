//
//  GPPlainMessage.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPPlainMessage.h"

@implementation GPPlainMessage

@synthesize caption;
@synthesize text;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"caption"] && [dictionary objectForKey:@"caption"] != [NSNull null]) {
            self.caption = [dictionary objectForKey:@"caption"];
        }
        if ([dictionary objectForKey:@"text"] && [dictionary objectForKey:@"text"] != [NSNull null]) {
            self.text = [dictionary objectForKey:@"text"];
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"caption"]) {
            self.caption = [aDecoder decodeObjectForKey:@"caption"];
        }
        if ([aDecoder containsValueForKey:@"text"]) {
            self.text = [aDecoder decodeObjectForKey:@"text"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:caption forKey:@"caption"];
    [aCoder encodeObject:text forKey:@"text"];
}


@end
