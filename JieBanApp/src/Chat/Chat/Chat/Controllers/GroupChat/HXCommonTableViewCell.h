//
//  HXCommonTableViewCell.h
//  Chat
//
//  Created by apple on 2019/11/14.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCommonTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImgView;
@end

NS_ASSUME_NONNULL_END
