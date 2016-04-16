//
//  SDExchangeHeadView.m
//  sexduoduo
//
//  Created by showm on 15/12/3.
//  Copyright © 2015年 dbCode. All rights reserved.
//

#import "SDExchangeHeadView.h"
#import "StyledPageControl.h"
#import "ClassifyFileObj.h"


@interface SDExchangeHeadView()
//滚动点
@property(weak,nonatomic)StyledPageControl* pageControl;
//广告对象Model
//@property (strong,nonatomic) SHHealthAdModel *model;
//滚动数据
@property(strong,nonatomic)NSMutableArray* svData;
@end


@implementation SDExchangeHeadView
- (id)initWithFrameAndType:(CGRect)frame pvc:(id)pvc
{
    self = [super initWithFrame:frame];
    if (self) {
        self.svData = [NSMutableArray array];
        self.parentVC = pvc;
        
        XLCycleScrollView *adScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        adScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        adScrollView.delegate = self;
        adScrollView.datasource = self;
        adScrollView.scrollView.scrollsToTop = NO;
        adScrollView.autoScrollDuration = 3;
        adScrollView.autoScroll = YES;
        adScrollView.pageControl.hidden = YES;
        [self addSubview:adScrollView];
        self.scrollView = adScrollView;
        
        //点
        StyledPageControl* pageControl = [[StyledPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height-20, frame.size.width, 20)];
        pageControl.diameter = 8;
        pageControl.gapWidth = 8;
        pageControl.coreNormalColor = [UIColor colorWithRed:241/255.f green:51/255.f blue:125/255.f alpha:1.0];
        pageControl.coreSelectedColor = [UIColor colorWithRed:232/255.f green:232/255.f blue:232/255.f alpha:1.0];
        pageControl.pageControlStyle = PageControlStyleDefault;
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        
        [self addSubview:self.pageControl];
        
        //广告
        if ([[AppSet shareInstance] BBSADList].count>0) {
            
            [self.svData addObjectsFromArray:[[AppSet shareInstance] BBSADList]];
            [self.scrollView reloadData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestData];
        });
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark ---Data
-(void)requestData
{
    [self requestHomeAdsListWithWithDic:nil];
}
//广告
-(void)requestHomeAdsListWithWithDic:(NSDictionary *)dic
{
    
    
    //请求广告 或 置顶
    NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]init];
    [tempDic setObject:@"10" forKey:@"forumId"];
    [tempDic setObject:@"1" forKey:@"pageNo"];
    [tempDic setObject:@"10" forKey:@"pageSize"];
    [[MKHttpExchangeDemo shareMyInstance] requestADListWithDic:tempDic completionHandler:^(id responseObject) {
        NSDictionary *responseDic = responseObject;
        NSLog(@"--<>>%@-广告-%@",responseDic,[responseDic objectForKey:@"message"]);
        
        if (responseDic[@"success"] && responseDic[@"datasource"])
        {
            [_svData removeAllObjects];

            
            self.svData=[[NSMutableArray alloc]initWithCapacity:0];
            [PublicMethod formatRequestDataForAndroid:responseDic[@"datasource"] toArray:self.svData];
            
            //保存本地
            [[AppSet shareInstance] setBBSADList:self.svData];
            [[AppSet shareInstance] saveBBSADList];
            
            [_scrollView reloadData];

        }
        
    } errorHandler:^(NSError *error) {
        
    }];
    
}


#pragma mark ---Delegate
- (NSInteger)numberOfPages
{
    NSInteger count = [self.svData count];
    return count;
}
- (UIView *)cycleScrollView:(XLCycleScrollView *)scrollView pageAtIndex:(NSInteger)index
{
    QzImageView *AdView = [_scrollView dequeueReusableView];
    if (!AdView) {
        AdView = [[QzImageView alloc] initWithFrame:_scrollView.bounds];
        
        //主题
        UIImageView *priceBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height-40,SCREEN_WIDTH, 40)];
        priceBg.image=UIImageByName(@"bbsADbg");
        [AdView addSubview:priceBg];
        
        UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(QZMake(10), self.height -30, QZMake(375-20), QZMake(20))];
        priceLab.backgroundColor = [UIColor clearColor];
        priceLab.textColor = [UIColor whiteColor];
        priceLab.font = [UIFont systemFontOfSize:16.0];
        priceLab.qzTagString=@"titleLab";
        [AdView addSubview:priceLab];
    }
    AdView.userInteractionEnabled = YES;
    
    NSDictionary *dic = _svData[index];
    if (1 == _svData.count) {
        self.pageControl.numberOfPages = 0;
    } else {
        self.pageControl.numberOfPages = (int)_svData.count;
    }
    self.pageControl.currentPage = (int)scrollView.currentPage;
    AdView.contentMode = UIViewContentModeScaleToFill;
    
    
    NSURL *url=[PublicMethod bbsImgURlAndroidWithStr:dic[@"contentHtml"][0]];
    [AdView sd_setImageWithURL:url];
    
    UILabel *nameLab=(UILabel *)[AdView subViewWithQzTagString:@"titleLab"];
    
    nameLab.text = dic[@"title"];

    return AdView;
}

//点击事件
-(void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    
    
    NSLog(@"点击");
 
    NSString *topicId=@"0";
    if (self.svData.count>index) {
        topicId=self.svData[index][@"id"];
    }
    
    
    BBSDetailNewViewController *controller = [[BBSDetailNewViewController alloc] initWithNibName:@"BBSDetailNewViewController" bundle:[NSBundle mainBundle]];
    controller.forumId=@"10";
    controller.topicId=topicId;
    controller.hidesBottomBarWhenPushed = YES;
    [self.parentVC.navigationController pushViewController: controller animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
