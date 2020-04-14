//
//  SendFileData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/24.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "SendFileData.h"
#import <WCDB/WCDB.h>

@interface SendFileData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(fileUrl)
WCDB_PROPERTY(locatPath)
WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(fileDirectory)
WCDB_PROPERTY(identifer)
WCDB_PROPERTY(disPathName)
WCDB_PROPERTY(extension)
WCDB_PROPERTY(fileUuid)
WCDB_PROPERTY(fileKey)
WCDB_PROPERTY(fileSize)

@end
