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

static NSString *const kGPPreferenceTagKeyFormat = @"tags:%@";

+ (GPTag *)createWithGrowthbeatClient:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId type:(GPTagType)tagType name:(NSString *)name value:(NSString *)value {

    NSString *path = @"/4/tags";
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
    if (NSStringFromGPTagType(tagType) ) {
        [body setObject:NSStringFromGPTagType(tagType) forKey:@"type"];
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
        [[[GrowthPush sharedInstance] preference] setObject:tag forKey:[NSString stringWithFormat:kGPPreferenceTagKeyFormat, name]];
    }
}

+ (GPTag *) load:(NSString *)name {

    if (!name) {
        return nil;
    }

    return [[[GrowthPush sharedInstance] preference] objectForKey:[NSString stringWithFormat:kGPPreferenceTagKeyFormat, name]];

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
