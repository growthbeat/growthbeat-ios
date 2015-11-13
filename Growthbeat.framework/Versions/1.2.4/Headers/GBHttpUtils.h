//
//  GBHttpUtils.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMultipartBoundary (@ "----------V2ymHFg03ehbqgZCaKO6jy")

@interface GBHttpUtils : NSObject

+ (NSString *)queryStringWithDictionary:(NSDictionary *)params;
+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString;
+ (NSData *)formUrlencodedBodyWithDictionary:(NSDictionary *)params;
+ (NSData *)jsonBodyWithDictionary:(NSDictionary *)params;
+ (NSData *)multipartBodyWithDictionary:(NSDictionary *)params;

@end
