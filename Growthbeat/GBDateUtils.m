//
//  GBDateUtils.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBDateUtils.h"
#import <UIKit/UIKit.h>

@implementation GBDateUtils

+ (NSDate *) dateWithDateTimeString:(NSString *)dateTimeString {
    return [self dateWithString:dateTimeString format:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDate *) dateWithString:(NSString *)string format:(NSString *)format {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSString *gregorianCalendar = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        gregorianCalendar = NSCalendarIdentifierGregorian;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        gregorianCalendar = NSGregorianCalendar;
#pragma clang diagnostic pop
    }

    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:gregorianCalendar]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:format];

    return [dateFormatter dateFromString:string];

}

@end
