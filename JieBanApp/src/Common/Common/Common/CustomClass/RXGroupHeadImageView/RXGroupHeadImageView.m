//
//  RXGroupHeadImageView.m
//  MyHead
//
//  Created by zhouwh on 15/8/27.
//  Copyright (c) 2015年 zhouwh. All rights reserved.
//

#import "RXGroupHeadImageView.h"
#import "RXCustomLayer.h"
#import "GroupHeadMode.h"
#import "UIImage+deal.h"
//#import "UIImageView+WebCache.h"
#import "UIImage+Addtions.h"

#define  isOpen  0
#define  isOpenCache  1

static inline float radians(double degrees) { return degrees * M_PI / 180;}

#define  lineScale  0.8*fitScreenWidth
@implementation RXGroupHeadImageView

{
    NSMutableArray *operationArr;
}
-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if(self)
    {
    }
    
    return self;
}
-(void)createHeaderViewH:(CGFloat)headerWH withImageWH:(CGFloat)imageWH groupId:(NSString *)groupId withMemberArray:(NSArray *)memberArray
{
    self.imgView.image = nil;
    if (!operationArr) {
        operationArr = [NSMutableArray array];
    }
    
    for (id <SDWebImageOperation> operation in operationArr) {
        [operation cancel];
    }
    
    [operationArr removeAllObjects];
    
    //ggh
    NSArray *imageArray = [self getImageArrayWithmemberArray:memberArray HeaderViewH:headerWH withImageWH:imageWH];
    UIImage *image = [self groupIconWithURLArray:imageArray bgColor:[UIColor greenColor]];
    if (!self.imgView) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWH, imageWH)];
    }
    else {
        self.imgView.frame = CGRectMake(0, 0, imageWH, imageWH);
    }
    if (!self.imgView.superview) {
        [self addSubview:self.imgView];
    }
    self.imgView.image = image;
    self.imgView.layer.cornerRadius = 5;
    self.imgView.layer.masksToBounds = YES;
    return;
    
    
    self.layer.sublayers = nil;
    self.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
    //    self.layer.cornerRadius = headerWH/2;
    self.layer.masksToBounds = YES;
    
    switch (memberArray.count) {
        case 1:
        {
            
            [self loadImageView1Layer:headerWH withImageWH:imageWH withGroupId:groupId withArray:(NSArray *)memberArray];
        }
            break;
        case 2:
        {
            [self loadImageView2Layer:headerWH withImageWH:imageWH withGroupId:groupId withArray:(NSArray *)memberArray];
        }
            break;
        case 3:
        {
            [self loadImageView3Layer:headerWH withImageWH:imageWH withGroupId:groupId withArray:(NSArray *)memberArray];
        }
            break;
        case 4:
        {
            [self loadImageView4Layer:headerWH withImageWH:imageWH withGroupId:groupId withArray:(NSArray *)memberArray];
        }
            break;
        case 5:
        {
            [self loadImageView5Layer:headerWH withImageWH:imageWH withGroupId:groupId withArray:(NSArray *)memberArray];
        }
            break;
            
        default:
            break;
    }
}

//ggh,群成员数组转化 为头像image数组
-(NSArray*)getImageArrayWithmemberArray:(NSArray*)memberArray HeaderViewH:(CGFloat)headerWH withImageWH:(CGFloat)imageWH{
    
    CGFloat diameter = headerWH;//直径
    CGFloat r = diameter / 2;//半径
    CGFloat scale = diameter / imageWH;//比例
    
    NSMutableArray *ImageArray = [[NSMutableArray alloc] init];
    for (KitGroupMemberInfoData *memberData in memberArray) {
        
#if isOpen
        NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
        memberData.memberName = info[Table_User_member_name];
        memberData.headUrl = info[Table_User_avatar];
#else
#endif
        UIImage *pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
#if isOpenCache
        pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
        if (pathImage) {
            pathImage = [pathImage imageWithCornerRadius:5];
        }
#else
        NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
        
        pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
#endif
        
        UIImage *oldimage = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.memberName?memberData.memberName:memberData.memberId,memberData.memberId);
        
        [ImageArray addObject:oldimage];
    }
    
    
    return ImageArray;
}


//第二种办法 尝试一下

//count 1
-(void)loadImageView1Layer:(CGFloat)viewWH withImageWH:(CGFloat)imageWH withGroupId:(NSString *)groupId withArray:(NSArray *)memberArray
{
    // NSArray *memArray = [KitGroupMemberInfoData getMemberInfoWithGroupId:groupId withCount:1];
    
    CGFloat diameter = viewWH;//直径
    CGFloat r = diameter / 2;//半径
    CGFloat scale = diameter / imageWH;//比例
    KitGroupMemberInfoData *memberData =memberArray[0];
#if isOpen
    NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
    memberData.memberName = info[Table_User_member_name];
    memberData.headUrl = info[Table_User_avatar];
#else
#endif
    
    // 获取沙盒目录
    // NSString *imagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]];
    UIImage *pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
    //[[UIImage alloc]initWithContentsOfFile:imagePath];
    
#if isOpenCache
    pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
#else
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    
    pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
#endif
    
    UIImage *oldimage = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.memberName?memberData.memberName:memberData.memberId,memberData.memberId);
    
    CGSize imageSize = oldimage.size;
    CGFloat correctScale = viewWH / imageSize.height;
    
    RXCustomLayer *layer0 =[RXCustomLayer createWithImage:oldimage scale:scale * correctScale degrees:diameter isClip:YES];
    
    layer0.frame =[RXGroupHeadImageView getRect:CGPointMake(r, r) size:CGSizeMake(diameter, diameter)];
    [self.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    [self loadImageLayer:layer0 withViewWH:viewWH scale:scale degrees:diameter correctScale:correctScale isClip:YES withPathImage:pathImage withMemberId:memberData.memberId withMemberUrl:memberData.headUrl withMd5:memberData.headMd5 withLoaction:@"11"];
    
}
//count 2
-(void)loadImageView2Layer:(CGFloat)viewWH withImageWH:(CGFloat)imageWH withGroupId:(NSString *)groupId withArray:(NSArray *)memberArray
{
    
    //wwl 修改头像显示半径与坐标
    CGFloat diameter = viewWH/(1+cos(radians(25)));
    CGFloat r = viewWH/2.0-diameter*cos(radians(25))/sqrtf(2)/2.0;
    CGFloat scale = diameter / imageWH;
    
    // CGFloat originNewX =(diameter - hypot(diameter/2, diameter/2))/2;
    KitGroupMemberInfoData *memberData =memberArray[0];
#if isOpen
    NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
    if (info) {
        memberData.memberName = info[Table_User_member_name];
        memberData.headUrl = info[Table_User_avatar];
    }else{
        memberData.memberName = memberData.memberName;
    }
#else
#endif
    
    
    // 获取沙盒目录
    UIImage *pathImage =nil;
    
#if isOpenCache
    pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
#else
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
#endif
    UIImage *oldimage = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.userName?memberData.userName:memberData.memberId,memberData.memberId);
    
    CGSize imageSize = oldimage.size;
    CGFloat correctScale = viewWH / imageSize.height;
    
    RXCustomLayer *layer =[RXCustomLayer createWithImage:oldimage scale:scale * correctScale degrees:0 isClip:NO];
    layer.frame =[RXGroupHeadImageView getRect:CGPointMake(r, r) size:CGSizeMake(diameter, diameter)];
    [self.layer addSublayer:layer];
    [layer setNeedsDisplay];
    
    [self loadImageLayer:layer withViewWH:viewWH scale:scale degrees:0 correctScale:correctScale isClip:NO withPathImage:pathImage withMemberId:memberData.memberId withMemberUrl:memberData.headUrl withMd5:memberData.headMd5 withLoaction:@"21"];
    
    
    KitGroupMemberInfoData *memberData1 =memberArray[1];
#if isOpen
    NSDictionary *info1 = [[Common sharedInstance].componentDelegate getDicWithId:memberData1.memberId withType:0];
    memberData1.memberName = info1[Table_User_member_name];
    memberData1.headUrl = info1[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage1 =nil;
    
#if isOpenCache
    pathImage1 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData1.headUrl];
#else
    pathImage1 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData1.memberId]]];
#endif
    oldimage =pathImage1?pathImage1: ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData1.userName?memberData1.userName:memberData1.memberId,memberData1.memberId);
    imageSize = oldimage.size;
    correctScale = viewWH / imageSize.height;
    
    RXCustomLayer *layer1 =[RXCustomLayer createWithImage:oldimage scale:scale * correctScale degrees:180 - 45 isClip:YES];
    
    layer1.frame =[RXGroupHeadImageView getRect:CGPointMake(viewWH-r, viewWH-r) size:CGSizeMake(diameter, diameter)];
    
    [self.layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    [self loadImageLayer:layer1 withViewWH:viewWH scale:scale degrees:135 correctScale:correctScale isClip:YES withPathImage:pathImage1 withMemberId:memberData1.memberId withMemberUrl:memberData1.headUrl withMd5:memberData1.headMd5 withLoaction:@"22"];
    
    
}
//count 3
-(void)loadImageView3Layer:(CGFloat)viewWH withImageWH:(CGFloat)imageWH withGroupId:(NSString *)groupId withArray:(NSArray *)memberArray
{
    
    //wwl 修改头像显示半径与坐标
    CGFloat diameter = viewWH/2.0*0.98;
    CGFloat scale = diameter / imageWH;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, viewWH, viewWH);
    KitGroupMemberInfoData *memberData =memberArray [0];
#if isOpen
    NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
    memberData.memberName = info[Table_User_member_name];
    memberData.headUrl = info[Table_User_avatar];
#else
#endif
    
    // 获取沙盒目录
    UIImage *pathImage =nil;
    
#if isOpenCache
    pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
#else
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    
    pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
#endif
    UIImage *oldimage = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.userName?memberData.userName:memberData.memberId,memberData.memberId);
    CGSize imageSize = oldimage.size;
    CGFloat correctScale = viewWH / imageSize.height;
    CGPoint center0 = CGPointMake(viewWH/2.0, diameter / 2.0);
    
    RXCustomLayer *layer0 =[RXCustomLayer createWithImage:oldimage scale:scale * correctScale degrees:30 isClip:YES];
    layer0.frame =[RXGroupHeadImageView getRect:center0 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    [self loadImageLayer:layer0 withViewWH:viewWH scale:scale degrees:30 correctScale:correctScale isClip:YES withPathImage:pathImage withMemberId:memberData.memberId withMemberUrl:memberData.headUrl withMd5:memberData.headMd5 withLoaction:@"31"];
    
    KitGroupMemberInfoData *memberData1 =memberArray [1];
#if isOpen
    NSDictionary *info1 = [[Common sharedInstance].componentDelegate getDicWithId:memberData1.memberId withType:0];
    memberData1.memberName = info1[Table_User_member_name];
    memberData1.headUrl = info1[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage1 =nil;
    
#if isOpenCache
    pathImage1 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData1.headUrl];
#else
    pathImage1 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData1.memberId]]];
#endif
    
    oldimage = pathImage1?pathImage1:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData1.userName?memberData1.userName:memberData1.memberId,memberData1.memberId);
    imageSize = oldimage.size;
    correctScale = viewWH / imageSize.height;
    
    CGPoint center1 = CGPointMake(viewWH/2.0 - viewWH/2.0 * cos(radians(30)) +diameter/2*cos(radians(30)), viewWH/2.0  + viewWH/2.0 * sin(radians(30))-diameter/2.0 * sin(radians(30)));
    
    RXCustomLayer *layer1 =[RXCustomLayer createWithImage:oldimage scale:scale * correctScale degrees:270 isClip:YES];
    layer1.frame =[RXGroupHeadImageView getRect:center1 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    [self loadImageLayer:layer1 withViewWH:viewWH scale:scale degrees:270 correctScale:correctScale isClip:YES withPathImage:pathImage1 withMemberId:memberData1.memberId withMemberUrl:memberData1.headUrl withMd5:memberData1.headMd5 withLoaction:@"32"];
    
    
    KitGroupMemberInfoData *memberData2 =memberArray [2];
#if isOpen
    NSDictionary *info2 = [[Common sharedInstance].componentDelegate getDicWithId:memberData2.memberId withType:0];
    memberData2.memberName = info2[Table_User_member_name];
    memberData2.headUrl = info2[Table_User_avatar];
#else
    
#endif
    UIImage *pathImage2 =nil;
    
#if isOpenCache
    pathImage2 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData2.headUrl];
#else
    pathImage2 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData2.memberId]]];
#endif
    
    oldimage = pathImage2?pathImage2:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData2.userName?memberData2.userName:memberData2.memberId,memberData2.memberId);
    imageSize = oldimage.size;
    correctScale = viewWH / imageSize.height;
    
    CGPoint center2 = CGPointMake(viewWH/2.0 + viewWH/2.0 * cos(radians(30)) -diameter/2*cos(radians(30)), center1.y);
    
    RXCustomLayer *layer2 =[RXCustomLayer createWithImage:oldimage scale:scale * correctScale degrees:150 isClip:YES];
    layer2.frame =[RXGroupHeadImageView getRect:center2 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer2];
    [layer2 setNeedsDisplay];
    
    [self loadImageLayer:layer2 withViewWH:viewWH scale:scale degrees:150 correctScale:correctScale isClip:YES withPathImage:pathImage2 withMemberId:memberData2.memberId withMemberUrl:memberData2.headUrl withMd5:memberData2.headMd5 withLoaction:@"33"];
    

    CGRect f = layer.frame;
    f.origin.y = (self.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [self.layer addSublayer:layer];
    
}
//count 4
-(void)loadImageView4Layer:(CGFloat)viewWH withImageWH:(CGFloat)imageWH withGroupId:(NSString *)groupId withArray:(NSArray *)memberArray
{
      
    //wwl 修改头像显示半径与坐标
    CGFloat diameter = viewWH/2.0 *0.9;
    CGFloat r = viewWH/2.0-diameter / 2.0*cos(radians(25));
    CGFloat scale = diameter / imageWH;
    
    KitGroupMemberInfoData *memberData =memberArray [0];
#if isOpen
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    
    NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
    memberData.memberName = info[Table_User_member_name];
    memberData.headUrl = info[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage =nil;
    
#if isOpenCache
    pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
#else
    pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
#endif
    UIImage *image = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.userName?memberData.userName:memberData.memberId,memberData.memberId);
    CGSize imageSize = image.size;
    CGFloat correctScale = viewWH / imageSize.height;
    CGPoint center0 = CGPointMake(r, r);
    
    RXCustomLayer *layer0 =[RXCustomLayer createWithImage:image scale:scale * correctScale degrees:0 isClip:YES];
    layer0.frame =[RXGroupHeadImageView getRect:center0 size:CGSizeMake(diameter, diameter)];
    [self.layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    [self loadImageLayer:layer0 withViewWH:viewWH scale:scale degrees:0 correctScale:correctScale isClip:YES withPathImage:pathImage withMemberId:memberData.memberId withMemberUrl:memberData.headUrl withMd5:memberData.headMd5 withLoaction:@"41"];
    
    KitGroupMemberInfoData *memberData1 =memberArray [1];
#if isOpen
    NSDictionary *info1 = [[Common sharedInstance].componentDelegate getDicWithId:memberData1.memberId withType:0];
    memberData1.memberName = info1[Table_User_member_name];
    memberData1.headUrl = info1[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage1 =nil;
    
#if isOpenCache
    pathImage1 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData1.headUrl];
#else
    pathImage1 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData1.memberId]]];
#endif
    image = pathImage1?pathImage1:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData1.userName?memberData1.userName:memberData1.memberId,memberData1.memberId);
    imageSize = image.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center1 = CGPointMake(center0.x, viewWH/2.0+diameter / 2.0*cos(radians(25)));
    
    RXCustomLayer *layer1 =[RXCustomLayer createWithImage:image scale:scale * correctScale degrees:270 isClip:YES];
    layer1.frame =[RXGroupHeadImageView getRect:center1 size:CGSizeMake(diameter, diameter)];
    [self.layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    [self loadImageLayer:layer1 withViewWH:viewWH scale:scale degrees:270 correctScale:correctScale isClip:YES withPathImage:pathImage1 withMemberId:memberData1.memberId withMemberUrl:memberData1.headUrl withMd5:memberData1.headMd5 withLoaction:@"42"];
    
    
    KitGroupMemberInfoData *memberData2 =memberArray [2];
#if isOpen
    NSDictionary *info2 = [[Common sharedInstance].componentDelegate getDicWithId:memberData2.memberId withType:0];
    memberData2.memberName = info2[Table_User_member_name];
    memberData2.headUrl = info2[Table_User_avatar];
#else
#endif
    UIImage *pathImage2 =nil;
    
#if isOpenCache
    pathImage2 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData2.headUrl];
#else
    pathImage2 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData2.memberId]]];
#endif
    image = pathImage2?pathImage2:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData2.userName?memberData2.userName:memberData2.memberId,memberData2.memberId);
    imageSize = image.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center2 =  CGPointMake(viewWH/2.0+diameter / 2.0*cos(radians(25)), center1.y);
    
    RXCustomLayer *layer2 =[RXCustomLayer createWithImage:image scale:scale * correctScale degrees:180 isClip:YES];
    layer2.frame =[RXGroupHeadImageView getRect:center2 size:CGSizeMake(diameter, diameter)];
    [self.layer addSublayer:layer2];
    [layer2 setNeedsDisplay];
    
    
    [self loadImageLayer:layer2 withViewWH:viewWH scale:scale degrees:180 correctScale:correctScale isClip:YES withPathImage:pathImage2 withMemberId:memberData2.memberId withMemberUrl:memberData2.headUrl withMd5:memberData2.headMd5 withLoaction:@"43"];
    
    
    KitGroupMemberInfoData *memberData3 =memberArray [3];
#if isOpen
    NSDictionary *info3 = [[Common sharedInstance].componentDelegate getDicWithId:memberData3.memberId withType:0];
    memberData3.memberName = info3[Table_User_member_name];
    memberData3.headUrl = info3[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage3 =nil;
    
#if isOpenCache
    pathImage3 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData3.headUrl];
#else
    pathImage3 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData3.memberId]]];
#endif
    image = pathImage3?pathImage3:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData3.userName?memberData3.userName:memberData3.memberId,memberData3.memberId);
    imageSize = image.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center3 =  CGPointMake(viewWH/2.0+diameter / 2.0*cos(radians(25)), center0.y);
    
    RXCustomLayer *layer3 =[RXCustomLayer createWithImage:image scale:scale * correctScale degrees:90 isClip:YES];
    layer3.frame =[RXGroupHeadImageView getRect:center3 size:CGSizeMake(diameter, diameter)];
    [self.layer addSublayer:layer3];
    [layer3 setNeedsDisplay];
    
    [self loadImageLayer:layer3 withViewWH:viewWH scale:scale degrees:90 correctScale:correctScale isClip:YES withPathImage:pathImage3 withMemberId:memberData3.memberId withMemberUrl:memberData3.headUrl withMd5:memberData3.headMd5 withLoaction:@"44"];
    
    
}
//count 5
-(void)loadImageView5Layer:(CGFloat)viewWH withImageWH:(CGFloat)imageWH withGroupId:(NSString *)groupId withArray:(NSArray *)memberArray
{
    //wwl 修改头像显示半径与坐标
    CGFloat r = viewWH / 2 / (2 * sin(radians(54)) + 1);
    CGFloat diameter = r * 2;
    CGFloat scale = diameter / imageWH;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0,viewWH, r / tan(radians(36)) + r / sin(radians(36)) + diameter);
    
    
    KitGroupMemberInfoData *memberData =memberArray [0];
#if isOpen
    DDLogInfo(@"......查询之前的时间..");
    NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
    DDLogInfo(@"......查询之后的时间..");
    memberData.memberName = info[Table_User_member_name];
    memberData.headUrl = info[Table_User_avatar];
#else
#endif
    
    
    UIImage *pathImage =nil;
    
#if isOpenCache
    pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
#else
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    
    pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
#endif
    
    UIImage *oldImage = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.userName?memberData.userName:memberData.memberId,memberData.memberId);
    CGSize imageSize = oldImage.size;
    CGFloat correctScale = viewWH / imageSize.height;
    CGPoint center0 = CGPointMake(viewWH / 2, r);
    
    RXCustomLayer *layer0 =[RXCustomLayer createWithImage:oldImage scale:scale * correctScale degrees:54 isClip:YES];
    layer0.frame =[RXGroupHeadImageView getRect:center0 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer0];
    [layer0 setNeedsDisplay];
    
    [self loadImageLayer:layer0 withViewWH:viewWH scale:scale degrees:54 correctScale:correctScale isClip:YES withPathImage:pathImage withMemberId:memberData.memberId withMemberUrl:memberData.headUrl withMd5:memberData.headMd5 withLoaction:@"51"];
    
    KitGroupMemberInfoData *memberData1=memberArray [1];
#if isOpen
    NSDictionary *info1 = [[Common sharedInstance].componentDelegate getDicWithId:memberData1.memberId withType:0];
    memberData1.memberName = info1[Table_User_member_name];
    memberData1.headUrl = info1[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage1 =nil;
    
#if isOpenCache
    pathImage1 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData1.headUrl];
#else
    pathImage1 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData1.memberId]]];
#endif
    oldImage = pathImage1?pathImage1:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData1.userName?memberData1.userName:memberData1.memberId,memberData1.memberId);
    imageSize = oldImage.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center1 = CGPointMake(center0.x - diameter * cos(radians(25)) * sin(radians(54)), center0.y + diameter * cos(radians(25)) * cos(radians(54)));
    
    RXCustomLayer *layer1 =[RXCustomLayer createWithImage:oldImage scale:scale * correctScale degrees:270+72 isClip:YES];
    layer1.frame =[RXGroupHeadImageView getRect:center1 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer1];
    [layer1 setNeedsDisplay];
    
    [self loadImageLayer:layer1 withViewWH:viewWH scale:scale degrees:342 correctScale:correctScale isClip:YES withPathImage:pathImage1 withMemberId:memberData1.memberId withMemberUrl:memberData1.headUrl withMd5:memberData1.headMd5 withLoaction:@"52"];
    
    KitGroupMemberInfoData *memberData2=memberArray [2];
#if isOpen
    NSDictionary *info2 = [[Common sharedInstance].componentDelegate getDicWithId:memberData2.memberId withType:0];
    memberData2.memberName = info2[Table_User_member_name];
    memberData2.headUrl = info2[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage2 =nil;
    
#if isOpenCache
    pathImage2 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData2.headUrl];
#else
    pathImage2 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData2.memberId]]];
#endif
    
    oldImage = pathImage2?pathImage2:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData2.userName?memberData2.userName:memberData2.memberId,memberData2.memberId);
    imageSize = oldImage.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center2 = CGPointMake(center1.x + diameter * cos(radians(25)) * cos(radians(72)), center1.y + diameter * cos(radians(25)) * sin(radians(72)));
    
    RXCustomLayer *layer2 =[RXCustomLayer createWithImage:oldImage scale:scale * correctScale degrees:270 isClip:YES];
    layer2.frame =[RXGroupHeadImageView getRect:center2 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer2];
    [layer2 setNeedsDisplay];
    
    [self loadImageLayer:layer2 withViewWH:viewWH scale:scale degrees:270 correctScale:correctScale isClip:YES withPathImage:pathImage2 withMemberId:memberData2.memberId withMemberUrl:memberData2.headUrl withMd5:memberData2.headMd5 withLoaction:@"53"];
    
    KitGroupMemberInfoData *memberData3=memberArray [3];
#if isOpen
    NSDictionary *info3 = [[Common sharedInstance].componentDelegate getDicWithId:memberData3.memberId withType:0];
    memberData3.memberName = info3[Table_User_member_name];
    memberData3.headUrl = info3[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage3 =nil;
    
#if isOpenCache
    pathImage3 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData3.headUrl];
#else
    pathImage3 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData3.memberId]]];
#endif
    oldImage = pathImage3?pathImage3:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData3.userName?memberData3.userName:memberData3.memberId,memberData3.memberId);
    
    imageSize = oldImage.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center3 = CGPointMake(center2.x + diameter * cos(radians(25)), center2.y);
    
    RXCustomLayer *layer3 =[RXCustomLayer createWithImage:oldImage scale:scale * correctScale degrees:180 + 18 isClip:YES];
    layer3.frame =[RXGroupHeadImageView getRect:center3 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer3];
    [layer3 setNeedsDisplay];
    
    [self loadImageLayer:layer3 withViewWH:viewWH scale:scale degrees:198 correctScale:correctScale isClip:YES withPathImage:pathImage3 withMemberId:memberData3.memberId withMemberUrl:memberData3.headUrl withMd5:memberData3.headMd5 withLoaction:@"54"];
    
    KitGroupMemberInfoData *memberData4=memberArray[4];
#if isOpen
    NSDictionary *info4 = [[Common sharedInstance].componentDelegate getDicWithId:memberData4.memberId withType:0];
    memberData4.memberName = info4[Table_User_member_name];
    memberData4.headUrl = info4[Table_User_avatar];
#else
#endif
    
    UIImage *pathImage4 =nil;
    
#if isOpenCache
    pathImage4 =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData4.headUrl];
#else
    pathImage4 = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData4.memberId]]];
#endif
    
    
    oldImage = pathImage4?pathImage4:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData4.userName?memberData4.userName:memberData4.memberId,memberData4.memberId);
    imageSize = oldImage.size;
    correctScale = viewWH / imageSize.height;
    CGPoint center4 = CGPointMake(center3.x + diameter * cos(radians(25)) * cos(radians(72)), center3.y - diameter * cos(radians(25)) * sin(radians(72)));
    
    RXCustomLayer *layer4 =[RXCustomLayer createWithImage:oldImage scale:scale * correctScale degrees:90 + 36 isClip:YES];
    layer4.frame =[RXGroupHeadImageView getRect:center4 size:CGSizeMake(diameter, diameter)];
    [layer addSublayer:layer4];
    [layer4 setNeedsDisplay];
    
    [self loadImageLayer:layer4 withViewWH:viewWH scale:scale degrees:126 correctScale:correctScale isClip:YES withPathImage:pathImage4 withMemberId:memberData4.memberId withMemberUrl:memberData4.headUrl withMd5:memberData4.headMd5 withLoaction:@"55"];
    
    
    CGRect f = layer.frame;
    f.origin.y = (self.frame.size.height - f.size.height) / 2;
    layer.frame = f;
    [self.layer addSublayer:layer];
}

/**
 * 截图
 * memberId 成员Id
 * curlayer 截图的对象
 * location 位置
 **/
-(BOOL)getImageFromViewMemberId:(NSString *)memberId withImage:(UIImage *)loadImage withLoaction:(NSString *)location{
    //    UIImageView *imgView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    //    imgView.image =loadImage;
    //    imgView.contentMode
    //    UIGraphicsBeginImageContextWithOptions(imgView.frame.size, NO, 0);
    //
    //    //1.获取bitmap上下文
    //    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    // CGContextAddEllipseInRect(ctx, curlayer.frame);
    //    [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    //  CGContextStrokePath(ctx);
    //    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    // UIGraphicsEndImageContext();
    
    //保存图像
    
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    // 获取沙盒目录
    NSString *imagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberId]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if(isDirExist)
    {
        // 将图片写入文件
        if ([UIImagePNGRepresentation(loadImage) writeToFile:imagePath atomically:NO]) {
            return YES;
        }
        
    }else
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir) {
            return NO;
        }
        // 将图片写入文件
        if ([UIImagePNGRepresentation(loadImage) writeToFile:imagePath atomically:NO]) {
            return YES;
        }
    }
    
    return NO;
    
}

-(BOOL)getImageFromViewMemberId:(NSString *)memberId withLayer:(RXCustomLayer *)curlayer withLoaction:(NSString *)location{
    
    // UIGraphicsBeginImageContext(curlayer.frame.size);
    
    UIGraphicsBeginImageContextWithOptions(curlayer.frame.size, NO, 0);
    
    //1.获取bitmap上下文
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextAddEllipseInRect(ctx, curlayer.frame);
    [curlayer renderInContext:UIGraphicsGetCurrentContext()];
    //  CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // UIGraphicsEndImageContext();
    
    //保存图像
    
    NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
    // 获取沙盒目录
    NSString *imagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@%@.png",memberId,location]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if(isDirExist)
    {
        // 将图片写入文件
        if ([UIImagePNGRepresentation(image) writeToFile:imagePath atomically:NO]) {
            return YES;
        }
        
    }else
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir) {
            return NO;
        }
        // 将图片写入文件
        if ([UIImagePNGRepresentation(image) writeToFile:imagePath atomically:NO]) {
            return YES;
        }
    }
    
    
    return NO;
}

//画头像
-(UIImage *)groupIconWithURLArray:(NSArray *)imageArray bgColor:(UIColor *)bgColor;
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage groupIconWith:imageArray bgColor:[UIColor colorWithHexString:@"f2f3f4"]];
    
    return imageView.image;
}




/**
 * layer 要画的对象
 * viewWh size
 * scale 比例
 * degrees 角度
 * correctScale 当前缩放的大小
 * isClip 是否裁剪
 * pathImage 本地是否有图片
 * memberId 成员Id
 * memberUrl 成员url
 * loaction 位置 由头像个数和图片所在的第几个位置组成 比如 头像有5个 在第二个位置 那么 count = 52
 **/


-(void)loadImageLayer:(RXCustomLayer *)layer withViewWH:(CGFloat)viewWh scale:(CGFloat)scale degrees:(NSInteger)degrees correctScale:(CGFloat)correctScale isClip:(BOOL)isClip withPathImage:(UIImage *)pathImage withMemberId:(NSString *)memberId withMemberUrl:(NSString *)memberUrl withMd5:(NSString *)urlMd5 withLoaction:(NSString*)loaction;
{
    __weak typeof (self)weak_self = self;
    __weak typeof (RXCustomLayer *)weak_layer = layer;
    
    if(viewWh<40*[self isIphone6PlusProPortionHeight])
    {
        viewWh =40*[self isIphone6PlusProPortionHeight];
    }
    if(KCNSSTRING_ISEMPTY(memberUrl) || KCNSSTRING_ISEMPTY(urlMd5))
    {
        return;
    }
    
    NSString *cacheMd5 =   [[NSUserDefaults standardUserDefaults]objectForKey:memberUrl];
    SDWebImageOptions options =SDWebImageRefreshCached;
    if([cacheMd5 isEqualToString:urlMd5])
    {
        options = 0;
    }
    
    id<SDWebImageOperation> operation = [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:memberUrl] options:options progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!weak_self) return;
        //|| !pathImage
        if(cacheType ==SDImageCacheTypeNone )
        {
            if (image) {
                
                DDLogInfo(@"走了几次了..........");
                [[NSUserDefaults standardUserDefaults]setObject:urlMd5 forKey:memberUrl];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [weak_layer updateWithImage:image scale:scale * correctScale degrees:degrees isClip:isClip];
                [weak_layer setNeedsDisplay];
                
                if(cacheType ==SDImageCacheTypeNone || !pathImage)
                {
                    if (image) {
                        [weak_self getImageFromViewMemberId:memberId withImage:image withLoaction:loaction];
                        
                        [weak_layer updateWithImage:image scale:scale * correctScale degrees:degrees isClip:isClip];
                        [weak_layer setNeedsDisplay];
                    }
                }
            }
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [operationArr addObject:operation];
    });
}

+ (CGRect)getRect:(CGPoint)center size:(CGSize)size
{
    return CGRectMake(center.x - size.width / 2.0, center.y - size.height / 2.0, size.width, size.height);
}

-(CGFloat)isIphone6PlusProPortionHeight
{
    //    if(iPhone6plus)
    //    {
    //        return kScreenHeight/667;
    //    }
    
    return iPhone6FitScreenHeight;
}

@end
