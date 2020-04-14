//
//  NSMutableDictionary+Ext.m
//  Lafaso
//
//  Created by yuxuanpeng MINA on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import "NSMutableDictionary+Ext.h"

@implementation NSMutableDictionary (value)

- (void)setBoolValue:(BOOL)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithBool:value] forKey:key];
    }
}

- (void)setIntValue:(int)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithInt:value] forKey:key];
    }
}

- (void)setIntegerValue:(NSInteger)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithInteger:value] forKey:key];
    }
}

- (void)setLongValue:(long)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithLong:value] forKey:key];
    }
}

- (void)setLongLongValue:(long long)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithLongLong:value] forKey:key];
    }
}

- (void)setFloatValue:(float)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithFloat:value] forKey:key];
    }
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key
{
    if (key) {
        [self setValue:[NSNumber numberWithDouble:value] forKey:key];
    }
}

@end

@implementation NSMutableDictionary (Data)

- (void)setRectValue:(CGRect)value forKey:(NSString *)key
{
    if (key) {
        CFDictionaryRef dictionaryRef = CGRectCreateDictionaryRepresentation(value);
        if (dictionaryRef) {
            [self setValue:(__bridge NSDictionary *)dictionaryRef forKey:key];
            CFRelease(dictionaryRef);
        }
    }
}

- (void)setPointValue:(CGPoint)value forKey:(NSString *)key
{
    if (key) {
        CFDictionaryRef dictionaryRef = CGPointCreateDictionaryRepresentation(value);
        if (dictionaryRef) {
            [self setValue:(__bridge NSDictionary *)dictionaryRef forKey:key];
            CFRelease(dictionaryRef);
        }
    }
}

- (void)setSizeValue:(CGSize)value forKey:(NSString *)key
{
    if (key) {
        CFDictionaryRef dictionaryRef = CGSizeCreateDictionaryRepresentation(value);
        if (dictionaryRef) {
            [self setValue:(__bridge NSDictionary *)dictionaryRef forKey:key];
            CFRelease(dictionaryRef);
        }
    }
}

- (void)setCString:(const char *)cString forKey:(NSString *)key
{
    if (key) {
        if (cString) {
            [self setValue:[NSString stringWithUTF8String:cString] forKey:key];
        }
    }
}

- (void)setSelector:(SEL)selector forKey:(NSString *)key
{
    if (key) {
        if (selector) {
            [self setCString:sel_getName(selector) forKey:key];
        }
    }
}

@end
