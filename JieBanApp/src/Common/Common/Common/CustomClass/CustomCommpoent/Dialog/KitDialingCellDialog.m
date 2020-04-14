//
//  KitDialingCellDialog.m
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-31.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import "KitDialingCellDialog.h"
#import <UIKit/UIKit.h>
#import "UIColor+Ext.h"

@interface KitDialingCellDialog()

@property (weak, nonatomic) IBOutlet UIImageView *lineImageVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain,nonatomic) NSArray* list;
@end

@implementation KitDialingCellDialog

//- (void)dealloc
//{
//    [self setList:nil];
//}


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = ThemeFontLarge;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.titleLabel.textColor = [UIColor colorWithHexString:@"0x66B243"];
    self.lineImageVIew.backgroundColor = [UIColor colorWithHexString:@"0xEFEFEF"];
    
    
    if(self.totalItems){
        _list = self.totalItems();
    }else{
       
        _list = [[NSArray alloc]initWithObjects:languageStringWithKey(@"呼叫"), languageStringWithKey(@"添加到联系人"),languageStringWithKey(@"删除本条记录"), nil];
    }
}

- (void)resetResource
{
    
    
    if(self.totalItems){
        _list = self.totalItems();
    }else{
         _list = [[NSArray alloc]initWithObjects:languageStringWithKey(@"呼叫"), languageStringWithKey(@"添加到联系人"),languageStringWithKey(@"删除本条记录"), nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44*FitThemeFont;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [_list objectAtIndex:indexPath.row];
    cell.textLabel.font = ThemeFontMiddle;
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(10, 44*FitThemeFont - 0.5, cell.frame.size.width - 20, 0.5)];
    view.backgroundColor = [UIColor colorWithHexString:@"0xEFEFEF"];
    [cell.contentView addSubview:view];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weak_object = self;
    //__weak KitDialingCellDialog *RXSelf =self;
    if (self.selectIndex) {
        self.selectIndex(indexPath.row);
    }
    //[self dismissModalDialogWithAnimation:YES];
    if ([weak_object.list count]>0) {
//        [weak_object dismissModalDialogWithAnimation:YES];
    }
    else{
        
    }
}

@end
