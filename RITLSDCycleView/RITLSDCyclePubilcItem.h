//
//  SDCyclePubilcItem.h
//  NongWanCloud
//
//  Created by YueWen on 2018/1/4.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDCycleScrollView/SDCycleScrollView.h>

#pragma mark - RITLS

NS_ASSUME_NONNULL_BEGIN

/// 对外暴露`SDCycleScrollView`的属性及方法
@protocol RITLSDCyclePubilcItem <NSObject>

@property (nonatomic, copy) NSArray *imagePathsGroup;
@property (nonatomic, strong) UICollectionView *mainView;
@property (nonatomic, strong) UIView *pageControl;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end


@interface SDCycleScrollView (SDCyclePubilcItem)<RITLSDCyclePubilcItem,UICollectionViewDataSource>

@end

NS_ASSUME_NONNULL_END
