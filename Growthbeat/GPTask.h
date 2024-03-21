//
//  GPTask.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>
#import <Growthbeat/GPMessageOrientation.h>

@interface GPTask : GBDomain <NSCoding> {
    
    NSString *id;
    NSString *applicationId;
    NSInteger goalId;
    NSInteger segmentId;
    GPMessageOrientation orientation;
    NSDate *begin;
    NSDate *end;
    NSInteger capacity;
    NSDate *created;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, assign) NSInteger goalId;
@property (nonatomic, assign) NSInteger segmentId;
@property (nonatomic, assign) GPMessageOrientation orientation;
@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, assign) NSInteger capacity;
@property (nonatomic, strong) NSDate *created;

+ (NSArray *) getTasks:(NSString *)applicationId credentialId:(NSString *)credentialId goalId:(NSInteger)goalId;

@end
