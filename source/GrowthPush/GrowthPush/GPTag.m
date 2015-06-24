//
//  GPTag.m
//  GrowthPush
//
//  Created by uchidas on 2015/06/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GPTag.h"
#import "GrowthPush.h"
#import "GBHttpClient.h"

@implementation GPTag

@synthesize tagId;
@synthesize clientId;
@synthesize value;

static NSString *const kGPPreferenceTagKey = @"tags";
static NSMutableDictionary *tags;

+ (NSMutableDictionary *)tags {
    
    if (!self.tags) {
        tags = [[[GrowthPush sharedInstance] preference] objectForKey:kGPPreferenceTagKey];
        if (!tags)
            tags = [NSMutableDictionary dictionary];
    }
    
    return tags;

}

+ (GPTag *) createWithGrowthbeatClient:(NSString *)clientId credentialId:(NSString *)credentialId name:(NSString *)name value:(NSString *)value {
    
    NSString *path = @"/3/tags";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if (name) {
        [body setObject:name forKey:@"name"];
    }
    if (value) {
        [body setObject:value forKey:@"value"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to create tag. %@", httpResponse.error];
        return nil;
    }
    
    return [GPTag domainWithDictionary:httpResponse.body];
    
}

+ (void) save:(GPTag *)tag name:(NSString *)name {
    if (tag && name) {
        [tags setObject:tag forKey:name];
        [[[GrowthPush sharedInstance] preference] setObject:tags forKey:kGPPreferenceTagKey];
    }
}

+ (GPTag *) load:(NSString *)name {
    
    if (name)
        return nil;
    
    return [tags objectForKey:name];
    
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"tagId"] && [dictionary objectForKey:@"tagId"] != [NSNull null]) {
            self.tagId = [[dictionary objectForKey:@"tagId"] integerValue];
        }
        if ([dictionary objectForKey:@"clientId"] && [dictionary objectForKey:@"clientId"] != [NSNull null]) {
            self.clientId = [[dictionary objectForKey:@"clientId"] longLongValue];
        }
        if ([dictionary objectForKey:@"value"] && [dictionary objectForKey:@"value"] != [NSNull null]) {
            self.value = [dictionary objectForKey:@"value"];
        }
    }
    
    return self;
    
}

# pragma mark --
# pragma mark NSCoding

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"tagId"]) {
            self.tagId = [aDecoder decodeIntegerForKey:@"tagId"];
        }
        if ([aDecoder containsValueForKey:@"clientId"]) {
            self.clientId = [[aDecoder decodeObjectForKey:@"clientId"] longLongValue];
        }
        if ([aDecoder containsValueForKey:@"value"]) {
            self.value = [aDecoder decodeObjectForKey:@"value"];
        }
    }
    
    return self;
    
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInteger:tagId forKey:@"tagId"];
    [aCoder encodeObject:@(clientId) forKey:@"clientId"];
    [aCoder encodeObject:value forKey:@"value"];
    
}


@end