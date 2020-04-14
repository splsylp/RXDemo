//
//  RXChatFileManager.m
//  Chat
//
//  Created by 高源 on 2019/5/13.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXChatFileManager.h"

@interface RXChatFileManager()<ECProgressDelegate>

/** progressBlock<##> */
@property(nonatomic,strong)void (^progressBlock)(CGFloat progress);

@end

@implementation RXChatFileManager

+ (RXChatFileManager *)sharedInstance{
    static RXChatFileManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[RXChatFileManager alloc] init];
    });
    return manager;
}

- (void)downloadMediaMessage:(ECMessage *)message progress:(void (^)(CGFloat progress))progress completion:(void (^)(ECError *error, ECMessage *message))completion {
    self.progressBlock = progress;
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:message progress:self completion:completion];
}

- (void)setProgress:(float)progress forMessage:(ECMessage *)message {
    !self.progressBlock?:self.progressBlock(progress);
}


@end
