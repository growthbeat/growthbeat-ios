//
//  GBDeviceUtils.m
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2013/07/14.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GBDeviceUtils.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <mach/mach.h>
#import <netinet/in.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation GBDeviceUtils

+ (NSString *) model {

    return [[UIDevice currentDevice] model];

}

+ (NSString *) os {

    NSString *version = [[UIDevice currentDevice] systemVersion];

    if (!version || [version length] == 0) {
        return nil;
    }

    return [NSString stringWithFormat:@"iOS %@", version];

}

+ (NSString *) language {

    NSArray *languages = [NSLocale preferredLanguages];

    if (!languages || [languages count] == 0) {
        return nil;
    }

    return [languages objectAtIndex:0];

}

+ (NSString *) timeZone {
    return [[NSTimeZone systemTimeZone] name];
}

+ (NSInteger) timeZoneOffset {
    return [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
}

+ (NSString *) locale {
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

+ (NSString *) country {
    NSLocale *locale = [NSLocale currentLocale];

    return [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
}

+ (NSString *) version {

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

}

+ (NSString *) build {

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

}

+ (BOOL) connectedToWiFi {

    struct sockaddr_in address;

    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;


    SCNetworkReachabilityRef networkReachablitiyRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);
    if (!networkReachablitiyRef) {
        return NO;
    }


    BOOL returnVal = YES;
    SCNetworkReachabilityFlags networkReachablitiyFlags = 0;

    if (!SCNetworkReachabilityGetFlags(networkReachablitiyRef, &networkReachablitiyFlags)) {
        returnVal = NO;
    }
    if (!(networkReachablitiyFlags & kSCNetworkReachabilityFlagsReachable)) {
        returnVal = NO;
    }
    if ((networkReachablitiyFlags & kSCNetworkReachabilityFlagsIsWWAN)) {
        returnVal = NO;
    }

    CFRelease(networkReachablitiyRef);
    return returnVal;

}

+ (float) getCurrentDeviceVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (unsigned int) getAvailableMemory {

    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }

    natural_t mem_free = vm_stat.free_count * (unsigned int)pagesize;

    return (unsigned int)mem_free;
}

+ (uint64_t) getCPUUsage {

    struct task_thread_times_info thread_info;
    mach_msg_type_number_t t_info_count = TASK_THREAD_TIMES_INFO_COUNT;
    kern_return_t status;

    status = task_info(current_task(), TASK_THREAD_TIMES_INFO,
            (task_info_t)&thread_info, &t_info_count);

    if (status != KERN_SUCCESS) {
        return 0;
    }

    return ((thread_info.user_time.seconds * 1000) + (thread_info.user_time.microseconds / 1000));

}

+ (NSString *) getPlatformString {

    NSString *device = [[UIDevice currentDevice] model];

    if ([device isEqualToString:@"iPhone Simulator"]) {
        return device;
    }

    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);

    return platform;

}


+ (NSString *) getAdvertisingId {
    NSString *uid = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        BOOL enabled = [GBDeviceUtils getTrackingEnabled];
        if (enabled) {
            SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
            NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
            uid = [uuid UUIDString];
        }
    }
    return uid;
}

+ (BOOL) getTrackingEnabled {
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
        BOOL enabled = ((BOOL (*)(id, SEL))[sharedManager methodForSelector:advertisingEnabledSelector])(sharedManager, advertisingEnabledSelector);
        return enabled;
    }
    return YES;
}

@end
