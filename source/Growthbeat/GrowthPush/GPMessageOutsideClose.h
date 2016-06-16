//
//  GPMessageOutside.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/16.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GPMessageOutsideClose) {
    GPMessageOutsideCloseFalse = 0,
    GPMessageOutsideCloseTrue
};

NSString *NSStringFromGPMessageOutsideClose(GPMessageOutsideClose messageOutsideClose);
GPMessageOutsideClose GPMessageOutsideCloseFromNSString(NSString *messageOutsideCloseString);
