//
//  UITextField+Ext.h
//  Rongxin
//
//  Created by yuxuanpeng MINA on 14-10-10.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Ext)

/**
 *  输入文字为空，给予提示
 *
 *  @param warning 提示文字
 *
 *  @return 是否为空
 */
- (BOOL)isTextFieldEmptyWithWarning:(NSString *)warning;
/**
 *  输入超过群组名称10个字 群公告45个字，给予提示
 *
 *  @param warning 提示文字
 *
 *  @return 是否超过
 */
- (BOOL)isTextFieldOuttoTenWithWarning:(NSString *)warning;
- (BOOL)isTextFieldOuttoFiftyWithWarning:(NSString *)warning;
@end
