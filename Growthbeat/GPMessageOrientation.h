//
//  GPMessageOrientation.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GPMessageOrientation) {
    GPMessageOrientationUnknown = 0,
    GPMessageOrientationVertical,
    GPMessageOrientationHorizontal
};

NSString *NSStringFromGMMessageOrientation(GPMessageOrientation messageOrientation);
GPMessageOrientation GMMessageOrientationFromNSString(NSString *messageOrientationString);
