//
//  GLSynchronization.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLSynchronization.h"
#import <Growthbeat/GBUtils.h>
#import <Growthbeat/GBHttpClient.h>
#import "GrowthLink.h"

@implementation GLSynchronization

@synthesize scheme;
@synthesize browser;
@synthesize clickId;

static NSString *const kGLPreferenceSynchronizationKey = @"synchronization";

+ (instancetype) synchronizeWithApplicationId:(NSString *)applicationId version:(NSString *)version credentialId:(NSString *)credentialId fingerprintParameters:(NSString *)fingerprintParameters {

    NSString *path = @"/1/synchronize";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
    }
    [body setObject:@"ios" forKey:@"os"];
    if (version) {
        [body setObject:version forKey:@"version"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if (fingerprintParameters) {
        [body setObject:fingerprintParameters forKey:@"fingerprint_parameters"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthLink sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthLink sharedInstance] logger] error:@"Failed to get synchronization. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }
    
    return [self domainWithDictionary:httpResponse.body];
}

+ (void) save:(GLSynchronization *)synchronization {
    [[[GrowthLink sharedInstance] preference] setObject:synchronization forKey:kGLPreferenceSynchronizationKey];
}

+ (GLSynchronization *) load {
    return [[[GrowthLink sharedInstance] preference] objectForKey:kGLPreferenceSynchronizationKey];
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"scheme"] && [dictionary objectForKey:@"scheme"] != [NSNull null]) {
            self.scheme = [dictionary objectForKey:@"scheme"];
        }
        if ([dictionary objectForKey:@"browser"] && [dictionary objectForKey:@"browser"] != [NSNull null]) {
            self.browser = [[dictionary objectForKey:@"browser"] boolValue];
        }
        if ([dictionary objectForKey:@"clickId"] && [dictionary objectForKey:@"clickId"] != [NSNull null]) {
            self.clickId = [dictionary objectForKey:@"clickId"];
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"scheme"]) {
            self.scheme = [aDecoder decodeObjectForKey:@"scheme"];
        }
        if ([aDecoder containsValueForKey:@"browser"]) {
            self.browser = [aDecoder decodeBoolForKey:@"browser"];
        }
        if ([aDecoder containsValueForKey:@"clickId"]) {
            self.clickId = [aDecoder decodeObjectForKey:@"clickId"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:scheme forKey:@"scheme"];
    [aCoder encodeBool:browser forKey:@"browser"];
    [aCoder encodeObject:clickId forKey:@"clickId"];
}

@end
