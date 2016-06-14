//
//  GMMessageOrientation.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/14.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMMessageOrientation) {
    GMMessageOrientationUnknown = 0,
    GMMessageOrientationVertical,
    GMMessageOrientationHorizontal
};

NSString *NSStringFromGMMessageOrientation(GMMessageOrientation messageOrientation);
GMMessageOrientation GMMessageOrientationFromNSString(NSString *messageOrientationString);
