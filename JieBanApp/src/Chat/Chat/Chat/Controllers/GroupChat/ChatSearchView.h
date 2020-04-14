//
//  ChatSearchView.h
//  Chat
//
//  Created by zhangmingfei on 2016/11/19.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatSearchViewDelagate <NSObject>

- (void)SearchTextViewCancelAction;

- (void)SearchTextViewDidChange;

@end

@interface ChatSearchView : UIView<UITextViewDelegate>

@property (nonatomic ,weak) id<ChatSearchViewDelagate>delgate;

@property (nonatomic ,strong) UITextView *searchTextView;
@property (nonatomic ,strong) UILabel *placeholderLabel;
@property (nonatomic ,strong) UIButton *cancelButton;
@property (strong,nonatomic)  UIImageView *imgView;

@end
