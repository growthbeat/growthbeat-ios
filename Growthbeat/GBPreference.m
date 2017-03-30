//
//  GBPreference.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/17.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GBPreference.h"
#import "Growthbeat.h"

@implementation GBPreference

@synthesize fileName;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.fileName = nil;
    }
    return self;
}

- (instancetype) initWithFileName:(NSString *)initialFileName {
    self = [super init];
    if (self) {
        self.fileName = initialFileName;
    }
    return self;
}

- (id <NSCoding>) objectForKey:(id <NSCopying>)key {

    NSDictionary *prefrences = [self preferences];

    id object = [prefrences objectForKey:key];

    if (!object) {
        return nil;
    }
    
    if([object isKindOfClass:[NSDictionary class]]) {
        return [NSDictionary dictionaryWithDictionary:object];
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:object];

}

- (void) setObject:(id <NSCoding>)object forKey:(id <NSCopying>)key {

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];

    if (!data) {
        return;
    }

    NSMutableDictionary *prefrences = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];

    [prefrences setObject:data forKey:key];
    [prefrences writeToURL:[self preferenceFileUrl] atomically:YES];

}

- (void) removeObjectForKey:(id <NSCopying>)key {

    NSMutableDictionary *prefrences = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];

    [prefrences removeObjectForKey:key];
    [prefrences writeToURL:[self preferenceFileUrl] atomically:YES];

}

- (void) removeAll {

    for (id key in [[self preferences] keyEnumerator]) {
        [self removeObjectForKey:key];
    }

}

- (NSDictionary *) preferences {
    return [NSDictionary dictionaryWithContentsOfURL:[self preferenceFileUrl]];
}

- (NSURL *) preferenceFileUrl {

    if (!fileName) {
        [[[Growthbeat sharedInstance] logger] error:@"GBPreference's fileName is not set."];
        return nil;
    }

    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];

    if ([urls count] == 0) {
        return nil;
    }

    NSURL *url = [urls lastObject];
    return [NSURL URLWithString:self.fileName relativeToURL:url];

}

@end
