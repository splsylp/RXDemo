/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "IMCommon.h"

@implementation IMConversation
- (void)dealloc
{
    self.conversationId = nil;
    self.contact = nil;
    self.date = nil;
    self.content = nil;
    self.woId = nil;
    self.alias = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end

@implementation IMMessageObj
- (id)init
{
    if (self = [super init])
    {
        self.isChunk = NO;
    }
    return self;
}
- (void)dealloc
{
    self.fileExt = nil;
    self.filePath = nil;
    self.fileUrl = nil;
    self.content = nil;
    self.userData = nil;
    self.curDate = nil;
    self.dateCreated = nil;
    self.sender = nil;
    self.sessionId = nil;
    self.msgid = nil;
    self.woId = nil;
    self.alias = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end

@implementation IMGroupNotice

- (id)init
{
    if (self = [super init])
    {
        self.messageId = -1;
    }
    return self;
}

- (void)dealloc
{
    self.verifyMsg = nil;
    self.groupId = nil;
    self.who = nil;
    self.curDate = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end

@implementation IMGroupInfo

-(id)init
{
    self = [super init];
    if (self)
    {
        self.declared = @"";
    }
    return self;
}
-(void)dealloc
{
    self.groupId = nil;
    self.name = nil;
    self.owner = nil;
    self.declared = nil;
    self.created = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end

