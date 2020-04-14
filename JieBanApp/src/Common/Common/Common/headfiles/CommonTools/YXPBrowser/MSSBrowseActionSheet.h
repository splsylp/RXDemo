//
//  MSSBrowseActionSheet.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 16/2/14.
//  Copyright © 2016年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

enum MSSBrowseType{
    
    MSSBrowseTypeCollect = 0,
    
    MSSBrowseTypeSave,
    
    MSSBrowseTypeCopy,
    
    MSSBrowseTypeFCMsgList,
    
    MSSBrowseTypePhotoAlbum,
    
    MSSBrowseTypePhotos,
    
    MSSBrowseTypeCall,
    
    MSSBrowseTypeVideo,
    
    MSSBrowseTypeForward,
    
    MSSBrowseTypeHXVidyoMeeting,
    
    MSSBrowseTypeHFVidyoMeeting,
    
    MSSBrowseTypeSweepYard,
    
    MSSBrowseTypeEachForword,
    
    MSSBrowseTypeMergeForword,
    
    MSSBrowseTypeMergeDelete,
    
    MSSBrowseTypeLinkShare,
    
    MSSBrowseTypeVideoShooting,
    
    MSSBrowseTypeUnMute,
    
    MSSBrowseTypeMute,
    
    MSSBrowseTypeOpenVideo,
    
    MSSBrowseTypeCloseVideo,
    
    MSSBrowseTypeChangeName,
    
    MSSBrowseTypeKickOut,
    
    MSSBrowseTypeInvitationGoon,
    
    MSSBrowseTypeDeleteFromList,
};

typedef enum MSSBrowseType MSSBrowseType;

#define MSSBrowseTypeGet ([[NSArray alloc] initWithObjects:languageStringWithKey(@"收藏"),languageStringWithKey(@"保存图片"),languageStringWithKey(@"复制图片地址"),languageStringWithKey(@"消息列表"),languageStringWithKey(@"拍照"),languageStringWithKey(@"从相册中选择"),languageStringWithKey(@"语音通话"),languageStringWithKey(@"视频通话"),languageStringWithKey(@"分享"),@"恒信视频会议",@"拨号视频会议",languageStringWithKey(@"识别图中二维码"),languageStringWithKey(@"逐条转发"),languageStringWithKey(@"合并转发"),languageStringWithKey(@"合并删除"),languageStringWithKey(@"链接分享"),languageStringWithKey(@"小视频"),languageStringWithKey(@"解除静音"),languageStringWithKey(@"静音"),languageStringWithKey(@"开启视频"),languageStringWithKey(@"关闭视频"),languageStringWithKey(@"改名"),languageStringWithKey(@"移出"),languageStringWithKey(@"继续邀请"),languageStringWithKey(@"从列表中删除"),nil])
// 枚举 to 字串
#define MSSBrowseTypeString(type) ([MSSBrowseTypeGet objectAtIndex:type])
// 字串 to 枚举
#define MSSBrowseTypeEnum(string) ([MSSBrowseTypeGet indexOfObject:string])

typedef void(^MSSBrowseActionSheetDidSelectedAtIndexBlock)(NSInteger index);

@interface MSSBrowseActionSheet : UIView

- (instancetype)initWithTitleArray:(NSArray *)titleArray cancelButtonTitle:(NSString *)cancelTitle didSelectedBlock:(MSSBrowseActionSheetDidSelectedAtIndexBlock)selectedBlock;

- (instancetype)initWithTitleArray:(NSArray *)titleArray cancelButtonTitle:(NSString *)cancelTitle didSelectedBlock:(MSSBrowseActionSheetDidSelectedAtIndexBlock)selectedBlock dismissCompletion:(void(^)(void))dismissCompletion;

- (instancetype)initWithTip:(NSString *)tip titleArray:(NSArray *)titleArray cancelButtonTitle:(NSString *)cancelTitle didSelectedBlock:(MSSBrowseActionSheetDidSelectedAtIndexBlock)selectedBlock;

- (void)showInView:(UIView *)view;

- (void)disMissActionSheet;

// transform时更新frame
- (void)updateFrame;

@end
