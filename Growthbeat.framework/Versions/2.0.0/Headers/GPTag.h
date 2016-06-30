//
//  GPTag.h
//  GrowthPush
//
//  Created by uchidas on 2015/06/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GPTagType.h"

@interface GPTag : GBDomain<NSCoding> {

    NSInteger tagId;
    NSString *clientId;
    NSString *value;

}

@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *value;

+ (GPTag *)createWithGrowthbeatClient:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId type:(GPTagType)tagType name:(NSString *)name value:(NSString *)value;
+ (void)save:(GPTag *)tag type:(GPTagType)tagType name:(NSString *)name;
+ (GPTag *)load:(GPTagType)tagType name:(NSString *)name;

@end
