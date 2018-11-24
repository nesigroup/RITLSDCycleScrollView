//
//  RITLShakePageControl.m
//  NongWanCloud
//
//  Created by YueWen on 2017/12/27.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import "RITLShakePageControl.h"

@interface RITLShakePageControl()

/// dot的直径
@property (nonatomic, assign, readonly)CGFloat indicatorDiameter;

/// 正常状态的layers
@property (nonatomic, strong)NSMutableArray < CALayer *> *inactiveLayers;

/// 活动状态下的layer
@property (nonatomic, strong) CALayer *activeLayer;

@end

@implementation RITLShakePageControl

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame]) {
        
        //初始化
        self.pageCount = 0;
        self.progress = 0;
        
        self.activeTint = UIColor.whiteColor;
        self.indicatorPadding = 10;
        self.indicatorRadius = 5;
        self.inactiveTint = [UIColor.whiteColor colorWithAlphaComponent:0.3];
        
        self.inactiveLayers = [NSMutableArray arrayWithCapacity:10];
        
    }
    
    return self;
}


#pragma mark - didSet

- (void)setPageCount:(NSInteger)pageCount
{
    _pageCount = pageCount;
    [self updateNumberOfPagesWithCount:pageCount];
}


- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self layoutActivePageIndicatorWithProgress:progress];
}


- (void)setActiveTint:(UIColor *)activeTint
{
    _activeTint = activeTint;
    self.activeLayer.backgroundColor = activeTint.CGColor;
}

- (void)setInactiveTint:(UIColor *)inactiveTint
{
    _inactiveTint = inactiveTint;
    
    [self.inactiveLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = inactiveTint.CGColor;
    }];
}


- (void)setIndicatorPadding:(CGFloat)indicatorPadding
{
    _indicatorPadding = indicatorPadding;
    
    [self layoutInactivePageIndicatorsAtLayers:self.inactiveLayers];
    [self layoutActivePageIndicatorWithProgress:self.progress];
    [self invalidateIntrinsicContentSize];
}

- (void)setIndicatorRadius:(CGFloat)indicatorRadius
{
    _indicatorRadius = indicatorRadius;
    [self layoutInactivePageIndicatorsAtLayers:self.inactiveLayers];
    [self layoutActivePageIndicatorWithProgress:self.progress];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - readonly

- (NSInteger)currentPage
{
    return (NSInteger)roundf(self.progress);
}

- (CGFloat)indicatorDiameter
{
    return self.indicatorRadius * 2;
}


#pragma mark - lazy

- (CALayer *)activeLayer
{
    if (!_activeLayer) {
        
        __weak typeof(self) weak = self;
        
        _activeLayer = ({
           
            CALayer *layer = CALayer.layer;
            
            CGRect frame = CGRectZero;
            frame.origin = CGPointZero;
            frame.size = CGSizeMake(weak.indicatorDiameter, weak.indicatorDiameter);
            layer.frame = frame;
            layer.backgroundColor = self.activeTint.CGColor;
            layer.cornerRadius = self.indicatorRadius;
            layer.actions = @{@"bounds":NSNull.null,
                              @"frame":NSNull.null,
                              @"position":NSNull.null
                              };
            
            layer;
        });
    }
    return _activeLayer;
}

#pragma mark - State Update

- (void)updateNumberOfPagesWithCount:(NSInteger)count
{
    // no need to update
    if (count == self.inactiveLayers.count) { return; }

    // reset current layout
    [self.inactiveLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        [obj removeFromSuperlayer];
    }];
    
    self.inactiveLayers = [NSMutableArray arrayWithCapacity:10];

    // add layers for new page count
    for (NSInteger i = 0; i < count; i++) {
        
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = self.inactiveTint.CGColor;
        [self.layer addSublayer:layer];
        [self.inactiveLayers addObject:layer];
    }

    [self layoutInactivePageIndicatorsAtLayers:self.inactiveLayers];
    
    // ensure active page indicator is on top
    [self.layer addSublayer:self.activeLayer];
    [self layoutActivePageIndicatorWithProgress:self.progress];
    [self invalidateIntrinsicContentSize];
}


- (void)layoutActivePageIndicatorWithProgress:(CGFloat)progress
{
    // ignore if progress is outside of page indicators' bounds
    if (!(progress >= 0 && progress <= (self.pageCount - 1))) { return; }
    
    CGFloat denormalizedProgress = progress * (self.indicatorDiameter + self.indicatorPadding);
    CGFloat distanceFromPage = ABS(roundf(progress) - progress);
    CGFloat width = self.indicatorDiameter + self.indicatorPadding * (distanceFromPage * 2);
    
    CGRect newFrame = CGRectMake(0, self.activeLayer.frame.origin.y, width, self.indicatorDiameter);
    newFrame.origin.x = denormalizedProgress;
    self.activeLayer.cornerRadius = self.indicatorRadius;
    self.activeLayer.frame = newFrame;
}


- (void)layoutInactivePageIndicatorsAtLayers:(NSArray <CALayer *> *)layers
{
    __block CGRect layerFrame = CGRectMake(0, 0, self.indicatorDiameter, self.indicatorDiameter);
    
    [layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        obj.cornerRadius = self.indicatorRadius;
        obj.frame = layerFrame;
        layerFrame.origin.x += (self.indicatorDiameter + self.indicatorPadding);
    }];
}


#pragma mark - super

- (CGSize)intrinsicContentSize
{
    return self.sizeThatFits;
}


- (CGSize)sizeThatFits
{
    return CGSizeMake(self.inactiveLayers.count * self.indicatorDiameter + (self.inactiveLayers.count - 1) * self.indicatorPadding, self.indicatorDiameter);
}

@end
