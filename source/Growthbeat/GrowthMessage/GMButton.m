//
//  GMButton.m
//  GrowthMessage
//
//  Created by 堀内 暢之 on 2015/03/03.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMButton.h"
#import "GBIntent.h"
#import "GMMessage.h"
#import "GMPlainButton.h"
#import "GMImageButton.h"
#import "GMCloseButton.h"
#import "GMScreenButton.h"

@implementation GMButton

@synthesize type;
@synthesize created;
@synthesize message;
@synthesize intent;

+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {

    GMButton *button = [[self alloc] initWithDictionary:dictionary];

    switch (button.type) {
        case GMButtonTypePlain:
            if ([button isKindOfClass:[GMPlainButton class]]) {
                return button;
            } else {
                return [GMPlainButton domainWithDictionary:dictionary];
            }
        case GMButtonTypeImage:
            if ([button isKindOfClass:[GMImageButton class]]) {
                return button;
            } else {
                return [GMImageButton domainWithDictionary:dictionary];
            }
        case GMButtonTypeClose:
            if ([button isKindOfClass:[GMCloseButton class]]) {
                return button;
            } else {
                return [GMCloseButton domainWithDictionary:dictionary];
            }
        case GMButtonTypeScreen:
            if ([button isKindOfClass:[GMScreenButton class]]) {
                return button;
            } else {
                return [GMScreenButton domainWithDictionary:dictionary];
            }
        default:
            return nil;
    }

}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"type"] && [dictionary objectForKey:@"type"] != [NSNull null]) {
            self.type = GMButtonTypeFromNSString([dictionary objectForKey:@"type"]);
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [dictionary objectForKey:@"created"];
        }
        if ([dictionary objectForKey:@"message"] && [dictionary objectForKey:@"message"] != [NSNull null]) {
            self.message = [GMMessage domainWithDictionary:[dictionary objectForKey:@"message"]];
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
