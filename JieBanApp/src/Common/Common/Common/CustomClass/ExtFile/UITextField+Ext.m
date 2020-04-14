//
//  UITextField+Ext.m
//  Rongxin
//
//  Created by yuxuanpeng MINA on 14-10-10.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import "UITextField+Ext.h"
#import "Common.h"
#import "KCConstants_string.h"
@implementation UITextField (Ext)

- (BOOL)isTextFieldEmptyWithWarning:(NSString *)warning
{
    if (KCNSSTRING_ISEMPTY(self.text)) {
        [SVProgressHUD showErrorWithStatus:warning];
        return YES;
    }
    return NO;
}
-(BOOL)isTextFieldOuttoTenWithWarning:(NSString *)warning
{
    if(self.text.length>10)
    {
        [SVProgressHUD showErrorWithStatus:warning];
        return YES;
    }
    return NO;
}
-(BOOL)isTextFieldOuttoFiftyWithWarning:(NSString *)warning
{
    if(self.text.length>45)
    {
        [SVProgressHUD showErrorWithStatus:warning];
        return YES;
    }
    return NO;
}
@end
