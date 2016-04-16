//
//  MyCenterBaseController.m
//  
//
//  Created by wenzhizheng on 16/1/8.
//
//

#import "MyCenterBaseController.h"

@interface MyCenterBaseController ()

@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UIButton *backBtn;


@end

@implementation MyCenterBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:UIKeyboardWillHideNotification object:nil];    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeHUD) name:NoNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeHUD) name:UserRelogin object:nil];
    
    
}

- (void)removeHUD
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0, 200, 44);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = self.titleStr;
    titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel = titleLabel;
    CGPoint center = topView.center;
    center.y = topView.height - 20;
    titleLabel.center = center;
    [topView addSubview:titleLabel];
    
    UIButton *backBtn = [[UIButton alloc] init];
    self.backBtn = backBtn;
    backBtn.frame = CGRectMake(0, titleLabel.top , titleLabel.height, titleLabel.height);
    backBtn.clipsToBounds = YES;
    [backBtn setImage:[UIImage imageNamed:@"myCenterBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 是否需要返回按钮
- (void)setIsNeedBack:(BOOL)isNeedBack
{
    _isNeedBack = isNeedBack;
    if (isNeedBack == NO) {
        self.backBtn.hidden = YES;
    }
}

#pragma mark - 返回
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置title
- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    self.titleLabel.text = titleStr;
}

#pragma mark - 监听键盘frame的改变
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
        self.view.frame = CGRectOffset(self.view.frame, 0, - margin);
    }];
}

- (void)adjustFrame
{
    if (self.margin == 0) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, self.margin);
    }];
    self.margin = 0;
}

#pragma mark - 移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
