//
//  GBClient.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBClient.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthbeatCore.h"

static NSString *const kGBPreferenceClientKey = @"client";

@implementation GBClient

@synthesize id;
@synthesize created;
@synthesize application;

+ (GBClient *) createWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId {

    NSString *path = @"/1/clients";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthbeatCore sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthbeatCore sharedInstance] logger] error:@"Failed to create client. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }

    return [GBClient domainWithDictionary:httpResponse.body];

}

+ (GBClient *) findWithId:(NSString *)id credentialId:(NSString *)credentialId {
    
    NSString *path = [NSString stringWithFormat:@"/1/clients/%@" ,id];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    if (credentialId) {
        [query setObject:credentialId forKey:@"credentialId"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodGet path:path query:query body:nil];
    GBHttpResponse *httpResponse = [[[GrowthbeatCore sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthbeatCore sharedInstance] logger] error:@"Failed to find client. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }
    
    return [GBClient domainWithDictionary:httpResponse.body];
    
}

+ (void) save:(GBClient *)client {
    if (!client) {
        return;
    }
    [[[GrowthbeatCore sharedInstance] preference] setObject:client forKey:kGBPreferenceClientKey];
}

+ (GBClient *) load {
    return [[[GrowthbeatCore sharedInstance] preference] objectForKey:kGBPreferenceClientKey];
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
        }
        if ([dictionary objectForKey:@"application"] && [dictionary objectForKey:@"application"] != [NSNull null]) {
            self.application = [GBApplication domainWithDictionary:[dictionary objectForKey:@"application"]];
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
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"application"]) {
            self.application = [aDecoder decodeObjectForKey:@"application"];
        }
    }
    return self;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:application forKey:@"application"];

}

@end
