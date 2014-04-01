//
//  PDCircleProgress.m
//  PDCircleProgress
//
//  Created by ChenGe on 14-4-1.
//  Copyright (c) 2014年 Panda. All rights reserved.
//

#import "PDCircleProgress.h"

#define LINE_WIDTH 2
#define BLUE_COLOR [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1]
#define BLUE_COLOR_ALPHA(__x__) [UIColor colorWithRed:0 green:0.48 blue:1 alpha:__x__]

@interface PDCircleProgress ()
{
    CADisplayLink * link;
    CGFloat tempProgress;
    CGFloat tempAlpha;
}
@end

@implementation PDCircleProgress

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width);
    self = [super initWithFrame:frame];
    
    if (self) {
        self.progress = 0.f;
        tempProgress = 0.f;
        tempAlpha = 0.f;
        self.backgroundColor = [UIColor whiteColor];
        
        link = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.progress <= 0.f) {
        [self tryToConnect];
    } else if (self.progress >= 1.f) {
        [self finishedLoad];
    } else {
        [self loading];
    }
}

#pragma mark - loading state
- (void)tryToConnect
{
    CGFloat distance = 2 * M_PI;
    CGFloat secondsPerFrame = 0.9;
    
    NSTimeInterval ti = [NSDate timeIntervalSinceReferenceDate] / secondsPerFrame;
    
    BOOL goesCW = YES;
    CGFloat phase = distance * (ti - floor(ti)) * (goesCW ? - 1 : 1);
    
    UIBezierPath * circle = [UIBezierPath bezierPathWithArcCenter:RectGetCenter(self.bounds)
                                                           radius:self.bounds.size.width / 2 - LINE_WIDTH
                                                       startAngle:phase
                                                         endAngle:0.3 + phase clockwise:NO];
    
    [circle setLineWidth:LINE_WIDTH];
    [BLUE_COLOR setStroke];
    [circle stroke];
}

- (void)loading
{
    
    //loading background
    UIBezierPath * loadingPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, LINE_WIDTH, LINE_WIDTH)];
    [loadingPath setLineWidth:LINE_WIDTH];
    [BLUE_COLOR setStroke];
    [loadingPath stroke];
    
    CGFloat dx = self.bounds.size.width / 2 * 0.8;
    loadingPath = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, dx, dx)];
    [BLUE_COLOR setFill];
    [loadingPath fill];

    //loading Progress
    loadingPath = [UIBezierPath bezierPathWithArcCenter:RectGetCenter(self.bounds) radius:self.bounds.size.width / 2 - LINE_WIDTH * 2.5 startAngle:ProgressToAngle(0) endAngle:ProgressToAngle(self.progress) clockwise:YES];
    [loadingPath setLineWidth:LINE_WIDTH * 2];
    [BLUE_COLOR setStroke];
    [loadingPath stroke];
    
}


- (void)finishedLoad
{
    //底图
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectInset(self.bounds, LINE_WIDTH, LINE_WIDTH)];
    
    //对勾
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(21.5, 51.67)];
    [bezierPath addLineToPoint: CGPointMake(41.69, 71.5)];
    [bezierPath addLineToPoint: CGPointMake(78.5, 35.33)];
    [bezierPath addLineToPoint: CGPointMake(72.56, 29.5)];
    [bezierPath addLineToPoint: CGPointMake(41.69, 59.83)];
    [bezierPath addLineToPoint: CGPointMake(27.44, 45.83)];
    [bezierPath addLineToPoint: CGPointMake(21.5, 51.67)];
    [bezierPath closePath];
    
    //对勾大小修正
    CGFloat scale = self.bounds.size.width / 100;
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    [bezierPath applyTransform:transform];
    
    //合并曲线 打开奇偶填充规则
    [bezierPath appendPath:ovalPath];
    [bezierPath setUsesEvenOddFillRule:YES];
    
    //设置简单动画
    CGFloat step = 0.1;
    CGFloat secondsPerFrame = 0.1;
    NSTimeInterval ti = [NSDate timeIntervalSinceReferenceDate] / secondsPerFrame;
    CGFloat phase = step * (ti - floor(ti));
    if (tempAlpha < 1) {
        tempAlpha += phase;
    } else {
        [link invalidate];
    }
    
    [BLUE_COLOR_ALPHA(tempAlpha) setFill];
    [bezierPath fill];
    [BLUE_COLOR_ALPHA(tempAlpha) setStroke];
    bezierPath.lineWidth = LINE_WIDTH;
    [bezierPath stroke];
    
}

#pragma mark - public method

CGFloat ProgressToAngle(CGFloat progress)
{
    return  progress * M_PI * 2 - M_PI_2;
    
}

CGPoint RectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

@end
