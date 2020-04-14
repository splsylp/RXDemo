//
//  KitKeyBoard.h
//  ccp_ios_kit
//
//  Created by yuxuanpeng on 16/3/1.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KitKeyBoardDelegate;

@interface KitKeyBoard : UIView
@property (strong,nonatomic)NSString *inputText;

+ (id)showInView:(UIView *)view withDelegate:(id<KitKeyBoardDelegate>)delegate;
+ (id)showInMeetDialView:(UIView *)view withDelegate:(id<KitKeyBoardDelegate>)delegate;
- (void)onClickKeyboardButton:(id)sender;
-(void)hiddenKeyBoard;
- (void)showkeyBoard:(UIView *)view;

- (IBAction)onClickDelButton:(id)sender;
- (IBAction)addAddressButtom:(id)sender;
@end
@protocol KitKeyBoardDelegate <NSObject>

- (void)keyBoard:(KitKeyBoard *)keyboard currentKey:(NSString *)key;

- (void)keyBoard:(KitKeyBoard *)keyboard text:(NSString*)text index:(NSInteger )index;

- (void)keyBoardDidmiss:(KitKeyBoard *)keyboard;

-(void)keyBoardAddMobile:(KitKeyBoard *)keyboard text:(NSString *)text;

-(void)hiddenKeyBoard:(KitKeyBoard *)keyBoard;
@end
