//
//  NSArray+Ext.m
//  Lafaso
//
//  Created by wj on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import "NSArray+Ext.h"
#import <UIKit/UIKit.h>
@implementation NSArray (value)

- (BOOL)boolValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return NO;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj boolValue];
    }
    
    return NO;
}

- (int)intValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return 0;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return (int)[(NSNumber *)obj integerValue];
    }
    
    return 0;
}

- (NSInteger)integerValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return 0;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj integerValue];
    }
    
    return 0;
}

- (long)longValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return 0l;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj longValue];
    }
    
    return 0l;
}

- (long long)longlongValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return 0ll;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj longLongValue];
    }
    
    return 0ll;
}

- (float)floatValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return 0.0f;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj floatValue];
    }
    
    return 0.0f;
}

- (double)doubleValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return 0.0f;
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj doubleValue];
    }
    
    return 0.0f;
}

@end

@implementation NSArray (Data)

- (CGRect)rectValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return CGRectZero;
    }
    
    CGRect rect = CGRectZero;
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        BOOL result = CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)obj, &rect);
        if (!result) {
            rect = CGRectZero;
        }
    }
    
    return rect;
}

- (CGSize)sizeValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return CGSizeZero;
    }
    
    CGSize size = CGSizeZero;
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        BOOL result = CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)obj, &size);
        if (!result) {
            size = CGSizeZero;
        }
    }
    
    return size;
}

- (CGPoint)pointValueForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return CGPointZero;
    }
    
    CGPoint point = CGPointZero;
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        BOOL result = CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)obj, &point);
        if (!result) {
            point = CGPointZero;
        }
    }
    
    return point;
}

- (const char *)cstringForIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return "";
    }
    
    id obj = [self objectAtIndex:index];
    if ([obj respondsToSelector:@selector(UTF8String)]) {
        return [obj UTF8String];
    }
    
    return "";
}

- (SEL)selectorForIndex:(NSInteger)index
{
    SEL selector = NULL;
    const char *name = [self cstringForIndex:index];
    if (name) {
        selector = sel_registerName(name);
    }
    
    return selector;
}

- (NSString *)arrayToString {
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (id)toArrayWithString:(NSString *)jsonStr {
    
    id jsonObject = nil;
    NSError *error = nil;
    if ([jsonStr isKindOfClass:[NSString class]]) {
        NSData *jsonData =[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingAllowFragments
                                                       error:&error];
    }
    if (jsonObject != nil && error == nil && [jsonObject isKindOfClass:[NSArray class]]){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}

@end
