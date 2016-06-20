//
//  GPMessage.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessage.h"
#import "GrowthPush.h"
#import "GBHttpClient.h"

@implementation GPMessage

@synthesize id;
@synthesize type;
@synthesize background;
@synthesize created;
@synthesize task;
@synthesize buttons;

+ (GPMessage *)receive:(NSString *)taskId applicationId:(NSString *)applicationId clientId:(NSString *)clientId credentialId:(NSString *)credentialId {
    NSString *path = @"/4/receive";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (taskId) {
        [body setObject:taskId forKey:@"taskId"];
    }
    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodGet path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to get message. %@", httpResponse.error];
        return nil;
    }
    
    if (!httpResponse.body) {
        [[[GrowthPush sharedInstance] logger] info:@"No message is received."];
        return nil;
    }
    
    [[[GrowthPush sharedInstance] logger] info:@"A message is received."];
    
    return [GPMessage domainWithDictionary:httpResponse.body];


}

+ (GPTag *)receiveCount:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId taskId:(NSString *)taskId messageId:(NSString *)messageId {
    
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
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodGet path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to get message. %@", httpResponse.error];
        return nil;
    }
    
    if (!httpResponse.body) {
        [[[GrowthPush sharedInstance] logger] info:@"No message is received."];
        return nil;
    }
    
    [[[GrowthPush sharedInstance] logger] info:@"A message is received."];
    
    return [GPTag domainWithDictionary:httpResponse.body];
    
}


#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"id"]) {
            self.id = [aDecoder decodeObjectForKey:@"id"];
        }
        if ([aDecoder containsValueForKey:@"type"]) {
            self.type = [aDecoder decodeIntegerForKey:@"type"];
        }
        if ([aDecoder containsValueForKey:@"background"]) {
            self.background = [aDecoder decodeObjectForKey:@"background"];
        }
        if ([aDecoder containsValueForKey:@"created"]) {
            self.created = [aDecoder decodeObjectForKey:@"created"];
        }
        if ([aDecoder containsValueForKey:@"task"]) {
            self.task = [aDecoder decodeObjectForKey:@"task"];
        }
        if ([aDecoder containsValueForKey:@"buttons"]) {
            self.buttons = [aDecoder decodeObjectForKey:@"buttons"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeInteger:type forKey:@"type"];
    [aCoder encodeObject:background forKey:@"background"];
    [aCoder encodeObject:created forKey:@"created"];
    [aCoder encodeObject:task forKey:@"task"];
    [aCoder encodeObject:buttons forKey:@"buttons"];
}

@end
