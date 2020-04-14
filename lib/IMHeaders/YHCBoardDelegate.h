//
//  YHCBoardDelegate.h
//  Board
//
//  Created by 王文龙 on 2018/5/2.
//  Copyright © 2018年 maibou. All rights reserved.
//

@protocol YHCBoardDelegate <NSObject>

@optional

//会议中发起共享
- (UIViewController *)getChooseDocumentVCWhenCreateBoardInConf:(NSString *)conferenceId withModeratorId:(NSString *)moderatorId completion:(void(^)(ECError *error, NSDictionary *roomInfo))completion;

@end
