//
//  GAClientEvent.m
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GAClientEvent.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthAnalytics.h"

@implementation GAClientEvent

@synthesize id;
@synthesize clientId;
@synthesize eventId;
@synthesize properties;
@synthesize created;

+ (GAClientEvent *) createWithClientId:(NSString *)clientId eventId:(NSString *)eventId properties:(NSDictionary *)properties credentialId:(NSString *)credentialId {

    NSString *path = @"/1/client_events";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (eventId) {
        [body setObject:eventId forKey:@"eventId"];
    }
    if (properties) {
        for (id key in [properties keyEnumerator]) {
            id object = [properties objectForKey:key];
            if (!object) {
                continue;
            }
            [body setObject:object forKey:[NSString stringWithFormat:@"properties[%@]", key]];
        }
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthAnalytics sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthAnalytics sharedInstance] logger] error:@"Failed to create client event. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }

    return [GAClientEvent domainWithDictionary:httpResponse.body];

}

+ (void) save:(GAClientEvent *)clientEvent {
    if (clientEvent && clientEvent.eventId) {
        [[[GrowthAnalytics sharedInstance] preference] setObject:clientEvent forKey:clientEvent.eventId];
    }
}

+ (GAClientEvent *) load:(NSString *)eventId {
    return [[[GrowthAnalytics sharedInstance] preference] objectForKey:eventId];
}

- (id) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"clientId"] && [dictionary objectForKey:@"clientId"] != [NSNull null]) {
            self.clientId = [dictionary objectForKey:@"clientId"];
        }
        if ([dictionary objectForKey:@"eventId"] && [dictionary objectForKey:@"eventId"] != [NSNull null]) {
            self.eventId = [dictionary objectForKey:@"eventId"];
        }
        if ([dictionary objectForKey:@"properties"] && [dictionary objectForKey:@"properties"] != [NSNull null]) {
            self.properties = [NSDictionary dictionaryWithDictionary:[dictionary objectForKey:@"properties"]];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
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
        if ([aDecoder containsValueForKey:@"clientId"]) {
            self.clientId = [aDecoder decodeObjectForKey:@"clientId"];
        }
        if ([aDecoder containsValueForKey:@"eventId"]) {
            self.eventId = [aDecoder decodeObjectForKey:@"eventId"];
        }
        if ([aDecoder containsValueForKey:@"properties"]) {
            self.properties = [aDecoder decodeObjectForKey:@"properties"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:clientId forKey:@"clientId"];
    [aCoder encodeObject:eventId forKey:@"eventId"];
    [aCoder encodeObject:properties forKey:@"properties"];
    [aCoder encodeObject:created forKey:@"created"];
}

@end
