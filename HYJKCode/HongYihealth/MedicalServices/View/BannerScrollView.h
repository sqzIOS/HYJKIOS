//
//  BannerScrollView.h
//  
//
//  Created by 刘朝涛 on 16/1/1.
//
//

#import <UIKit/UIKit.h>

@interface BannerScrollView : UIScrollView

@property (nonatomic, copy) NSMutableArray *imageArr;

- (void)changeValue:(NSMutableArray *)dataArr;

@end
