//
//  KWPopoverView.h
//  KWPopoverViewDemo
//
//  Created by zzl on 14-4-10.
//  Copyright (c) 2014年 zzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWPopoverView : UIView

@property(nonatomic)BOOL isRejectTouchBack;
+ (void)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view withContentView:(UIView *)cView andRejectTouchBackOrNO:(BOOL)rejectBack;


@end