//
//  FingerprintUtil.h
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2015/09/07.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

@interface NSURL (dictionaryFromQueryString)
-(NSDictionary *) dictionaryFromQueryString;
@end

@implementation NSURL (dictionaryFromQueryString)
-(NSDictionary *) dictionaryFromQueryString{
    
    NSString *query = [self query];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSRange range = [pair rangeOfString:@"="];
        NSString *key = range.length ? [pair substringToIndex:range.location] : pair;
        NSString *val = range.length ? [pair substringFromIndex:range.location+1] : @"";
        key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        val = [val stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        val = [val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}
@end

@interface Fingerprint : NSObject <UIWebViewDelegate>
- (void) getFingerPrint:(UIWindow *)window fingerprintUrl:(NSString*)fingerprintUrl argBlock:(void(^)(NSString *fingerprintParameters))argBlock;
@end
