//
//  SHPaperTableView.h
//  sexduoduo
//
//  Created by showm on 15/9/29.
//  Copyright (c) 2015年 dbCode. All rights reserved.
//  论文服务 左边tableView

#import <UIKit/UIKit.h>

@interface SHPaperTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
/**
 
 *  表视图数据
 */
@property (strong, nonatomic) NSMutableArray *tvData;
@property (strong, nonatomic) UIViewController *mainVC;
@property (assign, nonatomic) NSInteger selectIndex;
/**
 *  初始化
 */
- (id)initWithTableViewWithFrame:(CGRect)frame withVC:(UIViewController*)VC;

@end