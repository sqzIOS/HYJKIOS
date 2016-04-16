//
//  SVStatusHUD.m
//
//  Created by Sam Vermette on 17.11.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVStatusHUD
//

#import "SVStatusHUD.h"
#import <QuartzCore/QuartzCore.h>

#define SVStatusHUDVisibleDuration 1.0f
#define SVStatusHUDFadeOutDuration 1.0f


@interface SVStatusHUD ()

@property (nonatomic, retain) NSTimer *fadeOutTimer;
@property (nonatomic, readonly) UIWindow *overlayWindow;
@property (nonatomic, readonly) UIView *hudView;
@property (nonatomic, readonly) UILabel *stringLabel;
@property (nonatomic, assign) CGPoint centerPoint;

- (void)showWithStatus:(NSString*)string atCenter:(CGPoint)point duration:(NSTimeInterval)duration;
- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)positionHUD:(NSNotification*)notification;

- (void)dismiss;

@end


@implementation SVStatusHUD

@synthesize overlayWindow, hudView, fadeOutTimer, stringLabel, centerPoint;

static SVStatusHUD *sharedView = nil;

- (void)dealloc {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [hudView release];
    [stringLabel release];
    
    [super dealloc];
}

+ (SVStatusHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVStatusHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	return sharedView;
}


+ (void)setStatus:(NSString *)string {
	[[SVStatusHUD sharedView] setStatus:string];
}

#pragma mark - Show Methods

+ (void)show
{
    [SVStatusHUD showWithStatus:nil atCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2) duration:SVStatusHUDVisibleDuration];
}

+ (void)showWithStatus:(NSString*)string atCenter:(CGPoint)point
{
    [SVStatusHUD showWithStatus:string atCenter:point duration:SVStatusHUDVisibleDuration];
}

+ (void)showWithStatus:(NSString*)string atCenter:(CGPoint)point duration:(NSTimeInterval)duration
{
    [[SVStatusHUD sharedView] showWithStatus:string atCenter:point duration:duration];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        [self.overlayWindow addSubview:self];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
	
    return self;
}


- (void)setStatus:(NSString *)string {
	
    CGFloat hudWidth = 80;
    CGFloat hudHeight = 20;
	
	self.hudView.bounds = CGRectMake(40, 0, hudWidth, hudHeight);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
}


- (void)showWithStatus:(NSString *)string atCenter:(CGPoint)point duration:(NSTimeInterval)duration
{
    self.centerPoint = point;
	[self setStatus:string];
    [self.overlayWindow makeKeyAndVisible];
    [self positionHUD:nil];
    
	if(self.alpha != 1) {
        [self registerNotifications];
		self.alpha = 1;
	}
    
    if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
    
    [self setNeedsDisplay];
}


- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification 
                                               object:nil];  
}


- (void)positionHUD:(NSNotification*)notification {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    CGFloat posY = floor(activeHeight*0.52);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI; 
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    } 
    
    self.hudView.transform = CGAffineTransformMakeRotation(rotateAngle); 
    self.hudView.center = self.centerPoint;
}

- (void)dismiss {
	
	[UIView animateWithDuration:SVStatusHUDFadeOutDuration
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{	
						 sharedView.alpha = 0;
					 }
					 completion:^(BOOL finished){ 
                         if(sharedView.alpha == 0) {
                             [[NSNotificationCenter defaultCenter] removeObserver:sharedView];
                             [overlayWindow release], overlayWindow = nil;
                             [sharedView release], sharedView = nil;
                             
                             [[UIApplication sharedApplication].windows.lastObject makeKeyAndVisible];
                             
                             // uncomment to make sure UIWindow is gone from app.windows
                             //NSLog(@"%@", [UIApplication sharedApplication].windows);
                         }
                     }];
}

#pragma mark - Getters

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
    }
    return overlayWindow;
}

- (UIView *)hudView {
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 10;
		hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:hudView];
    }
    return hudView;
}

- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, 20)];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = UITextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:16];
		stringLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.7];
		stringLabel.shadowOffset = CGSizeMake(1, 1);
        stringLabel.numberOfLines = 0;
		[self.hudView addSubview:stringLabel];
    }
    return stringLabel;
}

@end
