//
//  GPMessageOutside.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/16.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessageOutsideClose.h"

NSString *NSStringFromGPMessageOutsideClose(GPMessageOutsideClose messageOutsideClose) {
    
    switch (messageOutsideClose) {
        case GPMessageOutsideCloseTrue:
            return @"true";
        case GPMessageOutsideCloseFalse:
            return @"false";
    }
    
}

GPMessageOutsideClose GPMessageOutsideCloseFromNSString(NSString *messageOutsideCloseString){
    if ([messageOutsideCloseString isEqualToString:@"true"]) {
        return GPMessageOutsideCloseTrue;
    }
    if ([messageOutsideCloseString isEqualToString:@"false"]) {
        return GPMessageOutsideCloseFalse;
    }
    return GPMessageOutsideCloseFalse;
}

