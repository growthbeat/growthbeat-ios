//
//  GPMessageOrientation.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessageOrientation.h"

NSString *NSStringFromGMMessageOrientation(GPMessageOrientation messageOrientation) {
    
    switch (messageOrientation) {
        case GPMessageOrientationUnknown:
            return nil;
        case GPMessageOrientationVertical:
            return @"vertical";
        case GPMessageOrientationHorizontal:
            return @"horizontal";
    }
    
}

GPMessageOrientation GMMessageOrientationFromNSString(NSString *messageOrientationString){
    if ([messageOrientationString isEqualToString:@"vertical"]) {
        return GPMessageOrientationVertical;
    }
    if ([messageOrientationString isEqualToString:@"horizontal"]) {
        return GPMessageOrientationHorizontal;
    }
    return GPMessageOrientationUnknown;
}

