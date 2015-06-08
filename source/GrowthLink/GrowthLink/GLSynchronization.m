//
//  GLSynchronization.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLSynchronization.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthLink.h"

@implementation GLSynchronization

@synthesize browser;
@synthesize token;

static NSString *const kGLPreferenceSynchronizationKey = @"synchronization";

+ (instancetype) getWithApplicationId:(NSString *)applicationId os:(NSInteger)os version:(NSString *)version credentialId:(NSString *)credentialId {
    
    NSString *path = [NSString stringWithFormat:@"/1/synchronize/%@", applicationId];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    if (os) {
        [query setObject:[NSString stringWithFormat:@"%ld", (long)os] forKey:@"os"];
    }
    if (version) {
        [query setObject:version forKey:@"version"];
    }
    if (credentialId) {
        [query setObject:credentialId forKey:@"credentialId"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodGet path:path query:query];
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
        if ([dictionary objectForKey:@"browser"] && [dictionary objectForKey:@"browser"] != [NSNull null]) {
            self.browser = [[dictionary objectForKey:@"browser"] integerValue];
        }
        if ([dictionary objectForKey:@"token"] && [dictionary objectForKey:@"token"] != [NSNull null]) {
            self.token = [dictionary objectForKey:@"token"];
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"browser"]) {
            self.browser = [aDecoder decodeIntegerForKey:@"browser"];
        }
        if ([aDecoder containsValueForKey:@"token"]) {
            self.token = [aDecoder decodeObjectForKey:@"token"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:browser forKey:@"browser"];
    [aCoder encodeObject:token forKey:@"token"];
}

@end
