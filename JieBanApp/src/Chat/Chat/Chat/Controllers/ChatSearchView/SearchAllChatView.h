//
//  SearchAllChatView.h
//  Chat
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DidSelectSearchDelegate <NSObject>

@optional
- (void)didSelectSearch:(NSString *)sessionId;
- (void)didScrollRegisBoad;

@end

@interface SearchAllChatView : UIView

@property (nonatomic, assign) id<DidSelectSearchDelegate>delegate;

- (void)reloadSearchText:(NSString *)text withSessions:(NSMutableArray *)sessions withVC:(BaseViewController *)currentVC withSearchB:(UISearchBar *)searcB;
@property (nonatomic, strong) UISearchBar *textF;
///内容视图的位移
@property (nonatomic, assign) CGFloat contentShift;
///动画持续时间
@property (nonatomic, assign) CGFloat animationTime;

///移除popView
- (void)dismissThePopView;


@end
