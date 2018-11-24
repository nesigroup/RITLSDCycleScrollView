//
//  RITLShakePageControl.h
//  NongWanCloud
//
//  Created by YueWen on 2017/12/27.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 原作者:   https://github.com/popwarsweet/PageControls
/// 语言:     Swift

#pragma mark - RITLS

NS_ASSUME_NONNULL_BEGIN

@interface RITLShakePageControl : UIView

#pragma mark - PageControl

/// 页码，默认为 0
@property (nonatomic, assign)NSInteger pageCount;

/// 进度，默认为 0
@property (nonatomic, assign)CGFloat progress;

/// 当前页码
@property (nonatomic, assign, readonly)NSInteger currentPage;

#pragma mark - Appearance

/// 高亮颜色
@property (nonatomic, strong) UIColor *activeTint;//默认为 white
/// 正常颜色
@property (nonatomic, strong) UIColor *inactiveTint;//默认为 white 0.3
/// dot的间距
@property (nonatomic, assign) CGFloat indicatorPadding;//默认为 10
/// dot的圆角
@property (nonatomic, assign) CGFloat indicatorRadius;//默认为 5


@end

NS_ASSUME_NONNULL_END
