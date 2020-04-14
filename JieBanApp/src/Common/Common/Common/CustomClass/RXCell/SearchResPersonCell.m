//
//  SearchResPersonself.m
//  Common
//
//  Created by eagle on 2019/3/1.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "SearchResPersonCell.h"
#import "NSObject+Ext.h"


@implementation SearchResPersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.picImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5 * FitThemeFont, 45 * FitThemeFont, 45 * FitThemeFont)];
    self.picImage.tag = 100;
    self.picImage.layer.cornerRadius = self.picImage.frame.size.width / 2;
    self.picImage.layer.masksToBounds = YES;
    self.picImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.picImage];

    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(65 * FitThemeFont, 7 * FitThemeFont, kScreenWidth - 65 * FitThemeFont - 10, 20 * FitThemeFont)];
    nameLab.font = ThemeFontLarge;
    nameLab.tag = 101;
    self.nameLab = nameLab;
    [self.contentView addSubview:nameLab];

    
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right, 7 * FitThemeFont, 150 * FitThemeFont, 20 * FitThemeFont)];
    placeLabel.tag = 102;
    placeLabel.font = ThemeFontLarge;
    placeLabel.backgroundColor = [UIColor clearColor];
    placeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.placeLabel = placeLabel;
    [self.contentView addSubview:placeLabel];

    UILabel *positionLab = [[UILabel alloc] initWithFrame:CGRectMake(65 * FitThemeFont, 30 * FitThemeFont, kScreenWidth - 65 * FitThemeFont - 10, 16 * FitThemeFont)];
    positionLab.tag = 103;
    positionLab.font = ThemeFontMiddle;
    positionLab.textColor = [UIColor lightGrayColor];
    self.positionLab = positionLab;
    [self.contentView addSubview:positionLab];

    // 分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.picImage.right, 55 * FitThemeFont - 1, kScreenWidth - self.picImage.right, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    [self.contentView addSubview:lineView];

}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;


}
-(void)buildUI{
    // Initialization code
    self.picImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5 * FitThemeFont, 45 * FitThemeFont, 45 * FitThemeFont)];
    self.picImage.tag = 100;
    self.picImage.layer.cornerRadius = self.picImage.frame.size.width / 2;
    self.picImage.layer.masksToBounds = YES;
    self.picImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.picImage];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(65 * FitThemeFont, 7 * FitThemeFont, kScreenWidth - 65 * FitThemeFont - 10, 20 * FitThemeFont)];
    nameLab.font = ThemeFontLarge;
    nameLab.tag = 101;
    self.nameLab = nameLab;
    [self.contentView addSubview:nameLab];
    
    
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right, 7 * FitThemeFont, 150 * FitThemeFont, 20 * FitThemeFont)];
    placeLabel.tag = 102;
    placeLabel.font = ThemeFontMiddle;
    placeLabel.backgroundColor = [UIColor clearColor];
    placeLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    self.placeLabel = placeLabel;
    [self.contentView addSubview:placeLabel];
    
    UILabel *positionLab = [[UILabel alloc] initWithFrame:CGRectMake(65 * FitThemeFont, 30 * FitThemeFont, kScreenWidth - 65 * FitThemeFont - 10, 16 * FitThemeFont)];
    positionLab.tag = 103;
    positionLab.font = ThemeFontSmall;
    positionLab.textColor = [UIColor  colorWithHexString:@"#999999"];
    self.positionLab = positionLab;
    [self.contentView addSubview:positionLab];
    
    // 分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.picImage.right, 55 * FitThemeFont - 1, kScreenWidth - self.picImage.right, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    [self.contentView addSubview:lineView];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
//    UILabel *nameLabel = [[UILabel alloc]init];

}
-(UITableViewCell *)setPersonWithDic:(NSDictionary *)dict withDepartmentName:(NSString *)departmentName searchText:(NSString *)searchText{
    NSString *name = @"";
    NSString *place= @"";
     NSString *mobile= @"";
     NSString *headUrl= @"";
     NSString *headMD5= @"";
    if (dict[Table_User_member_name]) {
        name = dict[Table_User_member_name];
    }
    if (dict[Table_User_position_name]) {
        place = dict[Table_User_position_name];
    }
    
    if (dict[Table_User_mobile]) {
        mobile = dict[Table_User_mobile];
    }
    
    if (dict[Table_User_avatar]) {
        headUrl = dict[Table_User_avatar];
    }
    if (dict[Table_User_urlmd5]) {
        headMD5 = dict[Table_User_urlmd5];
    }
    
    return  [self setPersonWithName:name withAccount:mobile withPlace:place withDepartment:departmentName searchText:searchText withHeadViewUrl:headUrl withHeadViewUrlMD5:headMD5];
}
-(UITableViewCell *)setPersonWithName:(NSString *)name  withAccount:(NSString *)account withPlace:(NSString *)place withDepartment:(NSString *)department searchText:(NSString *)searchText withHeadViewUrl:(NSString *)headViewUrlStr withHeadViewUrlMD5:(NSString *)headViewUrlMD5{

//    _contactDic = contactDic;
    //默认样式
    self.picImage.hidden = NO;
    self.nameLab.hidden = NO;
    self.titleLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.positionLab.hidden = YES;
    self.positionLab.hidden = YES;
    NSString *titleLabStr = name;
    self.nameLab.attributedText = [self changeAttrString:titleLabStr text:searchText color:ThemeColor];
    if (place.length >0) {
        self.placeLabel.text = [NSString stringWithFormat:@" | %@",place];
          self.positionLab.hidden = NO;
    }
    /// eagle sessionviewcontrller 里面搜索出来的，名字下面显示部门
    if (department.length>0) {
   
        self.positionLab.attributedText = [self changeAttrString:department text:searchText color:ThemeColor];
         self.positionLab.hidden = NO;
    }

    self.backgroundColor = [UIColor clearColor];

    if (!KCNSSTRING_ISEMPTY(headViewUrlStr) && !KCNSSTRING_ISEMPTY(headViewUrlMD5)) {
#if isHeadRequestUserMd5
        [self.picImage setImageWithURLString:headViewUrlStr urlmd5:headViewUrlMD5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.picImage.size, name,account) withRefreshCached:NO];
#else
        [self.picImage sd_setImageWithURL:[NSURL URLWithString:headViewUrlStr] placeholderImage:ThemeDefaultHead(self.picImage.size, name,account) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
#endif
    }else{
        [self.picImage sd_cancelCurrentImageLoad];
        self.picImage.image = ThemeDefaultHead(self.picImage.size, name,account);
    }
    
    CGSize size = [titleLabStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge, NSFontAttributeName, nil]];
    CGFloat width = size.width > (kScreenWidth - self.nameLab.originX - 10) ? (kScreenWidth - self.nameLab.originX - 10) : size.width;
    self.nameLab.frame = CGRectMake(self.nameLab.originX, self.nameLab.originY, width, self.nameLab.size.height);
    width = (kScreenWidth - self.nameLab.originX - 10) - width;
    self.placeLabel.frame = CGRectMake(self.nameLab.originX + size.width, self.placeLabel.originY, width,  self.placeLabel.height);
    return self;
}
@end
