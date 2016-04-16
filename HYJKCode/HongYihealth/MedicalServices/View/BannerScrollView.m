//
//  BannerScrollView.m
//  
//
//  Created by 刘朝涛 on 16/1/1.
//
//

#import "BannerScrollView.h"

@implementation BannerScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.pagingEnabled = YES;
        [self initView];
    }
    return self;
}

- (void)initView {
    for (int i = 0; i < self.imageArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width * i, 0, self.width, self.height)];
//        imageView.clipsToBounds = YES;
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView sd_setImageWithURL:[NSURL URLWithString:_imageArr[i]] placeholderImage:DEFAULT_AVATAR];
//        [imageView setContentMode:UIViewContentModeScaleAspectFill];
//        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
    }
}
    
- (void)changeValue:(NSMutableArray *)dataArr {
    self.imageArr = [[NSMutableArray alloc] initWithArray:dataArr];
    [self removeAllSubviews];
    self.contentSize = CGSizeMake(self.width * self.imageArr.count, self.height);
    [self initView];
}

- (NSArray *)imageArr {
    if (_imageArr == nil) {
        _imageArr = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _imageArr;
}

@end
