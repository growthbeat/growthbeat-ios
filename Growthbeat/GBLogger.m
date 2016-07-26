//
//  GBLogger.m
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GBLogger.h"

@implementation GBLogger

@synthesize tag;
@synthesize silent;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.silent = NO;
    }
    return self;
}

- (instancetype) initWithTag:(NSString *)initialTag {
    self = [self init];
    if (self) {
        self.tag = initialTag;
    }
    return self;
}

- (void) error:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"ERROR" format:format args:args];
}

- (void) warn:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"WARN" format:format args:args];
}

- (void) info:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"INFO" format:format args:args];
}

- (void) debug:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"DEBUG" format:format args:args];
}

- (void) logWithLevel:(NSString *)level format:(NSString *)format args:(va_list)args {

    if (silent) {
        return;
    }

    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"[%@:%@] %@", tag, level, message);

}

@end
