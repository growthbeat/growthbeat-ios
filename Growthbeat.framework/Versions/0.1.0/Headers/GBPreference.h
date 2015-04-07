//
//  GBPreference.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/17.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBPreference : NSObject {

    NSString *fileName;

}

@property (nonatomic, strong) NSString *fileName;

- (instancetype)initWithFileName:(NSString *)initialFileName;
- (id)objectForKey:(id <NSCopying>)key;
- (void)setObject:(id)object forKey:(id <NSCopying>)key;
- (void)removeObjectForKey:(id <NSCopying>)key;
- (void)removeAll;

@end
