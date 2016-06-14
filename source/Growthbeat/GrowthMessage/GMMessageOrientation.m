//
//  GMMessageOrientation.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/14.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GMMessageOrientation.h"

NSString *NSStringFromGMMessageOrientation(GMMessageOrientation messageOrientation) {
    
    switch (messageOrientation) {
        case GMMessageOrientationUnknown:
            return nil;
        case GMMessageOrientationVertical:
            return @"vertical";
        case GMMessageOrientationHorizontal:
            return @"horizontal";
    }
    
}

GMMessageOrientation GMMessageOrientationFromNSString(NSString *messageOrientationString) {
    if ([messageOrientationString isEqualToString:@"vertical"]) {
        return GMMessageOrientationVertical;
    }
    if ([messageOrientationString isEqualToString:@"horizontal"]) {
        return GMMessageOrientationHorizontal;
    }
    return GMMessageOrientationUnknown;
}