//
//  GBViewUtils.m
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/09/10.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBViewUtils.h>

@implementation GBViewUtils

+ (UIWindow *) getWindow {

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }

    return window;

}

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a {
    NSScanner *colorScanner = [NSScanner scannerWithString:hex];
    unsigned int color;
    [colorScanner scanHexInt:&color];
    CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
    CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
    CGFloat b =  (color & 0x0000FF) /255.0f;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (NSString *)addDensityByPictureUrl:(NSString *)originalUrl {
    int scale = (int)floor([[UIScreen mainScreen] scale]);
    if (scale == 1)
        return originalUrl;
    
    NSMutableArray *filenameArray = [[originalUrl componentsSeparatedByString:@"/"] mutableCopy];
    NSString *filename = [filenameArray objectAtIndex:filenameArray.count - 1];
    NSArray *extensionArray = [filename componentsSeparatedByString:@"."];
    NSString *resultFileName = [NSString stringWithFormat:@"%@@%dx.%@",[extensionArray objectAtIndex:0], (int)floor([[UIScreen mainScreen] scale]), [extensionArray objectAtIndex:1] ];
    [filenameArray removeLastObject];
    NSString *pathString = [filenameArray componentsJoinedByString:@"/"];
    NSString *resultString = [NSString stringWithFormat:@"%@/%@",pathString,resultFileName];
    
    return resultString;
}

@end
