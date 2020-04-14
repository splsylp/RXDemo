//
//  LanguageTools.h
//  TestSDK
//
//  Created by tianao on 2017/9/19.
//  Copyright © 2017年 田傲. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Chinese_Simple @"zh-Hans"
#define Chinese_Traditional @"zh-Hant"
#define English_US @"en"
#define Korean @"ko"

@interface LanguageTools : NSObject
@property (nonatomic,strong,readonly) NSBundle * bundle;

// 单例初始化方法
+ (id) sharedInstance;

// 根据key获取相应的String
- (NSString *) getStringForKey:(NSString *) key;

// 应用内设置新语言
- (void) setNewLanguage:(NSString *) language;


@end
