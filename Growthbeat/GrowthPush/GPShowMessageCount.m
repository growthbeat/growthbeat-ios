//
//  GPShowMessageCount.m
//  Growthbeat
//
//  Created by 尾川 茂 on 2017/03/10.
//  Copyright © 2017年 SIROK, Inc. All rights reserved.
//

#import "GPShowMessageCount.h"
#import "GrowthPush.h"
#import "GBHttpClient.h"

@implementation GPShowMessageCount

@synthesize clientId;
@synthesize messageId;
@synthesize taskId;
@synthesize count;

+ (GPShowMessageCount *)receiveCount:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId taskId:(NSString *)taskId messageId:(NSString *)messageId {
    
    NSString *path = @"/4/receive/count";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if(clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if(applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
    }
    if(credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if(taskId) {
        [body setObject:taskId forKey:@"taskId"];
    }
    if(messageId) {
        [body setObject:messageId forKey:@"messageId"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to count up show message. %@", httpResponse.error];
        return nil;
    }
    
    return [GPShowMessageCount domainWithDictionary:httpResponse.body];
    
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        
        if (![dictionary objectForKey:@"type"])
            return nil;
        
        if ([dictionary objectForKey:@"clientId"] && [dictionary objectForKey:@"clientId"] != [NSNull null]) {
            self.clientId = [dictionary objectForKey:@"clientId"];
        }
        if ([dictionary objectForKey:@"messageId"] && [dictionary objectForKey:@"messageId"] != [NSNull null]) {
            self.messageId = [dictionary objectForKey:@"messageId"];
        }
        if ([dictionary objectForKey:@"taskId"] && [dictionary objectForKey:@"taskId"] != [NSNull null]) {
            self.taskId = [dictionary objectForKey:@"tagId"];
        }
        if ([dictionary objectForKey:@"count"] && [dictionary objectForKey:@"count"] != [NSNull null]) {
            self.count = [[dictionary objectForKey:@"clientId"] integerValue];
        }
    }
    return self;
    
}



#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"clientId"]) {
            self.clientId = [aDecoder decodeObjectForKey:@"clientId"];
        }
        if ([aDecoder containsValueForKey:@"messageId"]) {
            self.messageId = [aDecoder decodeObjectForKey:@"messageId"];
        }
        if ([aDecoder containsValueForKey:@"taskId"]) {
            self.taskId = [aDecoder decodeObjectForKey:@"taskId"];
        }
        if ([aDecoder containsValueForKey:@"count"]) {
            self.count = [aDecoder decodeIntegerForKey:@"count"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:clientId forKey:@"clientId"];
    [aCoder encodeObject:messageId forKey:@"messageId"];
    [aCoder encodeObject:taskId forKey:@"taskId"];
    [aCoder encodeInteger:count forKey:@"count"];
}


@end
