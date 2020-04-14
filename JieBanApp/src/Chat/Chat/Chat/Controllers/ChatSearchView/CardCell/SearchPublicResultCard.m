//
//  SearchPublicResultCard.m
//  Chat
//
//  Created by mac on 2017/4/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "SearchPublicResultCard.h"

@implementation SearchPublicResultCard
#define contMaxSize CGSizeMake(kScreenWidth -80, 1000.0f)

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        [self createView];
    }
    
    return self;
}
-(void)createView
{
    self.headImg =[[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 44, 44)];
    self.headImg.layer.cornerRadius=self.headImg.width/2;
    self.headImg.layer.masksToBounds=YES;
    self.headImg.contentMode=UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.headImg];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImg.right + 10, 12, kScreenWidth - self.headImg.right - 10, 20)];
    self.nameLabel.font = ThemeFontLarge;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.nameLabel];
    
    self.introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.originX, self.nameLabel.bottom+3, self.nameLabel.width-10, 30)];
    self.introduceLabel.font =ThemeFontSmall;
    self.introduceLabel.backgroundColor = [UIColor clearColor];
    self.introduceLabel.textColor = [UIColor colorWithRed:0.68f green:0.68f blue:0.68f alpha:1.00f];
    self.introduceLabel.numberOfLines = 2;
    [self.contentView addSubview:self.introduceLabel];
}

-(void)setPublicSearchDic:(NSDictionary *)searchDic cellIndex:(NSIndexPath *)indexPath searchString:(NSString *)searchString
{
    
    if(searchDic)
    {
        self.headImg.image =nil;
        
        
        [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_thum",[searchDic objectForKey:@"head_pic_url"]]] placeholderImage:ThemeImage(@"app_official_account_icon") options:SDWebImageRefreshCached|SDWebImageRetryFailed];
        
        
        NSString *nameString    =[searchDic objectForKey:@"pn_name"];
        // 创建可变属性化字符串
        NSMutableAttributedString *attr_nameString = [[NSMutableAttributedString alloc] initWithString:nameString];
        // 设置颜色
        
        if(KCNSSTRING_ISEMPTY(searchString))
        {
            searchString=@"";
        }
        [attr_nameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.22f green:0.76f blue:0.25f alpha:1.00f] range:[nameString rangeOfString:searchString]];
        [self.nameLabel setAttributedText:attr_nameString];
        //[searchDic objectForKey:@"summary"]
        NSString *content = [searchDic objectForKey:@"summary"];

        CGSize bubbleSize = [[Common sharedInstance] widthForContent:content withSize:contMaxSize withLableFont:ThemeFontSmall.pointSize];
        //如果有一行或者二行的时候,那么高度bubbleSize=19.09*i(i=1,2),所以定于一个参数 当少于40的高度的时候 赋值0.5的高度
        //CGFloat repairHeight =0;
        
        if(bubbleSize.height>30)
        {
            bubbleSize.height=30;
        }
        
        self.introduceLabel.height=bubbleSize.height;
        
        self.introduceLabel.text =content;
    }
}


@end
