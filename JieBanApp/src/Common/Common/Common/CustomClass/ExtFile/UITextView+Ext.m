//
//  UITextView+Ext.m
//  Rongxin
//
//  Created by yuxuanpeng on 14-10-18.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import "UITextView+Ext.h"
#import "Common.h"
#import "KCConstants_string.h"
@implementation UITextView (Ext)

- (BOOL)isTextFieldEmptyWithWarning:(NSString *)warning
{
    if (KCNSSTRING_ISEMPTY(self.text)) {
//        [[Common sharedInstance] showErrorWithStatus:warning];
        [SVProgressHUD showErrorWithStatus:warning];
        return YES;
    }
    return NO;
}
@end
