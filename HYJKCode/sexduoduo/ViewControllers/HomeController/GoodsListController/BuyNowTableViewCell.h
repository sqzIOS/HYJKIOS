//
//  BuyNowTableViewCell.h
//  sexduoduo
//
//  Created by sqz on 14-11-27.
//  Copyright (c) 2014年 dbCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyNowTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *goodImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLab;

@property (strong, nonatomic) IBOutlet UILabel *nowPriceLab;
@property (strong, nonatomic) IBOutlet UILabel *oldPriceLab;

@property (strong, nonatomic) IBOutlet UILabel *numLab;

@property (strong, nonatomic) IBOutlet UILabel *zeKouLab;



-(void)configCellWithArray:(NSArray *)array indexRow:(int)row;
@end
