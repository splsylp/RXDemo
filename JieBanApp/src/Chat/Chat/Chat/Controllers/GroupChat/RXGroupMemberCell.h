//
//  RXGroupMemberCell.h
//  Chat
//
//  Created by apple on 2019/11/20.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KitGroupMemberInfoData.h"

typedef NS_ENUM(NSUInteger, RXGroupMembersStyle) {
    RXGroupMembersStyleNone,
    RXGroupMembersStyleSetOwner,
    RXGroupMembersStyleSetAdmin,
    RXGroupMembersStyleShowMemberInfo,
    RXGroupMembersStyleDeleteAdmin
};

@protocol GroupMemberCellDelegate <NSObject>

@optional
- (void)deleteAdminAtIndexPath:(NSIndexPath *_Nonnull)indexPath;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RXGroupMemberCell : UITableViewCell

@property (nonatomic, strong) KitGroupMemberInfoData *mebmerInfo;

@property (nonatomic, weak) id <GroupMemberCellDelegate> gmDelegate;

@property (nonatomic, assign) RXGroupMembersStyle style;

- (instancetype) initWithInTableView:(UITableView *)tableView withStyle:(RXGroupMembersStyle)style atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
