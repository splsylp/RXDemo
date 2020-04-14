//
//  BaseModel.m
//  Common
//
//  Created by lxj on 2018/7/27.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

#pragma mark - 李晓杰添加 打印看到属性
// 重写debugDescription, 而不是description
- (NSString *)debugDescription {
    //声明一个字典
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    //得到当前class的所有属性
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);

    //循环并用KVC得到每个属性的值
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name]?:@"nil";//默认值为nil字符串
        [dictionary setObject:value forKey:name];//装载到字典里
    }

    //释放
    free(properties);

    //return
    return [NSString stringWithFormat:@"<%@: %p> -- %@",[self class],self,dictionary];
}

@end
