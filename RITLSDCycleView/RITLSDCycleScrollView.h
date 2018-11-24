//
//  CSDCycleScrollView.h
//  NongWanCloud
//
//  Created by YueWen on 2018/1/9.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import <SDCycleScrollView/SDCycleScrollView.h>
#import "RITLSDCyclePubilcItem.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RITLS

@class RITLSDCycleScrollView;

@protocol RITLSDCycleScrollViewCell

/// 显示图片的imageView
@property (nonatomic, strong, readonly) UIImageView *imageView;

@end



@protocol RITLSDCycleScrollViewDataSource <NSObject>

//
///**
// 自定义的collectionView类
// 作为cell的类必须履行<RITLSDCycleScrollViewCell>
//
// 即将废弃，建议使用cycleViewCustomCollectionViewCellClass:
//
// @return 履行<RITLSDCycleScrollViewCell>的类
// */
//- (Class <RITLSDCycleScrollViewCell>)customCollectionViewCellClassForCycleScrollView;
//

/**
 自定义的collectionView类
 作为cell的类必须履行<RITLSDCycleScrollViewCell>

 @param cycleView 执行回调的轮播视图
 @return 履行<RITLSDCycleScrollViewCell>的类
 */
- (Class)cycleViewCustomCollectionViewCellClass:(RITLSDCycleScrollView *)cycleView;


@optional

/**
 自定义cell的赋值，否则只对imageView自动赋值

 @param cycleView 执行回调的轮播视图
 @param cell 执行回调进行处理的cell
 @param indexPath cell所在的位置
 */
- (void)cycleView:(RITLSDCycleScrollView *)cycleView
  setupCustomCell:(UICollectionViewCell<RITLSDCycleScrollViewCell>*)cell
         forIndex:(NSIndexPath *)indexPath;

///**
// 自定义的collectionViewLayout对象
// 
// 即将废弃，建议使用cycleScollViewcustomCollectionViewLayout:
//
// @return 自定义的UICollectionViewLayout对象
// */
//- (UICollectionViewLayout *)customCollectionViewLayoutForCycleScollView;


/**
 自定义的collectionViewLayout对象

 @param cycleView 执行回调的轮播视图
 @return 自定义的UICollectionViewLayout对象
 */
- (UICollectionViewLayout *)cycleScollViewcustomCollectionViewLayout:(RITLSDCycleScrollView *)cycleView;

/**
 自定义的collectionViewLayout对象时，附带的滚动位置方式
 默认为UICollectionViewScrollPositionNone
 
 @param cycleView 执行回调的轮播视图
 @return 位移方式
 */
- (UICollectionViewScrollPosition)cycleViewCustomCollectionViewScrollPosition:(RITLSDCycleScrollView *)cycleView ;

/**
 自定义的collectionViewLayout对象时，附带的轮播计算方式

 @param cycleView 执行回调的轮播视图
 @param contentOffset 滚动视图的偏移量
 @return 当前自己计算的页码
 */
- (NSInteger)cycleView:(RITLSDCycleScrollView *)cycleView currentIndexWithContentOffset:(CGPoint)contentOffset;

/**
 是否根据自定义后的UICollectionViewScrollPosition进行重新设置
 默认为false
 
 @param cycleView 执行回调的轮播视图
 @return true表示根据自定义的flowlayout进行重新layout
 */
- (BOOL)cycleViewShouldResetCollectionWithCustomScrollPosition:(RITLSDCycleScrollView *)cycleView;



@end

extern CGFloat RITLSDCycleScrollViewPageSpaceDefault;


/// custom SDCycleScrollView
@interface RITLSDCycleScrollView : SDCycleScrollView

/// 距离底边距，绝对底边距，默认为RITLSDCycleScrollViewPageSpaceDefault
@property (nonatomic, assign)CGFloat pageControlMarginBottom;
/// 距离右侧边距，绝对右侧边距，默认为RITLSDCycleScrollViewPageSpaceDefault
@property (nonatomic, assign)CGFloat pageControlMarginRight;

/// 重写layoutsubview时子类调用
- (void)updateMargin;

/// 是否分页
@property (nonatomic, assign)BOOL pageEnable;
/// 数据源
@property (nonatomic, weak, nullable) id<RITLSDCycleScrollViewDataSource> dataSource;
/// 滚动的集合视图
@property (nonatomic, weak, readonly)UICollectionView *contentView;

@end

NS_ASSUME_NONNULL_END
