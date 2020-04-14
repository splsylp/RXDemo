//
//  SearchPublicResultCard.h
//  Chat
//
//  Created by mac on 2017/4/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPublicResultCard : UITableViewCell
@property(nonatomic,strong)UIImageView *headImg;//头像
@property(nonatomic,strong)UILabel *nameLabel;//公众号名称
@property(nonatomic,strong)UILabel *introduceLabel;//介绍
-(void)setPublicSearchDic:(NSDictionary *)searchDic cellIndex:(NSIndexPath *)indexPath searchString:(NSString *)searchString;
@end
