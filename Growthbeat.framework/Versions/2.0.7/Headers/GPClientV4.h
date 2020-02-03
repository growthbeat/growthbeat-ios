//
//  GPClient.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GPOS.h"
#import "GPEnvironment.h"

@interface GPClientV4 : GBDomain <NSCoding> {

    NSString *id;
    NSString *applicationId;
    NSString *token;
    GPOS os;
    GPEnvironment environment;
    NSDate *created;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) GPOS os;
@property (nonatomic, assign) GPEnvironment environment;
@property (nonatomic, strong) NSDate *created;

+ (GPClientV4 *) load;
+ (void) save:(GPClientV4 *)newClient;
+ (GPClientV4 *) attachClient:(NSString *)id applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId token:(NSString *)token environment:(GPEnvironment)environment;

@end
