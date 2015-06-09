//
//  InboxRefreshControl.m
//
//
//  Created by Bobo Shone on 15/6/5.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "InboxRefreshControl.h"

typedef enum {
    InboxRefreshControlArcStateIncrease = 0,
    InboxRefreshControlArcStateDecrease
} InboxRefreshControlArcState;

//typedef enum {
//    InboxRefreshControlStateDefault = 0
//    InboxRefreshControlStatePulling,
//    InboxRefreshControlStateRefreshing,    
//} InboxRefreshControlState;

@interface InboxRefreshControl ()

@property (nonatomic, assign) BOOL refreshing;

@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, assign) CGFloat maxArcAngle;
@property (nonatomic, assign) CGFloat minArcAngle;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) InboxRefreshControlArcState arcState;
@property (nonatomic, assign) CGFloat currentStartAngle;
@property (nonatomic, assign) CGFloat currentEndAngle;
@property (nonatomic, assign) CGFloat rotationAngle;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *circleColor;
//@property (nonatomic, assign) InboxRefreshControlState state;

@end

@implementation InboxRefreshControl

- (instancetype)initWithSize:(CGFloat)size {
    self = [super initWithFrame:CGRectMake(0, 0, size, size)];
    if (self) {
        self.lineWidth = 3;
        self.circleRadius = (size - self.lineWidth)/2;
        self.maxArcAngle = M_PI * 2 * 0.85;
        self.minArcAngle = M_PI * 2  * 0.15;
        self.updateTimer = [NSTimer timerWithTimeInterval:1.f/60 target:self selector:@selector(update) userInfo:nil repeats:YES];
        self.backgroundColor = [UIColor clearColor];
        self.circleColor = [UIColor blueColor];
    }
    return self;
}

- (void)beginRefreshing {
    self.refreshing = YES;
    
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

- (void)endRefreshing {
    self.refreshing = NO;
    
    [self.updateTimer invalidate];
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat startAngle = self.currentStartAngle;
    CGFloat endAngle = self.currentEndAngle;
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, self.circleRadius, startAngle, endAngle, 0);
    CGContextSetStrokeColorWithColor(context, self.circleColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextStrokePath(context);
}

- (void)update {
    
    CGFloat degreeDelta = 6;
    if (self.currentEndAngle - self.currentStartAngle <= self.minArcAngle) {
        self.arcState = InboxRefreshControlArcStateIncrease;
    }
    if (self.currentEndAngle - self.currentStartAngle >= self.maxArcAngle) {
        self.arcState = InboxRefreshControlArcStateDecrease;
    }
    
    if (self.arcState == InboxRefreshControlArcStateIncrease) {
        self.currentEndAngle += degreeDelta / 180.f * M_PI;
    }
    else if (self.arcState == InboxRefreshControlArcStateDecrease) {
        self.currentStartAngle += degreeDelta / 180.f * M_PI;
    }
    
    self.rotationAngle += 3 / 180.f * M_PI;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.transform = CGAffineTransformMakeRotation(self.rotationAngle);
        [self setNeedsDisplay];
    });
}

- (void)dealloc {
    if (self.updateTimer.valid) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
    
}

- (void)pullWithDistance:(CGFloat)pullingDistance {
    if (self.refreshing) {
        return;
    }
    
    CGFloat distance = pullingDistance;
    CGFloat ignoredDistance = 50;
    if (distance < ignoredDistance) {
        return;
    }
    else {
        distance = distance - ignoredDistance;
    }
    self.currentStartAngle = -M_PI/2;
    CGFloat maxChangeSizePullingDistance = 50;
    CGFloat scale = MIN(1, distance/maxChangeSizePullingDistance);
    self.currentEndAngle = self.currentStartAngle + scale * self.maxArcAngle;
    self.rotationAngle = scale * M_PI/2*3;
    self.transform = CGAffineTransformMakeRotation(self.rotationAngle);
    self.alpha = scale;
    [self setNeedsDisplay];
}

@end
