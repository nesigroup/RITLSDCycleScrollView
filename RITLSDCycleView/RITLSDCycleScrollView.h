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

/// 自定义的collectionView类
- (Class <RITLSDCycleScrollViewCell>)customCollectionViewCellClassForCycleScrollView;


@optional

/// 自定义cell的赋值，否则只对imageView自动赋值
- (void)cycleView:(RITLSDCycleScrollView *)cycleView
  setupCustomCell:(UICollectionViewCell<RITLSDCycleScrollViewCell>*)cell
         forIndex:(NSIndexPath *)indexPath;

/// 自定义的collectionViewLayout对象
- (UICollectionViewLayout *)customCollectionViewLayoutForCycleScollViwe;

@end


/// custom SDCycleScrollView
@interface RITLSDCycleScrollView : SDCycleScrollView

/// 是否分页
@property (nonatomic, assign)BOOL pageEnable;

/// 数据源
@property (nonatomic, weak, nullable) id<RITLSDCycleScrollViewDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
