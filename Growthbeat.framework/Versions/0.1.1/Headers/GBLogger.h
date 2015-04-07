//
//  GBLogger.h
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBLogger : NSObject {

    NSString *tag;
    BOOL silent;

}

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, assign) BOOL silent;

- (instancetype)initWithTag:(NSString *)tag;

- (void)error:(NSString *)format, ...;
- (void)warn:(NSString *)format, ...;
- (void)info:(NSString *)format, ...;
- (void)debug:(NSString *)format, ...;

@end
