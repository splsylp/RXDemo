//
//  HYTMediaContactsListViewController.h
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-5.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "BaseViewController.h"
//typedef void (^PopViewBlock)(NSDictionary *dataDic);//pop回去的时候传值

@interface HYTMediaContactsListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSInteger currentIndex;
    NSInteger curRequestCount;
    NSString *recordCur;//记录是否已经在把数据存进数据库
    NSInteger curReqCount;//网上请求数据的个数的;

}
@property(nonatomic,strong)UILabel *titleLabel;
@property (nonatomic, strong) UIButton * returnBtn;
@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) ECMessage *message;//用于消息转发
@property (strong,nonatomic)NSMutableArray *vidyoMemeberList;//vidyo
@property (assign,nonatomic)BOOL isFromVidyoVC;//是否从vidyoVC跳转过来
@end
