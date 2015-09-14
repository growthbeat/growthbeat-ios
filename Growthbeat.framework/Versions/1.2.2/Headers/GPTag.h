//
//  GPTag.h
//  GrowthPush
//
//  Created by uchidas on 2015/06/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GPTag : GBDomain<NSCoding> {

    NSInteger tagId;
    long long clientId;
    NSString *value;

}

@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, assign) long long clientId;
@property (nonatomic, strong) NSString *value;

+ (GPTag *)createWithGrowthbeatClient:(NSString *)clientId credentialId:(NSString *)credentialId name:(NSString *)name value:(NSString *)value;
+ (void)save:(GPTag *)tag name:(NSString *)name;
+ (GPTag *)load:(NSString *)name;

@end
