//
//  WHIdentityCardScaningView.m
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/6.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import "WHIdentityCardScaningView.h"

#define iPhone40inch ([UIScreen mainScreen].bounds.size.height == 568.0)

#define iPhone47inch ([UIScreen mainScreen].bounds.size.height == 667.0)

#define iPhone55inch ([UIScreen mainScreen].bounds.size.height == 736.0)


@interface WHIdentityCardScaningView ()

{
    CAShapeLayer * _IDCardScanningWindowLayer;
    NSTimer * _timer;
}

@property (strong, nonatomic) UILabel * titleLabel;

@end

@implementation WHIdentityCardScaningView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self drawView];
        
        [self startTimer];
    }
    
    return self;
}

- (void)drawView {
    
    // 中间包裹线
    _IDCardScanningWindowLayer = [CAShapeLayer layer];
    _IDCardScanningWindowLayer.position = self.layer.position;
    
    CGFloat width = iPhone40inch ? 240 : (iPhone47inch ? 270 : 300);
    _IDCardScanningWindowLayer.bounds = (CGRect){CGPointZero, {width, width * 1.574}};
    _IDCardScanningWindowLayer.cornerRadius = 15;
    _IDCardScanningWindowLayer.borderColor = [UIColor whiteColor].CGColor;
    _IDCardScanningWindowLayer.borderWidth = 1.5;
    
    [self.layer addSublayer:_IDCardScanningWindowLayer];
    
    // 里面镂空层
    UIBezierPath * transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:_IDCardScanningWindowLayer.frame cornerRadius:_IDCardScanningWindowLayer.cornerRadius];
    
    // 外面背景层
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.frame];
    [path appendPath:transparentRoundedRectPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer * fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.6;
    [self.layer addSublayer:fillLayer];
    
    CGFloat facePathWidth = iPhone40inch ? 125 : (iPhone47inch ? 150 : 180);
    CGFloat facePathHeight = facePathWidth * 0.812;
    CGRect rect = _IDCardScanningWindowLayer.frame;
    self.facePathRect = CGRectMake(CGRectGetMaxX(rect) - facePathWidth - 35, CGRectGetMaxY(rect) - facePathHeight - 25, facePathWidth, facePathHeight);
    
    CGPoint center = self.center;
    center.x = CGRectGetMaxX(_IDCardScanningWindowLayer.frame) + 20;
    
    [self addtipLabelWithText:@"请将身份证正面位于区域内进行扫描" center:center];
}


- (void)addtipLabelWithText:(NSString *)text center:(CGPoint)center {
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.text = text;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    tipLabel.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    
    [tipLabel sizeToFit];
    tipLabel.center = center;
    self.titleLabel = tipLabel;
    [self addSubview:tipLabel];
}

- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [_timer fire];
}
- (void)timerAction:(NSTimer *)timer {
    [self setNeedsDisplay];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)drawRect:(CGRect)rect {
    
    rect = _IDCardScanningWindowLayer.frame;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    static CGFloat moveX = 0;
    static CGFloat distanceX = 0;
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2);
    CGContextSetRGBStrokeColor(context, 0.3, 0.8, 0.3, 0.8);
    
    CGPoint p1, p2;
    
    moveX += distanceX;
    
    if (moveX >= CGRectGetWidth(rect) - 2) {
        distanceX = -2;
    } else if (moveX <= 2) {
        distanceX = 2;
    }
    
    p1 = CGPointMake(CGRectGetMaxX(rect) - moveX, rect.origin.y);
    p2 = CGPointMake(CGRectGetMaxX(rect) - moveX, rect.origin.y + rect.size.height);
    
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    
    CGContextStrokePath(context);
}

- (void)setTitleStr:(NSString *)titleStr {
    self.titleLabel.text = [NSString stringWithFormat:@"请将身份证%@面位于区域内进行扫描",titleStr];
}


@end
