//
//  SearchResPersonCell.h
//  Common
//
//  Created by eagle on 2019/3/1.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResPersonCell : UITableViewCell
@property (strong, nonatomic)  UIImageView *picImage;
@property (strong, nonatomic)  UILabel *titleLabel; // 群组名字
@property (strong, nonatomic)  UILabel *nameLab;//姓名
@property (strong, nonatomic)  UILabel *positionLab;//个人资料的职位 聊天记录的X条相聊天记录
@property (strong, nonatomic)  UILabel *timeLabel; //聊天记录后面时间  群组后面的y人数
@property (strong, nonatomic)  UIView *lineView;
@property (strong, nonatomic)  UILabel *placeLabel;//职位
//@property (strong, nonatomic)  RXGroupHeadImageView *headView;
-(UITableViewCell *)setPersonWithName:(NSString *)name  withAccount:(NSString *)account withPlace:(NSString *)place withDepartment:(NSString *)department searchText:(NSString *)searchText withHeadViewUrl:(NSString *)headViewUrlStr withHeadViewUrlMD5:(NSString *)headViewUrlMD5;
-(UITableViewCell *)setPersonWithDic:(NSDictionary *)dict withDepartmentName:(NSString *)departmentName searchText:(NSString *)searchText;

@end

NS_ASSUME_NONNULL_END
