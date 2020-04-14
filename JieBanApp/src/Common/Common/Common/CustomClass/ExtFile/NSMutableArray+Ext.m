//
//  NSMutableArray+Ext.m
//  Lafaso
//
//  Created by wj on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import "NSMutableArray+Ext.h"
#import <UIKit/UIKit.h>
@implementation NSMutableArray (value)

- (void)addBoolValue:(BOOL)value
{
    [self addObject:[NSNumber numberWithBool:value]];
}

- (void)addIntValue:(int)value
{
    [self addObject:[NSNumber numberWithInt:value]];
}

- (void)addIntegerValue:(NSInteger)value
{
    [self addObject:[NSNumber numberWithInteger:value]];
}

- (void)addLongValue:(long)value
{
    [self addObject:[NSNumber numberWithLong:value]];
}

- (void)addLongLongValue:(long long)value
{
    [self addObject:[NSNumber numberWithLongLong:value]];
}

- (void)addFloatValue:(float)value
{
    [self addObject:[NSNumber numberWithFloat:value]];
}

- (void)addDoubleValue:(double)value
{
    [self addObject:[NSNumber numberWithDouble:value]];
}

@end

@implementation NSMutableArray (Data)//by shan

- (void)addRectValue:(CGRect)value
{
//    CFDictionaryRef dictionaryRef = CGRectCreateDictionaryRepresentation(value);
//    if (dictionaryRef) {
//        [self addObject:(NSDictionary *)dictionaryRef];
//        CFRelease(dictionaryRef);
//    }
}

- (void)addSizeValue:(CGSize)size
{
//    CFDictionaryRef dictionaryRef = CGSizeCreateDictionaryRepresentation(size);
//    if (dictionaryRef) {
//        [self addObject:(NSDictionary *)dictionaryRef];
//        CFRelease(dictionaryRef);
//    }
}

- (void)addPointValue:(CGPoint)point
{
//    CFDictionaryRef dictionaryRef = CGPointCreateDictionaryRepresentation(point);
//    if (dictionaryRef) {
//        [self addObject:(NSDictionary *)dictionaryRef];
//        CFRelease(dictionaryRef);
//    }
}

- (void)addCString:(const char *)cString
{
    if (cString) {
        [self addObject:[NSString stringWithUTF8String:cString]];
    }
}

- (void)addSelector:(SEL)selector
{
    [self addCString:sel_getName(selector)];
}

@end
