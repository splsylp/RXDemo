//
//  KitAddressBook.m
//  HIYUNTON
//
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "KitAddressBook.h"

#import "KitCompanyAddress.h"
#import "RX_KCPinyinHelper.h"

@implementation KitAddressBook

- (id)init{
    self = [super init];
    if (self) {
        self.phones = [NSMutableDictionary dictionary];
        self.others = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)setName:(NSString *)name{
    _name = name;
    _firstLetter = [RX_KCPinyinHelper quickConvert:name];
    _pyname = [RX_KCPinyinHelper pinyinFromChiniseString:name];
}

+ (KitAddressBook *)getAddressBook:(NSString *)mobiel{
    KitCompanyAddress *address = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:mobiel];
    if (address) {
        KitAddressBook *book = [[KitAddressBook alloc] init];
        book.nickname = address.name;
        book.mobilenum = mobiel;
        return book;
    }
    return nil;
}


@end
