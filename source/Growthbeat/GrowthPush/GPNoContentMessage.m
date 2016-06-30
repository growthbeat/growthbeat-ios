//
//  GPNoContentMessage.m
//  Growthbeat
//
//  Created by Shigeru Ogawa on 2016/06/26.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPNoContentMessage.h"

@implementation GPNoContentMessage

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
    }
 
    return self;
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}


@end
