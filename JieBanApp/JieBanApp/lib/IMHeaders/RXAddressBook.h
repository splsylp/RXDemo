//
//  AddressBook.h
//  AddressBook
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KitBaseHeader.h"
@interface RXAddressBook :  NSObject

@property (nonatomic,assign) BOOL isSpecialAttUpdate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RXAddressBook);
- (UIViewController*)mainView;
//获取选择联系人界面
- (UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(NSNumber *)type;

//根据手机号获取本地通讯录名字
- (NSString *)getLocalAddressNameWithPhoneNumber:(NSString *)phone;

//获取联系人详情页面
-(UIViewController *)getContactorInfosVCWithData:(id)data;


//获取企业通讯录  不需要遍历
- (NSNumber *)getCompanyAddressBookCount;

//获取所有本地通讯录
- (NSMutableArray*)getPhoneAddressArray;

//获取关注的好友
-(id)updateLoadingSpecialAtt:(NSString *)isAddReuqeest;

- (void)reloadAddressData:(NSString *)isAppearView;

//更新通讯录
- (void)updateAdrressBook:(void (^)(BOOL success))completion;

//获取添加好友界面
-(UIViewController *)getAddRXfriend:(NSDictionary *)data;


@end
