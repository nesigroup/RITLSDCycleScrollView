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
@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

- (int)currentIndex;

- (void)setupTimer;
- (void)invalidateTimer;
- (void)setupPageControl;

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
        
        self.scrollable = true;
        self.customSize = CGSizeZero;
        self.flowLayout.sectionInset = UIEdgeInsetsZero;
        self.flowLayout.minimumInteritemSpacing = CGFLOAT_MIN;
        self.flowLayout.minimumLineSpacing = CGFLOAT_MIN;
        self.usePageControl = true;
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
            [self.mainView registerClass:class forCellWithReuseIdentifier:NSStringFromClass(class)];
        }
        
        if ([dataSource respondsToSelector:@selector(cycleScollViewcustomCollectionViewLayout:)]) {
            
            UICollectionViewLayout *layout = [self.dataSource cycleScollViewcustomCollectionViewLayout:self];
            //如果是flowLayout
            self.mainView.collectionViewLayout = layout;
            
            if ([layout isKindOfClass:UICollectionViewFlowLayout.class]) {
                self.flowLayout = (UICollectionViewFlowLayout *)layout;
                self.customSize = ((UICollectionViewFlowLayout *)layout).itemSize;
            }
        }
        
        if ([dataSource respondsToSelector:@selector(cycleViewCustomCollectionViewScrollPosition:)]) {
            self.position = [self.dataSource cycleViewCustomCollectionViewScrollPosition:self];
        }
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
    
 
    UICollectionViewCell <RITLSDCycleScrollViewCell> *cell = nil;
    
    NSInteger item = self.infiniteLoop ? [self pageControlIndexWithCurrentCellIndex:indexPath.item] : indexPath.item;
    
    if (self.hasCycleViewAllRegisterCellClasses) {
        
        NSString *identifier = [self.dataSource cycleViewIdentifer:self atIndexPath:[NSIndexPath indexPathForItem:item inSection:0]] ;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
    }else {
        
        Class cellClass = [self cycleViewCustomCollectionViewCellClass];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
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
    
    //进行回调
    if ([self.dataSource respondsToSelector:@selector(cycleView:setupCustomCell:forIndex:)]) {
        [self.dataSource cycleView:self setupCustomCell:cell forIndex:[NSIndexPath indexPathForItem:item inSection:0]];
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
    
    // 进行注册
    if (self.hasCycleViewAllRegisterCellClasses) {
        // 所有注册的样式
        NSDictionary <NSString *, Class> *allRegisterCellClasses = [self.dataSource cycleViewAllRegisterCellClasses:self];
        //注册
        for (NSString *key in allRegisterCellClasses.allKeys) {
            [self.mainView registerClass:allRegisterCellClasses[key] forCellWithReuseIdentifier:key];
        }
    }else {
        Class cellClass = [self cycleViewCustomCollectionViewCellClass];
        [self.mainView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];//进行注册
    }
    
    [super setImagePathsGroup:imagePathsGroup];
    
    if (imagePathsGroup.count > 1 && !self.scrollable) { //只有当大于1个并且不允许手动滚动的时候才会设置
        self.contentView.scrollEnabled = self.scrollable;
    }
}


/// 是否存在 cycleViewAllRegisterCellClasses 方法
- (BOOL)hasCycleViewAllRegisterCellClasses {
    
    return [self.dataSource respondsToSelector:@selector(cycleViewAllRegisterCellClasses:)] && [self.dataSource cycleViewAllRegisterCellClasses:self] && [self.dataSource respondsToSelector:@selector(cycleViewIdentifer:atIndexPath:)];
}


- (void)layoutSubviews
{
    //记录原始itemSize
    [super layoutSubviews];

    [self updateMargin];
    [self updateCustomSize];
}


- (void)setupPageControl {}


/// 优化当前索引
- (NSInteger)currentIndex
{
    if ([self.dataSource respondsToSelector:@selector(cycleView:currentIndexWithContentOffset:)]) {
        
        NSInteger index =  [self.dataSource cycleView:self currentIndexWithContentOffset:self.mainView.contentOffset];
        
        return index < 0 ? [super currentIndex] : index;
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
    //如果存在自定义的flowLayout
    if ([self.dataSource respondsToSelector:@selector(cycleScollViewcustomCollectionViewLayout:)]) {
        if ([self.mainView.collectionViewLayout isKindOfClass:UICollectionViewFlowLayout.class]) {
            ((UICollectionViewFlowLayout *)self.mainView.collectionViewLayout).itemSize = self.customSize;
        }
    }
    
    if (![self.dataSource respondsToSelector:@selector(cycleViewShouldResetCollectionWithCustomScrollPosition:)]) { return; }
    [self updateCustomInitContentOffSet];
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

- (Class)cycleViewCustomCollectionViewCellClass
{
    return [self.dataSource cycleViewCustomCollectionViewCellClass:self];
}


@end
