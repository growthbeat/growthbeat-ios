//
//  GPClient.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GPClientV4.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthPush.h"

static NSString *const kGPPreferenceClientV4Key = @"growthpush-client-v4";

@implementation GPClientV4

@synthesize id;
@synthesize applicationId;
@synthesize token;
@synthesize os;
@synthesize environment;
@synthesize created;

+ (GPClientV4 *) load {
    return [[[GrowthPush sharedInstance] preference] objectForKey:kGPPreferenceClientV4Key];
}

+ (void) save:(GPClientV4 *)newClient {
    [[[GrowthPush sharedInstance] preference] setObject:newClient forKey:kGPPreferenceClientV4Key];
}

+ (GPClientV4 *) createWithClientId:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId token:(NSString *)token environment:(GPEnvironment)environment {

    NSString *path = @"/4/clients";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if (token) {
        [body setObject:token forKey:@"token"];
    }
    if (NSStringFromGPOS(GPOSIos)) {
        [body setObject:NSStringFromGPOS(GPOSIos) forKey:@"os"];
    }
    if (NSStringFromGPEnvironment(environment)) {
        [body setObject:NSStringFromGPEnvironment(environment) forKey:@"environment"];
    }

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to create client. %@", httpResponse.error];
        return nil;
    }

    return [GPClientV4 domainWithDictionary:httpResponse.body];

}

+ (GPClientV4 *) updateWithClientId:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId token:(NSString *)token environment:(GPEnvironment)environment {

    NSString *path = [NSString stringWithFormat:@"/4/clients/%@", clientId];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if(applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
    }
    if (token) {
        [body setObject:token forKey:@"token"];
    }
    if (NSStringFromGPEnvironment(environment)) {
        [body setObject:NSStringFromGPEnvironment(environment) forKey:@"environment"];
    }

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPut path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to update client. %@", httpResponse.error];
        return nil;
    }

    return [GPClientV4 domainWithDictionary:httpResponse.body];

}

- (id) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"applicationId"] && [dictionary objectForKey:@"applicationId"] != [NSNull null]) {
            self.applicationId = [dictionary objectForKey:@"applicationId"];
        }
        if ([dictionary objectForKey:@"token"] && [dictionary objectForKey:@"token"] != [NSNull null]) {
            self.token = [dictionary objectForKey:@"token"];
        }
        if ([dictionary objectForKey:@"os"] && [dictionary objectForKey:@"os"] != [NSNull null]) {
            self.os = GPOSFromNSString([dictionary objectForKey:@"os"]);
        }
        if ([dictionary objectForKey:@"environment"] && [dictionary objectForKey:@"environment"] != [NSNull null]) {
            self.environment = GPEnvironmentFromNSString([dictionary objectForKey:@"environment"]);
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            // TODO fix time difference
            self.created = [GBDateUtils dateWithString:[dictionary objectForKey:@"created"] format:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
    return self;

}

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"id"]) {
            self.id = [aDecoder decodeObjectForKey:@"id"];
        }
        if ([aDecoder containsValueForKey:@"applicationId"]) {
            self.applicationId = [aDecoder decodeObjectForKey:@"applicationId"];
        }
        if ([aDecoder containsValueForKey:@"token"]) {
            self.token = [aDecoder decodeObjectForKey:@"token"];
        }
        if ([aDecoder containsValueForKey:@"os"]) {
            self.os = GPOSFromNSString([aDecoder decodeObjectForKey:@"os"]);
        }
        if ([aDecoder containsValueForKey:@"environment"]) {
            self.environment = GPEnvironmentFromNSString([aDecoder decodeObjectForKey:@"environment"]);
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
    }
    return self;

}


- (void) encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:applicationId forKey:@"applicationId"];
    [aCoder encodeObject:token forKey:@"token"];
    [aCoder encodeObject:NSStringFromGPOS(os) forKey:@"os"];
    [aCoder encodeObject:NSStringFromGPEnvironment(environment) forKey:@"environment"];
    [aCoder encodeObject:created forKey:@"created"];

}


@end
