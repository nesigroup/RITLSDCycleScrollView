//
//  CSDCycleScrollView.m
//  NongWanCloud
//
//  Created by YueWen on 2018/1/9.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "RITLSDCycleScrollView.h"
#import <UIImageView+WebCache.h>


@implementation RITLSDCycleScrollView

- (void)setDataSource:(id<RITLSDCycleScrollViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    if (dataSource) {
        
        // 注册cell
        [self.mainView registerClass:[self.dataSource customCollectionViewCellClassForCycleScrollView] forCellWithReuseIdentifier:NSStringFromClass([self.dataSource customCollectionViewCellClassForCycleScrollView])];
    }
    
    if ([dataSource respondsToSelector:@selector(customCollectionViewLayoutForCycleScollViwe)]) {
        
        self.mainView.collectionViewLayout = [self.dataSource customCollectionViewLayoutForCycleScollViwe];
    }
}


#pragma mark - override

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.dataSource) {
        
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    Class <RITLSDCycleScrollViewCell> cellClass = [self.dataSource customCollectionViewCellClassForCycleScrollView];
    
    
    UICollectionViewCell <RITLSDCycleScrollViewCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
    
    NSString *imagePath = self.imagePathsGroup[indexPath.item];
    
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
        
        [self.dataSource cycleView:self setupCustomCell:cell forIndex:indexPath];
    }
    
    return cell;
}



- (void)setImagePathsGroup:(NSArray *)imagePathsGroup
{
    if (!self.dataSource) {
        
        [super setImagePathsGroup:imagePathsGroup]; return;
    }
    
    Class <RITLSDCycleScrollViewCell> cellClass = [self.dataSource customCollectionViewCellClassForCycleScrollView];
    
    //进行注册
    [self.mainView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    
    [super setImagePathsGroup:imagePathsGroup];

}


- (void)setPageEnable:(BOOL)pageEnable
{
    self.mainView.pagingEnabled = pageEnable;
}

- (BOOL)pageEnable
{
    return self.mainView.pagingEnabled;
}


@end
