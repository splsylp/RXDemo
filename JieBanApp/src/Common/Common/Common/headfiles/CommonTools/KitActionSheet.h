//
//  KitActionSheet.h
//  Rongxin
//
//  Created by yuxuanpeng on 14-10-21.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EActionSheetResource) {
     EActionSheetSearch,   //搜索的结果
     EActionSheetAddressBook, //打过或者接过的电话
     EActionSheetOther,     //键盘输入的电话
};

@class KitActionSheet;

@protocol KitActionSheetDelegate <NSObject>
- (void)actionSheet:(KitActionSheet*)actionSheet index:(NSInteger )index;
@optional
- (void)didClickOnDestructiveButton;
- (void)didClickOnCancelButton;
@end

@interface KitActionSheet : UIView
@property (assign,nonatomic) EActionSheetResource resource;
@property (assign,nonatomic) BOOL isVoipAccount;
@property (copy,nonatomic)NSString* phone;
@property (nonatomic , copy) NSArray *(^otherButtonColor)(void);

- (id)initWithTitle:(NSString *)title delegate:(id<KitActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitlesArray;
- (void)showInView:(UIView *)view;

@end
