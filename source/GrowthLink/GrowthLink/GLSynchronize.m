//
//  GLSynchronize.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLSynchronize.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthLink.h"

@implementation GLSynchronize

@synthesize configuration;
@synthesize click;

static NSString *const kGLPreferenceSynchronizeKey = @"synchronize";

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
        [[[GrowthLink sharedInstance] logger] error:@"Failed to get synchronize. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }
    
    return [self domainWithDictionary:httpResponse.body];
}

+ (void) save:(GLSynchronize *)synchronize {
    [[[GrowthLink sharedInstance] preference] setObject:synchronize forKey:kGLPreferenceSynchronizeKey];
}

+ (GLSynchronize *) load {
    return [[[GrowthLink sharedInstance] preference] objectForKey:kGLPreferenceSynchronizeKey];
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"configuration"] && [dictionary objectForKey:@"configuration"] != [NSNull null]) {
            self.configuration = [dictionary objectForKey:@"configuration"];
        }
        if ([dictionary objectForKey:@"click"] && [dictionary objectForKey:@"click"] != [NSNull null]) {
            self.click = [dictionary objectForKey:@"click"];
        }
    }
    return self;
    
}

@end
