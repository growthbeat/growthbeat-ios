//
//  GRRecorder.h
//  replay
//
//  Created by A13048 on 2014/01/23.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GRConfiguration.h"

@interface GRRecorder : NSObject {
    BOOL isRec;
    GRConfiguration *configuration;
    NSString *spot;
}

@property (nonatomic) BOOL isRec;
@property (nonatomic) GRConfiguration *configuration;
@property (nonatomic) NSString *spot;

- (void)startWithConfiguration:(GRConfiguration *)newConfiguration callback:(void(^) (NSData *, NSDate *))newCallback;
- (void)stop;
- (NSData *) GPUCompressImage:(UIImage*)image;

@end
