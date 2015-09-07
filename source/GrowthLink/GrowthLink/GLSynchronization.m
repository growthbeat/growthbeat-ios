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

@synthesize cookieTracking;
@synthesize deviceFingerprint;
@synthesize clickId;

static NSString *const kGLPreferenceSynchronizationKey = @"synchronization";

+ (instancetype) synchronizeWithApplicationId:(NSString *)applicationId version:(NSString *)version fingerprintParameters:(NSString *)fingerprintParameters credentialId:(NSString *)credentialId {

    NSString *path = @"/2/synchronize";
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
        [body setObject:fingerprintParameters forKey:@"fingerprintParameters" ];
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
        if ([dictionary objectForKey:@"cookieTracking"] && [dictionary objectForKey:@"cookieTracking"] != [NSNull null]) {
            self.cookieTracking = [[dictionary objectForKey:@"cookieTracking"] boolValue];
        }
        if ([dictionary objectForKey:@"deviceFingerprint"] && [dictionary objectForKey:@"deviceFingerprint"] != [NSNull null]) {
            self.deviceFingerprint = [[dictionary objectForKey:@"deviceFingerprint"] boolValue];
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
        if ([aDecoder containsValueForKey:@"cookieTracking"]) {
            self.cookieTracking = [aDecoder decodeBoolForKey:@"cookieTracking"];
        }
        if ([aDecoder containsValueForKey:@"deviceFingerprint"]) {
            self.deviceFingerprint = [aDecoder decodeBoolForKey:@"deviceFingerprint"];
        }
        if ([aDecoder containsValueForKey:@"clickId"]) {
            self.clickId = [aDecoder decodeObjectForKey:@"clickId"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:cookieTracking forKey:@"cookieTracking"];
    [aCoder encodeBool:deviceFingerprint forKey:@"deviceFingerprint"];
    [aCoder encodeObject:clickId forKey:@"clickId"];
}

@end
