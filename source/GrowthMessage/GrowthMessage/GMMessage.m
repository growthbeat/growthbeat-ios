//
//  GMMessage.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthMessage.h"
#import "GMPlainMessage.h"
#import "GMImageMessage.h"
#import "GMBannerMessage.h"

@implementation GMMessage

@synthesize id;
@synthesize version;
@synthesize type;
@synthesize eventId;
@synthesize frequency;
@synthesize segmentId;
@synthesize cap;
@synthesize created;
@synthesize task;
@synthesize buttons;

+ (instancetype) receiveWithClientId:(NSString *)clientId eventId:(NSString *)eventId credentialId:(NSString *)credentialId {

    NSString *path = @"/1/receive";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (eventId) {
        [body setObject:eventId forKey:@"eventId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthMessage sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthMessage sharedInstance] logger] error:@"Failed to receive message. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }

    if (!httpResponse.body) {
        [[[GrowthMessage sharedInstance] logger] info:@"No message is received."];
        return nil;
    }

    [[[GrowthMessage sharedInstance] logger] info:@"A message is received."];

    return [GMMessage domainWithDictionary:httpResponse.body];

}

+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {

    GMMessage *message = [[self alloc] initWithDictionary:dictionary];

    switch (message.type) {
        case GMMessageTypePlain:
            if ([message isKindOfClass:[GMPlainMessage class]]) {
                return message;
            } else {
                return [GMPlainMessage domainWithDictionary:dictionary];
            }
        case GMMessageTypeImage:
            if ([message isKindOfClass:[GMImageMessage class]]) {
                return message;
            } else {
                return [GMImageMessage domainWithDictionary:dictionary];
            }
        case GMMessageTypeBanner:
            if ([message isKindOfClass:[GMBannerMessage class]]) {
                return message;
            } else {
                return [GMBannerMessage domainWithDictionary:dictionary];
            }
        default:
            return nil;
    }

}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"version"] && [dictionary objectForKey:@"version"] != [NSNull null]) {
            self.version = [[dictionary objectForKey:@"version"] integerValue];
        }
        if ([dictionary objectForKey:@"type"] && [dictionary objectForKey:@"type"] != [NSNull null]) {
            self.type = GMMessageTypeFromNSString([dictionary objectForKey:@"type"]);
        }
        if ([dictionary objectForKey:@"eventId"] && [dictionary objectForKey:@"eventId"] != [NSNull null]) {
            self.eventId = [dictionary objectForKey:@"eventId"];
        }
        if ([dictionary objectForKey:@"frequency"] && [dictionary objectForKey:@"frequency"] != [NSNull null]) {
            self.frequency = [[dictionary objectForKey:@"frequency"] integerValue];
        }
        if ([dictionary objectForKey:@"segmentId"] && [dictionary objectForKey:@"segmentId"] != [NSNull null]) {
            self.segmentId = [dictionary objectForKey:@"segmentId"];
        }
        if ([dictionary objectForKey:@"cap"] && [dictionary objectForKey:@"cap"] != [NSNull null]) {
            self.cap = [[dictionary objectForKey:@"cap"] integerValue];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [dictionary objectForKey:@"created"];
        }
        if ([dictionary objectForKey:@"task"] && [dictionary objectForKey:@"task"] != [NSNull null]) {
            self.task = [GMTask domainWithDictionary:[dictionary objectForKey:@"task"]];
        }
        if ([dictionary objectForKey:@"buttons"] && [dictionary objectForKey:@"buttons"] != [NSNull null]) {
            NSMutableArray *newButtons = [NSMutableArray array];
            for (NSDictionary *buttonDictionary in [dictionary objectForKey:@"buttons"]) {
                [newButtons addObject:[GMButton domainWithDictionary:buttonDictionary]];
            }
            self.buttons = newButtons;
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"id"]) {
            self.id = [aDecoder decodeObjectForKey:@"id"];
        }
        if ([aDecoder containsValueForKey:@"version"]) {
            self.version = [aDecoder decodeIntegerForKey:@"version"];
        }
        if ([aDecoder containsValueForKey:@"type"]) {
            self.type = [aDecoder decodeIntegerForKey:@"type"];
        }
        if ([aDecoder containsValueForKey:@"eventId"]) {
            self.eventId = [aDecoder decodeObjectForKey:@"eventId"];
        }
        if ([aDecoder containsValueForKey:@"frequency"]) {
            self.frequency = [aDecoder decodeIntegerForKey:@"frequency"];
        }
        if ([aDecoder containsValueForKey:@"segmentId"]) {
            self.segmentId = [aDecoder decodeObjectForKey:@"segmentId"];
        }
        if ([aDecoder containsValueForKey:@"cap"]) {
            self.cap = [aDecoder decodeIntegerForKey:@"cap"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"task"]) {
            self.task = [aDecoder decodeObjectForKey:@"task"];
        }
        if ([aDecoder containsValueForKey:@"buttons"]) {
            self.buttons = [aDecoder decodeObjectForKey:@"buttons"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeInteger:version forKey:@"version"];
    [aCoder encodeInteger:type forKey:@"type"];
    [aCoder encodeObject:eventId forKey:@"eventId"];
    [aCoder encodeInteger:frequency forKey:@"frequency"];
    [aCoder encodeObject:segmentId forKey:@"segmentId"];
    [aCoder encodeInteger:cap forKey:@"cap"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:task forKey:@"task"];
    [aCoder encodeObject:buttons forKey:@"buttons"];
}


@end
