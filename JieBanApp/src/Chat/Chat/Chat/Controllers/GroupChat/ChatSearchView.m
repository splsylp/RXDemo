//
//  ChatSearchView.m
//  Chat
//
//  Created by zhangmingfei on 2016/11/19.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatSearchView.h"

@implementation ChatSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCustomView];
        
    }
    return self;
}

- (void)createCustomView{
    
    self.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    UIView *searchBackgroundColorView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth-10, 40*fitScreenWidth)];
    searchBackgroundColorView.backgroundColor = [UIColor clearColor];
    [self addSubview:searchBackgroundColorView];
    
    //搜索图片
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5*fitScreenWidth,12*fitScreenWidth, 17, 17)];
    _imgView.image = ThemeImage(@"search_icon");
    [self addSubview:_imgView];
    
    self.searchTextView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgView.frame), 0, kScreenWidth - CGRectGetMaxX(_imgView.frame),40 * fitScreenWidth)];
    self.searchTextView.font = SystemFontLarge;
    self.searchTextView.textColor = [UIColor blackColor];
    self.searchTextView.delegate = self;
    self.searchTextView.scrollEnabled = NO;
    self.searchTextView.textContainerInset = UIEdgeInsetsMake(12*fitScreenWidth, 0, 0, 0);
    self.searchTextView.returnKeyType = UIReturnKeySearch;
    
    self.searchTextView.backgroundColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    [self addSubview:self.searchTextView];
    
    
    self.placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(3*fitScreenWidth, 0, self.searchTextView.right, 40*fitScreenWidth)];
    self.placeholderLabel.enabled = NO;
    self.placeholderLabel.backgroundColor=[UIColor clearColor];
    self.placeholderLabel.text = languageStringWithKey(@"搜索");
    self.placeholderLabel.font = SystemFontLarge;
    self.placeholderLabel.textColor = [UIColor colorWithHexString:@"BFBFBF"];
    [self.searchTextView addSubview:self.placeholderLabel];
}

- (void)cancelAction{
    self.searchTextView.text = nil;
    [self.searchTextView resignFirstResponder];
    [self.placeholderLabel setHidden:NO];
    [self.cancelButton setHidden:YES];
    [self.delgate SearchTextViewCancelAction];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.imgView.hidden = YES;
    self.searchTextView.frame = CGRectMake(0, 0, kScreenWidth - 5, 40*fitScreenWidth);
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    self.searchTextView.frame = CGRectMake(CGRectGetMaxX(self.imgView.frame), 0, kScreenWidth - CGRectGetMaxX(self.imgView.frame), 40*fitScreenWidth);
    self.imgView.hidden = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [self.placeholderLabel setHidden:NO];
        [self.cancelButton setHidden:YES];
        self.imgView.hidden = YES;
        
    }else{
        [self.placeholderLabel setHidden:YES];
        [self.cancelButton setHidden: NO];
        
    }
    [self.delgate SearchTextViewDidChange];
}


@end
