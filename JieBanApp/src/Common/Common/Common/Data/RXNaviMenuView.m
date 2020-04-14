//
//  RXNaviMenuView.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/8/8.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXNaviMenuView.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"

@interface RXNaviMenuView ()
@property(nonatomic,strong)UIView *mainView;
@property(nonatomic,strong)NSArray *titleArray;
@property(nonatomic,strong)NSArray *imageArray;
@end
@implementation RXNaviMenuView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor colorWithRed:0.83f green:0.83f blue:0.83f alpha:1.00f];
        self.backgroundColor=[UIColor clearColor];

    }
    return self;
}

-(void)setFetchTitleArray:(NSArray *(^)(void))fetchTitleArray
{
    _titleArray =fetchTitleArray();
}
-(void)setFetchImageArray:(NSArray *(^)(void))fetchImageArray
{
    _imageArray =fetchImageArray();
    [self CreateLayoutSubviews];
}

-(void)updateSubViewLayout:(CGRect)rect
{
    self.frame=rect;
    self.mainView =[[UIView alloc]init];
    self.mainView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    self.mainView.backgroundColor=[UIColor clearColor];
     [self addSubview:self.mainView];
}

-(void)CreateLayoutSubviews
{
    CGFloat iconWidth = 22*FitThemeFont;
    //创建控件
    if((_titleArray.count>0 &&_imageArray.count>0) && _titleArray.count==_imageArray.count)
    {
        for(int i =0;i<_titleArray.count;i++)
        {
            UIImageView *imgView =[[UIImageView alloc]init];
            UILabel *titleLabel =[[UILabel alloc]init];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            UIButton *subBtn;
            if(i==0)
            {
               subBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0,self.mainView.frame.size.width,49.5*FitThemeFont)];
    
                imgView.frame =CGRectMake(10*FitThemeFont,(subBtn.frame.size.height-iconWidth-7.5*FitThemeFont)/2+7.5*FitThemeFont, iconWidth, iconWidth);
                titleLabel.frame =CGRectMake(imgView.right+10*FitThemeFont, (subBtn.frame.size.height-iconWidth-7.5*FitThemeFont)/2+7.5*FitThemeFont,  self.mainView.frame.size.width-imgView.right+10*FitThemeFont, iconWidth);
                
                [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bg_0%d_noraml",i]] forState:UIControlStateNormal];
                //图片资源不存在
//                [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bomb_box_on_0%d",i]] forState:UIControlStateHighlighted];
//                [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bomb_box_on_0%d",i]] forState:UIControlStateSelected];
                
            }else
            {
                if(i==1 &&_titleArray.count>2)
                {
                   subBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 49.5*FitThemeFont, self.mainView.frame.size.width, 43*FitThemeFont)];
                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bg_0%d_noraml",i]] forState:UIControlStateNormal];
                    //图片资源不存在
//                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bomb_box_on_0%d",i]] forState:UIControlStateHighlighted];
//                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bomb_on_box_0%d",i]] forState:UIControlStateSelected];
                    
                }else if (i==_titleArray.count-1)
                {
                    subBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, ((i-1)*43*FitThemeFont)+49.5*FitThemeFont, self.mainView.frame.size.width, 41.5*FitThemeFont)];
                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:@"bg_02_noraml"] forState:UIControlStateNormal];
                    //图片资源不存在
//                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:@"bomb_box_on_02"] forState:UIControlStateHighlighted];
//                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:@"bomb_box_on_02"] forState:UIControlStateSelected];
                    
                }else
                {
                    subBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, ((i-1)*43*FitThemeFont)+49.5*FitThemeFont, self.mainView.frame.size.width, 43*FitThemeFont)];
                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bg_0%d_noraml",/*i-1*/1]] forState:UIControlStateNormal];
                    //图片资源不存在
//                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bomb_box_on_0%d", 1]] forState:UIControlStateHighlighted];
//                    [subBtn setBackgroundImage:[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"bomb_box_on_0%d", 1]] forState:UIControlStateSelected];
                }
                
                imgView =[[UIImageView alloc]initWithFrame:CGRectMake(10*FitThemeFont, (subBtn.frame.size.height-iconWidth)/2, iconWidth, iconWidth)];
                titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(imgView.right+10*FitThemeFont, (subBtn.frame.size.height-iconWidth)/2,  self.mainView.frame.size.width-imgView.right+10*FitThemeFont, iconWidth)];
                
            }
            subBtn.tag=100+i;
            subBtn.userInteractionEnabled=YES;
           
            [self.mainView addSubview:subBtn];
            
            imgView.tag = 1000+i;
            imgView.image = [[AppModel sharedInstance]imageWithName:_imageArray[i]];
            imgView.backgroundColor=[UIColor clearColor];
            [subBtn addSubview:imgView];
            titleLabel.text = _titleArray[i];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor whiteColor];
            if (isEnLocalization) {
                titleLabel.font =ThemeFontSmall;
            }else{
                titleLabel.font = ThemeFontLarge;
            }
            [subBtn addSubview:titleLabel];
            [subBtn addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

-(void)handleAction:(UIButton *)btn
{
    UIButton *subBtn =(UIButton *)[self viewWithTag:btn.tag];
    
    if(subBtn.selected)
    {
            [subBtn setSelected:NO];
        
            UIImageView *imgView =(UIImageView *)[self.mainView viewWithTag:subBtn.tag*10];
        imgView.image=[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"%@",_titleArray[subBtn.tag-100]]];
     }else
     {
            [subBtn setSelected:YES];
         
            UIImageView *imgView =(UIImageView *)[self viewWithTag:subBtn.tag*10];
            imgView.image=[[AppModel sharedInstance]imageWithName:[NSString stringWithFormat:@"%@_on",_titleArray[subBtn.tag-100]]];
         
//         if (btn.tag != _titleArray.count-1 + 100) {
//             UIImageView *imgView =(UIImageView *)[self viewWithTag:subBtn.tag*10];
//             imgView.image=ThemeImage([NSString stringWithFormat:@"%@_on",_titleArray[subBtn.tag-100])];
//         } else {
//             UIImageView *imgView =(UIImageView *)[self viewWithTag:subBtn.tag*10];
//             imgView.image=ThemeImage([NSString stringWithFormat:@"add_friend_plus_icon_on(1)"/*,_titleArray[subBtn.tag-100]*/]);
//         }
     }
   
    [self dismissModalDialogWithAnimation:YES];
    
    if(self.selectRowAtIndex)
    {
        self.selectRowAtIndex(self,subBtn.tag);
    }

}
-(void)handleGesture:(UITapGestureRecognizer *)tap
{
   // DDLogInfo(@"----------iiii-------%d",tap.view.tag);
    UIView *subView =[self.mainView viewWithTag:tap.view.tag];
    
    if(tap.view.tag==101 && _titleArray.count==2)
    {
        subView.layer.contents =(id)ThemeImage(@"bomb_box_on_02.png").CGImage;
    }else
    {
        NSString *tempStr = [NSString stringWithFormat:@"bomb_box_on_0%d.png",(int)(tap.view.tag-100)];
        subView.layer.contents =(id)ThemeImage(tempStr);
    }
    UIImageView *imgView =(UIImageView *)[self.mainView viewWithTag:tap.view.tag*10];
    NSString *tempStr = [NSString stringWithFormat:@"bomb_box_icon_0%d_on.png",(int)(tap.view.tag*10-1)];
    imgView.image=ThemeImage(tempStr);
    
    if(self.selectRowAtIndex)
    {
        self.selectRowAtIndex(self,tap.view.tag);
    }
    
    [self dismissModalDialogWithAnimation:YES];
}

@end
