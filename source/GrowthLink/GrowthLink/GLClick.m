//
//  GLClick.m
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/06/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLClick.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthLink.h"

@implementation GLClick

@synthesize id;
@synthesize pattern;
@synthesize clientId;
@synthesize open;
@synthesize install;
@synthesize created;
@synthesize accessed;

+ (instancetype) deeplinkWithClientId:(NSString *)clientId clickId:(NSString *)clickId install:(BOOL)install credentialId:(NSString *)credentialId {
    
    NSString *path = @"/1/deeplink";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (clickId) {
        [body setObject:clickId forKey:@"clickId"];
    }
    [body setObject:install?@"true":@"false" forKey:@"install"];
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthLink sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthLink sharedInstance] logger] error:@"Failed to get click. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }
    
    return [self domainWithDictionary:httpResponse.body];
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"pattern"] && [dictionary objectForKey:@"pattern"] != [NSNull null]) {
            self.pattern = [GLPattern domainWithDictionary:[dictionary objectForKey:@"pattern"]];
        }
        if ([dictionary objectForKey:@"clientId"] && [dictionary objectForKey:@"clientId"] != [NSNull null]) {
            self.clientId = [dictionary objectForKey:@"clientId"];
        }
        if ([dictionary objectForKey:@"open"] && [dictionary objectForKey:@"open"] != [NSNull null]) {
            self.open = [[dictionary objectForKey:@"open"] boolValue];
        }
        if ([dictionary objectForKey:@"install"] && [dictionary objectForKey:@"install"] != [NSNull null]) {
            self.install = [[dictionary objectForKey:@"install"] boolValue];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"created"]];
        }
        if ([dictionary objectForKey:@"accessed"] && [dictionary objectForKey:@"accessed"] != [NSNull null]) {
            self.accessed = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:@"accessed"]];
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
        if ([aDecoder containsValueForKey:@"pattern"]) {
            self.pattern = [aDecoder decodeObjectForKey:@"pattern"];
        }
        if ([aDecoder containsValueForKey:@"clientId"]) {
            self.clientId = [aDecoder decodeObjectForKey:@"clientId"];
        }
        if ([aDecoder containsValueForKey:@"open"]) {
            self.open = [aDecoder decodeBoolForKey:@"open"];
        }
        if ([aDecoder containsValueForKey:@"install"]) {
            self.install = [aDecoder decodeBoolForKey:@"install"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"accessed"]) {
            self.accessed = [aDecoder decodeObjectForKey:@"accessed"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:pattern forKey:@"pattern"];
    [aCoder encodeObject:clientId forKey:@"clientId"];
    [aCoder encodeBool:open forKey:@"open"];
    [aCoder encodeBool:install forKey:@"install"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:accessed forKey:@"accessed"];
}

@end
