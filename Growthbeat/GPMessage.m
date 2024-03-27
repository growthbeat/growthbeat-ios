//
//  GPMessage.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPMessage.h>
#import <Growthbeat/GrowthPush.h>
#import <Growthbeat/GBHttpClient.h>
#import <Growthbeat/GPPlainMessage.h>
#import <Growthbeat/GPCardMessage.h>
#import <Growthbeat/GPSwipeMessage.h>
#import <Growthbeat/GPNoContentMessage.h>

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
    if (applicationId) {
        [body setObject:applicationId forKey:@"applicationId"];
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
        [[[GrowthPush sharedInstance] logger] error:@"Failed to get message. %@", httpResponse.error ? httpResponse.error : [GBHttpResponse convertErrorMessage:httpResponse.body]];
        return nil;
    }
    
    return [GPMessage domainWithDictionary:httpResponse.body];


}


+ (instancetype) domainWithDictionary:(NSDictionary *)dictionary {
    
    GPMessage *message = [[self alloc] initWithDictionary:dictionary];
    if(!message)
        return [GPNoContentMessage domainWithDictionary:dictionary];
    
    switch (message.type) {
        case GPMessageTypePlain:
            if ([message isKindOfClass:[GPPlainMessage class]]) {
                return message;
            } else {
                return [GPPlainMessage domainWithDictionary:dictionary];
            }
        case GPMessageTypeCard:
            if ([message isKindOfClass:[GPCardMessage class]]) {
                return message;
            } else {
                return [GPCardMessage domainWithDictionary:dictionary];
            }
        case GPMessageTypeSwipe:
            if ([message isKindOfClass:[GPSwipeMessage class]]) {
                return message;
            } else {
                return [GPSwipeMessage domainWithDictionary:dictionary];
            }
        default:
            return nil;
    }
    
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        
        if (![dictionary objectForKey:@"type"])
            return nil;
        
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != [NSNull null]) {
            self.id = [dictionary objectForKey:@"id"];
        }
        if ([dictionary objectForKey:@"type"] && [dictionary objectForKey:@"type"] != [NSNull null]) {
            self.type = GPMessageTypeFromNSString([dictionary objectForKey:@"type"]);
        }
        if ([dictionary objectForKey:@"background"] && [dictionary objectForKey:@"background"] != [NSNull null]) {
            self.background = [GPBackground domainWithDictionary:[dictionary objectForKey:@"background"]];
        }
        if ([dictionary objectForKey:@"created"] && [dictionary objectForKey:@"created"] != [NSNull null]) {
            self.created = [GBDateUtils dateWithString:[dictionary objectForKey:@"created"] format:@"yyyy-MM-dd HH:mm:ss"];
        }
        if ([dictionary objectForKey:@"task"] && [dictionary objectForKey:@"task"] != [NSNull null]) {
            self.task = [GPTask domainWithDictionary:[dictionary objectForKey:@"task"]];
        }
        if ([dictionary objectForKey:@"buttons"] && [dictionary objectForKey:@"buttons"] != [NSNull null]) {
            NSMutableArray *buttonArray = [NSMutableArray array];
            NSArray *array  = (NSArray*)[dictionary objectForKey:@"buttons"];
            for (NSDictionary *dictionary in array) {
                [buttonArray addObject:[GPButton domainWithDictionary:dictionary]];
            }
            self.buttons = buttonArray;
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
