//
//  HXSendFileViewController.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseViewController.h"
@class HXSendFileViewController;

@protocol HXSendFileViewControllerDelegate <NSObject>

- (void)SelectCacheDocumentViewController:(HXSendFileViewController *)viewControllerr didSelectCacheObjects:(NSArray *)aCacheObjects albumObjects:(NSArray *)aAlbumObjects;

@end
@interface HXSendFileViewController : BaseViewController
@property (nonatomic,assign) id<HXSendFileViewControllerDelegate>delegate;
@property (nonatomic,assign)NSInteger WBFlag;
@property (nonatomic,retain)NSString *identifier;
@property (nonatomic,assign)NSInteger limitSelectCount;


@property(nonatomic,assign)BOOL isFromHFSendFile;//恒丰新增，表示从聊天发文件
@end
