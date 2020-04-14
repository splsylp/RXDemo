//
//  RXCollectManager.h
//  Chat
//
//  Created by lxj on 2018/12/20.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RXCollectData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChatMoreActionFuncType) {
    /*  支持的消息转发、收藏、删除等功能  */
    ChatMoreActionFuncType_None = 200,
    /*  未下载不能转发  */
    ChatMoreActionFuncType_NotDownload,
    /*  不支持的消息转发、收藏、删除等功能  */
    ChatMoreActionFuncType_NotSupport
};


@interface RXCollectManager : NSObject

#pragma mark - 收藏相关
//解析im消息，获取收藏要准备的数据
+ (NSArray<RXCollectData *> *)getCollectionsWithMessageData:(NSArray *)messageData;
//收藏多条消息
+ (void)collectionRequestWithCollections:(NSArray *)collections sessionId:(NSString *)sessionId;

//检查im消息的职能
+ (ChatMoreActionFuncType)checkMessageMoreActionBarClickWithType:(ChatMoreActionBarType)type messageArr:(NSArray<ECMessage *> *)messageArr;


@end

NS_ASSUME_NONNULL_END
