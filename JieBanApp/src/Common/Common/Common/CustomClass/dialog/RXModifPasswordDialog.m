//
//  HYTModifPasswordDialog.m
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-3.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "RXModifPasswordDialog.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
@interface RXModifPasswordDialog()

@property (weak, nonatomic) IBOutlet UITextField *editTextField;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (assign,nonatomic) CGRect    keyboardRect;


@end

@implementation RXModifPasswordDialog

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")
- (void)awakeFromNib
{
    [super awakeFromNib];
    [_editTextField becomeFirstResponder];
    _editTextField.delegate=self;
    self.backgroundColor = ColorEFEFEF;
    [self.leftButton setBackgroundImage:[UIColor createImageWithColor:[UIColor whiteColor] andSize:self.leftButton.size] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIColor createImageWithColor:[UIColor grayColor] andSize:self.leftButton.size] forState:UIControlStateSelected];
    
    [self.rightButton setBackgroundImage:[UIColor createImageWithColor:[UIColor whiteColor] andSize:self.leftButton.size] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIColor createImageWithColor:[UIColor grayColor] andSize:self.leftButton.size] forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
//监听密码的长度
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"])
    {
        return YES;
        
    }
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(_editTextField==textField)
    {
        if(aString.length>16)
        {
            textField.text=[aString substringToIndex:16];
            return NO;
        }
    }
    
    return YES;
}
- (IBAction)actionHandle:(id)sender {
    
    UIButton* btn = (UIButton*)sender;
    //UITextView *editText =(UITextView*)[self viewWithTag:100];
    
    __weak RXModifPasswordDialog *hytSelf =self;
    
    switch (btn.tag) {
        case 0:
        {
              [hytSelf dismissModalDialogWithAnimation:YES];
        }
        break;
        case 1:
        {
            if (self.didSelected) {
                self.didSelected(_editTextField.text);
                
            }
                if ([_editTextField canResignFirstResponder]) {
                    [_editTextField resignFirstResponder];
                }
            if (_editTextField.text == nil || _editTextField.text.length == 0) {
                
            } else {
                 [hytSelf dismissModalDialogWithAnimation:YES];
            }
        }
        break;
        default:
            break;
    }
//    [hytSelf dismissModalDialogWithAnimation:YES];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat offSetY = rect.size.height - _keyboardRect.size.height - self.height;
    CGRect endRect = CGRectMake(self.originX, offSetY, self.width, self.height);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = endRect;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                         }
                     }];
    [self cancelTapGesture];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat offSetY = (rect.size.height - self.height)/2;
    CGRect endRect = CGRectMake(self.originX, offSetY, self.width, self.height);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = endRect;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                         }
                     }];
    [self addTapGesture];
}


@end
