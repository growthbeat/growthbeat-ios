//
//  GPTask.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPTask.h"
#import "GrowthPush.h"
#import "GBHttpClient.h"

@implementation GPTask

@synthesize id;
@synthesize applicationId;
@synthesize goalId;
@synthesize segmentId;
@synthesize orientation;
@synthesize begin;
@synthesize end;
@synthesize capacity;
@synthesize created;

+ (NSArray *) getTasks:(NSString *)applicationId credentialId:(NSString *)credentialId goalId:(NSInteger)goalId {
    NSString *path = @"/4/tasks";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if (goalId) {
        [body setObject:[NSNumber numberWithInteger:goalId] forKey:@"goalId"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodGet path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to get tasks. %@", httpResponse.error];
        return nil;
    }
    if (!httpResponse.body) {
        [[[GrowthPush sharedInstance] logger] info:@"No task is received."];
        return nil;
    }
    
    [[[GrowthPush sharedInstance] logger] info:@"Task are received."];

    return [GPTask domainArrayFromArray:httpResponse.body];
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"applicationId"] && [dictionary objectForKey:@"applicationId"] != [NSNull null]) {
            self.applicationId = [dictionary objectForKey:@"applicationId"];
        }
        if ([dictionary objectForKey:@"goalId"] && [dictionary objectForKey:@"goalId"] != [NSNull null]) {
            self.goalId = [[dictionary objectForKey:@"goalId"] integerValue];
        }
        if ([dictionary objectForKey:@"segmentId"] && [dictionary objectForKey:@"segmentId"] != [NSNull null]) {
            self.segmentId = [[dictionary objectForKey:@"segmentId"] integerValue];
        }
        if ([dictionary objectForKey:@"orientation"] && [dictionary objectForKey:@"orientation"] != [NSNull null]) {
            self.orientation = GMMessageOrientationFromNSString([dictionary objectForKey:@"orientation"]);
        }
        if ([dictionary objectForKey:@"begin"] && [dictionary objectForKey:@"begin"] != [NSNull null]) {
            self.begin = [GBDateUtils dateWithString:[dictionary objectForKey:@"begin"] format:@"yyyy-MM-dd HH:mm:ss"];
        }
        if ([dictionary objectForKey:@"end"] && [dictionary objectForKey:@"end"] != [NSNull null]) {
            self.end = [GBDateUtils dateWithString:[dictionary objectForKey:@"end"] format:@"yyyy-MM-dd HH:mm:ss"];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithString:[dictionary objectForKey:@"created"] format:@"yyyy-MM-dd HH:mm:ss"];
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
        if ([aDecoder containsValueForKey:@"applicationId"]) {
            self.applicationId = [aDecoder decodeObjectForKey:@"applicationId"];
        }
        if ([aDecoder containsValueForKey:@"goalId"]) {
            self.goalId = [aDecoder decodeIntegerForKey:@"goalId"];
        }
        if ([aDecoder containsValueForKey:@"segmentId"]) {
            self.segmentId = [aDecoder decodeIntegerForKey:@"segmentId"];
        }
        if ([aDecoder containsValueForKey:@"orientation"]) {
            self.orientation = [aDecoder decodeIntegerForKey:@"orientation"];
        }
        if ([aDecoder containsValueForKey:@"begin"]) {
            self.begin = [aDecoder decodeObjectForKey:@"begin"];
        }
        if ([aDecoder containsValueForKey:@"end"]) {
            self.end = [aDecoder decodeObjectForKey:@"end"];
        }
        if ([aDecoder containsValueForKey:@"capacity"]) {
            self.capacity = [aDecoder decodeIntegerForKey:@"capacity"];
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
    [aCoder encodeInteger:goalId forKey:@"goalId"];
    [aCoder encodeInteger:segmentId forKey:@"segmentId"];
    [aCoder encodeInteger:orientation forKey:@"orientation"];
    [aCoder encodeObject:begin forKey:@"begin"];
    [aCoder encodeObject:end forKey:@"end"];
    [aCoder encodeInteger:capacity forKey:@"capacity"];
    [aCoder encodeObject:created forKey:@"created"];
}

@end
