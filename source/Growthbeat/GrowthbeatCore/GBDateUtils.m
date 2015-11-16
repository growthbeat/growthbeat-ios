//
//  GBDateUtils.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBDateUtils.h"

@implementation GBDateUtils

+ (NSDate *) dateWithDateTimeString:(NSString *)dateTimeString {
    return [self dateWithString:dateTimeString format:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDate *) dateWithString:(NSString *)string format:(NSString *)format {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:format];

    return [dateFormatter dateFromString:string];

}

@end
