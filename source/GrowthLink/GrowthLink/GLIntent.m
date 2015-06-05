//
//  GLIntent.m
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLIntent.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GrowthLink.h"

@implementation GLIntent

@synthesize link;
@synthesize pattern;
@synthesize intent;

+ (instancetype) createWithClientId:(NSString *)clientId token:(NSString *)token install:(NSInteger)install {
    
    NSString *path = @"/1/intent";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (token) {
        [body setObject:token forKey:@"token"];
    }
    if (install) {
        [body setObject:[NSString stringWithFormat:@"%ld", (long)install] forKey:@"install"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthLink sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthLink sharedInstance] logger] error:@"Failed to get synchronize. %@", httpResponse.error ? httpResponse.error : [httpResponse.body objectForKey:@"message"]];
        return nil;
    }
    
    return [self domainWithDictionary:httpResponse.body];
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"link"] && [dictionary objectForKey:@"link"] != [NSNull null]) {
            self.link = [dictionary objectForKey:@"link"];
        }
        if ([dictionary objectForKey:@"pattern"] && [dictionary objectForKey:@"pattern"] != [NSNull null]) {
            self.pattern = [dictionary objectForKey:@"pattern"];
        }
        if ([dictionary objectForKey:@"intent"] && [dictionary objectForKey:@"intent"] != [NSNull null]) {
            self.intent = [GBIntent domainWithDictionary:[dictionary objectForKey:@"intent"]];
        }
    }
    return self;
    
}

@end
