//
//  RXChatFileManager.h
//  Chat
//
//  Created by 高源 on 2019/5/13.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RXChatFileManager : NSObject

+ (RXChatFileManager *)sharedInstance;
/*
  [[ECDevice sharedInstance].messageManager downloadMediaMessage:message progress:nil completion:^(ECError *error, ECMessage *message)
 */

- (void)downloadMediaMessage:(ECMessage *)message progress:(void (^)(CGFloat progress))progress completion:(void (^)(ECError *error, ECMessage *message))completion;

@end

NS_ASSUME_NONNULL_END
