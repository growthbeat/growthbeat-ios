//
//  GPButton.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPButton.h"
#import "GBIntent.h"
#import "GPMessage.h"
#import "GPPlainButton.h"
#import "GPImageButton.h"
#import "GPCloseButton.h"
#import "GPScreenButton.h"

@implementation GPButton

@synthesize type;
@synthesize created;
@synthesize message;
@synthesize intent;

+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {
    
    GPButton *button = [[self alloc] initWithDictionary:dictionary];
    
    switch (button.type) {
        case GPButtonTypePlain:
            if ([button isKindOfClass:[GPPlainButton class]]) {
                return button;
            } else {
                return [GPPlainButton domainWithDictionary:dictionary];
            }
        case GPButtonTypeImage:
            if ([button isKindOfClass:[GPImageButton class]]) {
                return button;
            } else {
                return [GPImageButton domainWithDictionary:dictionary];
            }
        case GPButtonTypeClose:
            if ([button isKindOfClass:[GPCloseButton class]]) {
                return button;
            } else {
                return [GPCloseButton domainWithDictionary:dictionary];
            }
        case GPButtonTypeScreen:
            if ([button isKindOfClass:[GPScreenButton class]]) {
                return button;
            } else {
                return [GPScreenButton domainWithDictionary:dictionary];
            }
        default:
            return nil;
    }
    
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"type"] && [dictionary objectForKey:@"type"] != [NSNull null]) {
            self.type = GPButtonTypeFromNSString([dictionary objectForKey:@"type"]);
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [dictionary objectForKey:@"created"];
        }
        if ([dictionary objectForKey:@"message"] && [dictionary objectForKey:@"message"] != [NSNull null]) {
            self.message = [GPMessage domainWithDictionary:[dictionary objectForKey:@"message"]];
        }
        if ([dictionary objectForKey:@"intent"] && [dictionary objectForKey:@"intent"] != [NSNull null]) {
            self.intent = [GBIntent domainWithDictionary:[dictionary objectForKey:@"intent"]];
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"type"]) {
            self.type = [aDecoder decodeIntegerForKey:@"type"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"message"]) {
            self.message = [aDecoder decodeObjectForKey:@"message"];
        }
        if ([aDecoder containsValueForKey:@"intent"]) {
            self.intent = [aDecoder decodeObjectForKey:@"intent"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:type forKey:@"type"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:message forKey:@"message"];
    [aCoder encodeObject:intent forKey:@"intent"];
}

@end
