//
//  ChatMoreActionBar.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 2016/12/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChatMoreActionBarType) {
    /*  转发  单条*/
    ChatMoreActionBarType_forword = 100,
    /*  转发  多条合并转发*/
    ChatMoreActionBarType_forword_Multiple_Merge , 
    /*  收藏  */
    ChatMoreActionBarType_collection,
    /*  删除  */
    ChatMoreActionBarType_delete
    

    
};

@protocol ChatMoreActionBarDelegate <NSObject>

- (void)ChatMoreActionBarClickWithType:(ChatMoreActionBarType)type;
@end

@interface ChatMoreActionBar : UIView

@property (nonatomic, strong) UIButton * forWardBtn;//转发
@property (nonatomic, strong) UIButton * collectionBtn;//收藏
@property (nonatomic, strong) UIButton * deleteBtn;//删除
@property (nonatomic, assign) BOOL disabled;//是否禁用


@property (nonatomic, assign) id<ChatMoreActionBarDelegate>delegate;

@end
