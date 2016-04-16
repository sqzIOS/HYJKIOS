//
//  MedicalDemandController.m
//  
//
//  Created by wenzhizheng on 15/12/31.
//
//

#import "MedicalDemandController.h"
#import "MedicalSwitch.h"
#import "ShareFunction.h"
#import "UIView+Extend.h"
#import "MedicalFirstController.h"
#import "MedicalSecondController.h"

@interface MedicalDemandController () <MedicalSwitchDeletage>

@property (nonatomic,weak) UIView *topView;
@property (nonatomic,weak) UIView *contentView;

@property (nonatomic,strong) MedicalFirstController *firstController;
@property (nonatomic,strong) MedicalSecondController *secondController;


@end

@implementation MedicalDemandController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTopView];
    
    [self setContent];
    
    [self setUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.firstController.tableView) {
        [self.firstController.tableView reloadData];
    }
    if (self.secondController.tableView) {
        [self.secondController.tableView reloadData];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"modelDataChanged" object:nil];
}

#pragma mark - 初始化
- (void)setUp
{
    [self.contentView addSubview:self.firstController.tableView];
}

#pragma mark - 创建内容区域
- (void)setContent
{
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, self.topView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    [self.view addSubview:contentView];
    self.contentView = contentView;
}



#pragma mark - 创建topView
- (void)setTopView
{
    CGFloat frameY = 0;
    if (!IOS7) {
        frameY -= 20;
    }
    CGRect topViewFrame = CGRectMake(0, frameY, SCREEN_WIDTH, 64);
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = AppColor;
    topView.frame = topViewFrame;
    self.topView = topView;
    [self.view addSubview:topView];
    
    MedicalSwitch *medicalSiwtch = [MedicalSwitch medicalSwitch];
    [self.view addSubview:medicalSiwtch];
    medicalSiwtch.delegete = self;
    CGPoint center = topView.center;
    center.y = topView.height - 20;
    medicalSiwtch.center = center;
    [topView addSubview:medicalSiwtch];
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.frame = CGRectMake(0, medicalSiwtch.top,44,medicalSiwtch.height);
    [backBtn setImage:[UIImage imageNamed:@"myCenterBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
}

#pragma mark - 懒加载
- (MedicalFirstController *)firstController
{
    if (_firstController == nil) {
        _firstController = [[MedicalFirstController alloc] init];
    }
    _firstController.nav = self.navigationController;
    return _firstController;
}

- (MedicalSecondController *)secondController
{
    if (_secondController == nil) {
        _secondController = [[MedicalSecondController alloc] init];
    }
    _secondController.nav = self.navigationController;
    return _secondController;
}

#pragma mark - 界面切换
- (void)medicaSwitchChangeState:(switchState)state
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    if (state == switchStateLeft) {
        [self.contentView addSubview:self.firstController.tableView];
    } else {
        [self.contentView addSubview:self.secondController.tableView];
    }
}

#pragma mark - 返回
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 重写父类调整键盘的方法
- (void)changeFrame:(NSNotification *)noti
{
    if (self.margin > 200) {
        return;
    }
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect keybordFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat keybordHeigt = keybordFrame.size.height;
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    
    CGRect firstFrame = [self.view convertRect:firstResponder.frame fromView:firstResponder.superview];
    CGFloat firstY = firstFrame.origin.y + firstFrame.size.height;
    
    CGFloat margin = keybordHeigt - (SCREEN_HEIGHT - firstY);
    
    if (margin < 0) {
        return;
    }
    
    self.margin = self.margin + margin;
    [UIView animateWithDuration:0.2 animations:^{
        UITableView *tableView = self.firstController.tableView?self.firstController.tableView:self.secondController.tableView;
        tableView.contentOffset = CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y + margin);
    }];
}

- (void)adjustFrame
{
    if (self.margin == 0) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        UITableView *tableView = self.firstController.tableView?self.firstController.tableView:self.secondController.tableView;
        tableView.contentOffset = CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y - self.margin);
    }];
    self.margin = 0;
}


@end
