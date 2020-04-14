//
//  SessionViewCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXGroupHeadImageView.h"

@protocol SessionViewCellDelegate <NSObject>

-(void)updateListAllData;//刷新列表所有的数据

-(void)updateSessionTableView;//刷新tableView

//updateType 类型 0/1/2 更新/删除/其他
-(void)updateSessionArray:(ECSession *)session updateType:(NSInteger)updateType indexPath:(NSIndexPath *)indexPath;

@end
@interface SessionViewCell : UITableViewCell
@property (nonatomic, strong) RXGroupHeadImageView * groupHeadView;
@property (nonatomic, strong, readonly) UIImageView *portraitImg;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *stateLabel;//网络状态
@property (nonatomic, strong, readonly) UILabel *deptlabel;//部门,名称  用来展示网络状态了
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong, readonly) UILabel *unReadLabel;
@property (nonatomic, strong, readonly) UILabel *dateLabel;
@property (nonatomic, strong, readonly) UILabel *atLabel;
@property (nonatomic, strong, readonly) UIView *lineView;
@property (nonatomic, strong, readonly) UIImageView *notDisturbView;//消息免打扰
@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,retain) ECSession* session;
@property (nonatomic,assign) id<SessionViewCellDelegate> delegate;
@property(nonatomic,assign) CGFloat deviceScale;//当前设备比例

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDeviceScale:(CGFloat)deviceScale;

@end
