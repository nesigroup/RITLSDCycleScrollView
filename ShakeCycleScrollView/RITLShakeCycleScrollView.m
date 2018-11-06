//
//  ShakeCycleScrollView.m
//  NongWanCloud
//
//  Created by YueWen on 2017/12/27.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import "RITLShakeCycleScrollView.h"
#import "RITLShakePageControl.h"

/// 用于模拟读取父类的数据
@protocol ShakeCycleScrollViewSuper <NSObject>

@property (nonatomic, weak) UIView *pageControl;
@property (nonatomic, weak) UICollectionView *mainView;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

- (int)currentIndex;
- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index;

@end


@interface SDCycleScrollView (ShakeCycleScrollView) <ShakeCycleScrollViewSuper,UIScrollViewDelegate>


@end


@interface RITLShakeCycleScrollView ()

- (CGFloat)currentProgress;

@end

/// 重写部分方法
@implementation RITLShakeCycleScrollView

- (instancetype)init
{
    if (self = [super init]) {
     
        self.backgroundColor = UIColor.whiteColor;
        self.autoScroll = false;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.whiteColor;
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = CGSizeMake(self.imagePathsGroup.count * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    
    CGRect bounds = self.pageControl.bounds;
    bounds.size = size;
    self.pageControl.bounds = bounds;

}



- (void)setupPageControl
{
    if (self.pageControl) { [self.pageControl removeFromSuperview]; }// 重新加载时数据请求

    if (self.imagePathsGroup.count == 0 || self.onlyDisplayText) return;

    if ((self.imagePathsGroup.count == 1) && self.hidesForSinglePage) return;

    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];

    RITLShakePageControl *pageControl = [RITLShakePageControl new];
    pageControl.pageCount = self.imagePathsGroup.count;
    pageControl.activeTint = self.currentPageDotColor;
    pageControl.inactiveTint = self.pageDotColor;
    pageControl.userInteractionEnabled = false;
    pageControl.progress = indexOnPageControl;
    self.pageControl = pageControl;

    [self addSubview:pageControl];
}


//- (void)setPageControlStyle:(SDCycleScrollViewPageContolStyle)pageControlStyle
//{
//
//}


- (CGFloat)currentProgress
{
    if (self.mainView.bounds.size.width == 0 || self.mainView.bounds.size.height == 0) {
        
        return 0;
    }
    
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {// 不支持垂直
        
        return 0;
    }

    //获得当前的progress
    
    /// 一倍距离
    CGFloat groupWidth = self.imagePathsGroup.count * self.flowLayout.itemSize.width * 1.0;
    
    /// 获得整数
    NSInteger multiple = (NSInteger)(self.mainView.contentOffset.x / groupWidth);
    
    /// 获得剩余
    CGFloat progress = (self.mainView.contentOffset.x - multiple * groupWidth) * 1.0;
    
//    NSLog(@"progress = %@",@(progress / self.flowLayout.itemSize.width));
    
    /// 获得progress
    return MAX(0, progress / self.flowLayout.itemSize.width);
}


#pragma mark - *************** ScrollViewDelegate ***************

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题

    if ([self.pageControl isKindOfClass:RITLShakePageControl.class]) {

        ((RITLShakePageControl *)self.pageControl).progress = self.currentProgress;//修改进度
    }
}



@end
