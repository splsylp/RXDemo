//
//  GroupMemberCollectionViewCell.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXThirdPart.h"

@protocol GroupMemberCollectionViewCellDelegate <NSObject>

-(void)onChickDeleteMemberIndex:(NSInteger )curIndex withMemberName:(NSString *)name;
-(void)onchickHeadImgMemberIndex:(NSInteger )curIndex withMemberName:(NSString *)name;

@end

@interface GroupMemberCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView *headerIconView;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIButton *deleteBtn;
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,assign)id<GroupMemberCollectionViewCellDelegate>delegate;
- (void)iconViewLayerAnimation;
-(void)deleteAnimation;
@end
