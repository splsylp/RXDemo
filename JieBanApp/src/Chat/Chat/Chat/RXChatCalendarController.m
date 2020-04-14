//
//  RXChatCalendarController.m
//  Chat
//
//  Created by 高源 on 2019/5/20.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXChatCalendarController.h"
#import "ChatViewController.h"

@interface RXChatCalendarController ()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak , nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSCalendar *lunarCalendar;

/** allmessage */
@property(nonatomic,strong)NSArray *allMessage;

/** allSet */
@property(nonatomic,strong)NSMutableSet *allSet;

@end

@implementation RXChatCalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = languageStringWithKey(@"按日期查找");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self handleData];
    [self createCalendar];
    // Do any additional setup after loading the view.
}

- (void)createCalendar {
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectZero];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.pagingEnabled = NO; // important
    calendar.allowsMultipleSelection = YES;
    calendar.firstWeekday = 2;
    calendar.appearance.weekdayTextColor = [UIColor colorWithHexString:@"878787"];
    calendar.appearance.headerTitleColor = [UIColor colorWithHexString:@"BBBBBB"];
    calendar.appearance.selectionColor = ThemeColor;
    calendar.appearance.titleSelectionColor = [UIColor whiteColor];
    calendar.appearance.subtitleSelectionColor = [UIColor whiteColor];
    calendar.appearance.todayColor = ThemeColor;
    calendar.appearance.subtitleTodayColor = [UIColor blackColor];
    
    calendar.appearance.titleFont = [UIFont systemFontOfSize:16];
    calendar.appearance.weekdayFont = [UIFont systemFontOfSize:12];
    calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    calendar.placeholderType = FSCalendarPlaceholderTypeNone;//定义这个枚举，可以让只显示当前月份的日期
    
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.top.mas_offset(kTotalBarHeight);
    }];
    
    if (isEnLocalization) {
        calendar.locale =  [NSLocale localeWithLocaleIdentifier:@"en"];
    }else {
        calendar.locale =  [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    }
    
    _lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    _lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    
}

#pragma mark  - 处理数据
- (void)handleData {
    NSArray *allMessage = [[KitMsgData sharedInstance]  getAllMessageWithSessionId:self.data];
    self.allMessage = allMessage;
    NSMutableSet *set = [NSMutableSet set];
    for (ECMessage *message in allMessage) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp.longLongValue/1000];
        [set addObject:[NSDate getStringFromDate:date dateFormatter:@"yyyy-MM-dd"]];
    }
    self.allSet = set;
}

#pragma mark  - delegate
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    if (self.allMessage.count>0) {
        ECMessage *message = self.allMessage.firstObject;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp.longLongValue/1000];
        return date;
    }else {
        return NSDate.date;
    }
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    if (self.allMessage.count>0) {
        ECMessage *message = self.allMessage.lastObject;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp.longLongValue/1000];
        return date;
    }else {
        return NSDate.date;
    }
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSString *time = [NSDate getStringFromDate:date dateFormatter:@"yyyy-MM-dd"];
    return [self.allSet containsObject:time];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    return YES;
}

- (nullable NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date {
    NSString *time = [NSDate getStringFromDate:date dateFormatter:@"yyyy-MM-dd"];
    if ([time isEqualToString:[NSDate getStringFromDate:NSDate.date dateFormatter:@"yyyy-MM-dd"]]) {
        return languageStringWithKey(@"今天");
    }else {
        return nil;
    }
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    
    NSString *time = [NSDate getStringFromDate:date dateFormatter:@"yyyy-MM-dd"];
    
    if ([self.allSet containsObject:time]) {
        if([time isEqualToString:[NSDate getStringFromDate:NSDate.date dateFormatter:@"yyyy-MM-dd"]]) {
            return [UIColor blackColor];
        }else {
            return [UIColor blackColor];
        }
    }
    return [UIColor colorWithHexString:@"BBBBBB"];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSArray *arr = [[KitMsgData sharedInstance] getMessagesBySessionId:self.data startTime:date endTime:NSDate.date];
    if (arr.count > 0) {
        ECMessage *message = arr.lastObject;
        //聊天界面入口
        ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:message.sessionId andRecodMessage:message];
        chatVC.dataSearchFrom = @{@"fromePage":@"searchDetail"};
        [self pushViewController:chatVC];
    }
    calendar.appearance.todayColor = [UIColor whiteColor];

    NSArray *arrDate = calendar.selectedDates;
    for (int i = 0; i<arrDate.count; i++) {
        [calendar deselectDate:arrDate[i]];
    }

    [calendar selectDate:date];
}


@end
