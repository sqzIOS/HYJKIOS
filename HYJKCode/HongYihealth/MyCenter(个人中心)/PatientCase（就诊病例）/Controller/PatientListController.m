//
//  PatientListController.m
//  sexduoduo
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 dbCode. All rights reserved.
//

#import "PatientListController.h"
#import "PatientCaseController.h"
#import "UserOperation.h"
#import "PatientListCell.h"

@interface PatientListController ()<UITableViewDataSource,UITableViewDelegate,PatientListCellDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArry;


@end

@implementation PatientListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleStr = @"就诊人病例";
    
    [self setTableView];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasPatientChanged"] isEqualToString:@"1"]) {
        [self loadData];
    }
}

- (NSMutableArray *)dataArry
{
    if (_dataArry == nil) {
        _dataArry = [NSMutableArray array];
    }
    return _dataArry;
}

- (void)setTableView
{
    UITableView *tableView = [[UITableView alloc] init];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    CGFloat height = SCREEN_HEIGHT - 64;
    tableView.frame = CGRectMake(0,self.topView.bottom, SCREEN_WIDTH, height);
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    // 添加按钮
    UIButton *addBtn = [[UIButton alloc] init];
    addBtn.frame = CGRectMake(SCREEN_WIDTH - 40, self.topView.bottom - 30,20,20);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"addIcon"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:addBtn];
}

// 加载数据
- (void)loadData
{
    [UserOperation getPatientListSucceed:^(NSArray *caseList) {
        self.dataArry = [NSMutableArray arrayWithArray:caseList];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BINGLI object:nil userInfo:@{@"yitianxie":@"1"}];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"hasPatientChanged"];
        [self.tableView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failed:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArry.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PatientListCell *cell = [PatientListCell cellInTableView:tableView];
    cell.delegate = self;
    cell.model = [self.dataArry objectAtIndex:indexPath.row];
    cell.title = [NSString stringWithFormat:@"病例%zi",indexPath.row + 1];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PatientCaseController *controller = [PatientCaseController controllerWithPatientCaseModel:[self.dataArry objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - PatientListCellDelegate
- (void)patientListCellDidSelect:(PatientListCell *)cell
{
    PatientCaseModel *selectedModel = cell.model;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [UserOperation setDefaultPatientCase:selectedModel.case_id Succeed:^{
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.tableView reloadData];
    } failed:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ShareFunction showToast:@"请检查网络设置"];
    }];
    
}

#pragma mark - 添加
- (void)addBtnClick
{
    PatientCaseModel *model = [[PatientCaseModel alloc] init];
    PatientCaseController *controller = [PatientCaseController controllerWithPatientCaseModel:model];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
