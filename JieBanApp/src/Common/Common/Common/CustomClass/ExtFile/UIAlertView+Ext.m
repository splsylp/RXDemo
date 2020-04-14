//
//  UIAlertView+Ext.m
//  golf-brothers
//
//  Created by huangtony on 14-9-13.
//  Copyright (c) 2014年 Nick Lious. All rights reserved.
//

#import "UIAlertView+Ext.h"
#import <objc/runtime.h>

@interface GFUIAlertView : UIAlertView<UIAlertViewDelegate>
@end

@implementation GFUIAlertView
static char kWhenTappedBlockKey;
static char kWhenCancelBlockKey;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark Set blocks

- (void)runBlockForKey:(void *)blockKey {
    JMWhenClickedBlock block = objc_getAssociatedObject(self, blockKey);
    if (block) block();
}

- (void)setBlock:(JMWhenClickedBlock)block forKey:(void *)blockKey {
    self.userInteractionEnabled = YES;
    objc_setAssociatedObject(self, blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self runBlockForKey:&kWhenCancelBlockKey];
    }else{
        [self runBlockForKey:&kWhenTappedBlockKey];
    }
}

@end

@implementation UIAlertView (Ext)

+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click cancel:(JMWhenClickedBlock)cancel
{
    GFUIAlertView *alertView = [[GFUIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:languageStringWithKey(@"否") otherButtonTitles:languageStringWithKey(@"是"), nil];
    
    [alertView show];
    [alertView setBlock:click forKey:&kWhenTappedBlockKey];
    [alertView setBlock:cancel forKey:&kWhenCancelBlockKey];
    return alertView;
}

+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click onText:(NSString *)okText cancel:(JMWhenClickedBlock)cancel cancelText:(NSString *)cancelText
{
    GFUIAlertView *alertView = [[GFUIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelText otherButtonTitles:okText, nil];
    [alertView show];
    [alertView setBlock:click forKey:&kWhenTappedBlockKey];
    [alertView setBlock:cancel forKey:&kWhenCancelBlockKey];
    return alertView;
}

+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click cancelText:(NSString *)cancelText okText:(NSString *)okText
{
    GFUIAlertView *alertView = [[GFUIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelText otherButtonTitles:okText, nil];
    [alertView show];
    [alertView setBlock:click forKey:&kWhenTappedBlockKey];
    return alertView;
}

+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click  okText:(NSString *)okText
{
    GFUIAlertView *alertView = [[GFUIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:okText otherButtonTitles:nil, nil];
    [alertView show];
    [alertView setBlock:click forKey:&kWhenCancelBlockKey];
    return alertView;
}

@end
