//
//  GRRecordStatus.h
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GRRecordStatus) {
    GRRecordStatusUnknown = 0,
    GRRecordStatusNone,
    GRRecordStatusAdded,
    GRRecordStatusAlready,
};

NSString *NSStringFromGRRecordStatus(GRRecordStatus status);
GRRecordStatus GRRecordStatusFromNSString(NSString *statusString);