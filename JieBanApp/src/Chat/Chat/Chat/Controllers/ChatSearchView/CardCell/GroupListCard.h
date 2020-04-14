//
//  GroupListCard.h
//  Chat
//
//  Created by lxj on 2018/11/13.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXGroupHeadImageView.h"
NS_ASSUME_NONNULL_BEGIN

@interface GroupListCard : UITableViewCell
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *photoView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel; // 群组名字
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;//姓名
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *infoLabel;//个人资料的职位 聊天记录的X条相聊天记录
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *timeLabel; //聊天记录后面时间  群组后面的y人数
@property (unsafe_unretained, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;//职位
@property (unsafe_unretained, nonatomic) IBOutlet RXGroupHeadImageView *headView;
///当前搜索的字
@property(nonatomic ,strong) NSString *currentSearchText;

///联系人
@property(nonatomic ,strong) NSDictionary *contactDic;
///联系人对象
@property(nonatomic ,strong) KitCompanyAddress *address;




///聊天记录
@property(nonatomic ,strong) NSDictionary *recordDic;

///群组
@property(nonatomic ,strong) ECGroup *group;
- (void)reloadImage;

///消息
@property(nonatomic ,strong) ECSession *session;
@property(nonatomic ,strong) ECMessage *message;

@end

NS_ASSUME_NONNULL_END
