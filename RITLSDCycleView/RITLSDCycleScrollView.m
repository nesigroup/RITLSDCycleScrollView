//
//  CSDCycleScrollView.m
//  NongWanCloud
//
//  Created by YueWen on 2018/1/9.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "RITLSDCycleScrollView.h"
#import <UIImageView+WebCache.h>
#import <RITLViewFrame/UIView+RITLFrameChanged.h>


CGFloat RITLSDCycleScrollViewPageSpaceDefault = -1000000;

@protocol RITLSDCycleScrollViewSuper <NSObject>

@optional

@property (nonatomic, assign) NSInteger totalItemsCount;

- (int)currentIndex;

- (void)setupTimer;
- (void)invalidateTimer;

- (void)scrollToIndex:(int)targetIndex;
- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index;

@end

@interface SDCycleScrollView (RITLSDCycleScrollViewSuper)<RITLSDCycleScrollViewSuper>

@end

@interface RITLSDCycleScrollView ()

@property (nonatomic, assign)CGSize customSize;
@property (nonatomic, assign)UICollectionViewScrollPosition position;

@end

@implementation RITLSDCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.customSize = CGSizeZero;
        self.pageControlMarginBottom = RITLSDCycleScrollViewPageSpaceDefault;
        self.pageControlMarginRight = RITLSDCycleScrollViewPageSpaceDefault;
    }
    
    return self;
}

- (void)setDataSource:(id<RITLSDCycleScrollViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    if (dataSource) {
        
        if (@available(iOS 11.0, *)) {
            self.mainView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        Class class;
        
        // 注册cell
        if ([self.dataSource respondsToSelector:@selector(cycleViewCustomCollectionViewCellClass:)]) {
            
            class = [self.dataSource cycleViewCustomCollectionViewCellClass:self];
            
        }else {
            
            class = [self.dataSource customCollectionViewCellClassForCycleScrollView];
        }
        
        [self.mainView registerClass:class forCellWithReuseIdentifier:NSStringFromClass(class)];
    }
    
    if ([dataSource respondsToSelector:@selector(cycleScollViewcustomCollectionViewLayout:)]) {
        
        UICollectionViewLayout *layout = [self.dataSource cycleScollViewcustomCollectionViewLayout:self];
        
        self.mainView.collectionViewLayout = layout;
        
        if ([layout isKindOfClass:UICollectionViewFlowLayout.class]) {
            
            self.customSize = ((UICollectionViewFlowLayout *)layout).itemSize;
        }
    }
    
//    /****** 不建议使用的方法 ******/
//    else if ([dataSource respondsToSelector:@selector(customCollectionViewLayoutForCycleScollView)]) {
//
//        UICollectionViewLayout *layout = [self.dataSource customCollectionViewLayoutForCycleScollView];
//
//        self.mainView.collectionViewLayout = layout;
//
//        if ([layout isKindOfClass:UICollectionViewFlowLayout.class]) {
//
//            self.customSize = ((UICollectionViewFlowLayout *)layout).itemSize;
//        }
//    }
//    /************/
    
    if ([dataSource respondsToSelector:@selector(cycleViewCustomCollectionViewScrollPosition:)]) {
        
        self.position = [self.dataSource cycleViewCustomCollectionViewScrollPosition:self];
    }
}


- (UICollectionView *)contentView
{
    return [self valueForKey:@"mainView"];
}


#pragma mark - override

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.dataSource) {
        
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    Class <RITLSDCycleScrollViewCell> cellClass = [self cycleViewCustomCollectionViewCellClass];
    
    
    UICollectionViewCell <RITLSDCycleScrollViewCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
    
     NSInteger item = self.infiniteLoop ? [self pageControlIndexWithCurrentCellIndex:indexPath.item] : indexPath.item;
    
    //进行回调
    if ([self.dataSource respondsToSelector:@selector(cycleView:setupCustomCell:forIndex:)]) {
        
        [self.dataSource cycleView:self setupCustomCell:cell forIndex:[NSIndexPath indexPathForItem:item inSection:0]];
    }
    
    NSString *imagePath = self.imagePathsGroup[item];
    
    if (!self.onlyDisplayText && [imagePath isKindOfClass:[NSString class]]) {
        if ([imagePath hasPrefix:@"http"]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
        } else {
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            cell.imageView.image = image;
        }
    } else if (!self.onlyDisplayText && [imagePath isKindOfClass:[UIImage class]]) {
        cell.imageView.image = (UIImage *)imagePath;
    }
    
    return cell;
}



- (void)scrollToIndex:(int)targetIndex
{
    if (targetIndex >= self.totalItemsCount) {
        if (self.infiniteLoop) {
            targetIndex = self.totalItemsCount * 0.5;
            [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:self.position animated:NO];
        }
        return;
    }
    [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:self.position animated:YES];
}



- (void)adjustWhenControllerViewWillAppera
{
    long targetIndex = [self currentIndex];
    if (targetIndex < self.totalItemsCount) {
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:self.position animated:NO];
    }
}



- (void)setImagePathsGroup:(NSArray *)imagePathsGroup
{
    if (!self.dataSource) {
        
        [super setImagePathsGroup:imagePathsGroup]; return;
    }
    
    Class <RITLSDCycleScrollViewCell> cellClass = [self cycleViewCustomCollectionViewCellClass];
    
    //进行注册
    [self.mainView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    
    [super setImagePathsGroup:imagePathsGroup];

}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateMargin];
    [self updateCustomSize];
}


/// 优化当前索引
- (NSInteger)currentIndex
{
    if ([self.dataSource respondsToSelector:@selector(cycleView:currentIndexWithContentOffset:)]) {

        return [self.dataSource cycleView:self currentIndexWithContentOffset:self.mainView.contentOffset];
    }

    return  [super currentIndex];
}



#pragma mark -

- (void)setPageEnable:(BOOL)pageEnable
{
    self.mainView.pagingEnabled = pageEnable;
}

- (BOOL)pageEnable
{
    return self.mainView.pagingEnabled;
}


- (void)updateMargin
{
    if (self.pageControl.hidden || !self.showPageControl) { return; }
    
    if (self.pageControlMarginRight != RITLSDCycleScrollViewPageSpaceDefault) {
        
        self.pageControl.ritl_originX = self.ritl_width - self.pageControlMarginRight - self.pageControl.ritl_width;
    }
    
    if (self.pageControlMarginBottom != RITLSDCycleScrollViewPageSpaceDefault) {
        
        self.pageControl.ritl_originY = self.ritl_height - self.pageControlMarginBottom - self.pageControl.ritl_height;
    }

}


- (void)updateCustomSize
{
    if (![self.dataSource respondsToSelector:@selector(cycleViewShouldResetCollectionWithCustomScrollPosition:)]) { return; }
    
    if ([self.mainView.collectionViewLayout isKindOfClass:UICollectionViewFlowLayout.class]) {

        ((UICollectionViewFlowLayout *)self.mainView.collectionViewLayout).itemSize = self.customSize;
        [self updateCustomInitContentOffSet];
    }


}

- (void)updateCustomInitContentOffSet
{
    if (self.totalItemsCount) {
        int targetIndex = 0;
        if (self.infiniteLoop) {
            targetIndex = self.totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:self.position animated:NO];
    }
}


- (BOOL)debugIndex
{
    return false;
}


#pragma mark - Tool - 用以适配即将废弃的方法

- (Class <RITLSDCycleScrollViewCell>)cycleViewCustomCollectionViewCellClass
{
    return [self.dataSource cycleViewCustomCollectionViewCellClass:self];
}



@end
