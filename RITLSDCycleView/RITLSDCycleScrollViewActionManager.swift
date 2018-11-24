//
//  RITLSDCycleScrollViewActionManager.swift
//  CoworkClient
//
//  Created by YueWen on 2018/10/24.
//  Copyright © 2018 YueWen. All rights reserved.
//

import UIKit

/// 方便管理 RITLSDCycleScrollViewDataSource 的结构体
class RITLSDCycleScrollViewActionManager<Cell : UICollectionViewCell & RITLSDCycleScrollViewCell> :NSObject, RITLSDCycleScrollViewDataSource, SDCycleScrollViewDelegate  {

    
    // MARK: source
    /// 自定义的信息
    var customInfo: (Cell,IndexPath)->() = {_,_ in }
    /// 是否使用scrollPosition
    var isScrollPosition: Bool = false
    /// 滚动方式
    var scrollPosition: UICollectionView.ScrollPosition = []
    /// 布局参数
    var flowLayout: UICollectionViewLayout = UICollectionViewLayout()
    /// 根据偏移量返回当前的位置
    var index: (CGPoint)->(Int) = { _ in return -1 }
    
    // MARK: delegate
    /// 滚动到位置
    var scroll: (Int)->() = {_ in }
    /// 选择位置
    var select: (Int)->() = {_ in }
    
    override init() {
        super.init()
    }
    
    // MARK: RITLSDCycleScrollViewDataSource
    
    func cycleViewCustomCollectionViewCellClass(_ cycleView: RITLSDCycleScrollView) -> AnyClass {
        return Cell.self
    }
    
    
    func cycle(_ cycleView: RITLSDCycleScrollView, setupCustomCell cell: UICollectionViewCell & RITLSDCycleScrollViewCell, forIndex indexPath: IndexPath) {
        customInfo(cell as! Cell,indexPath)
    }
    
    
    func cycleScollViewcustomCollectionViewLayout(_ cycleView: RITLSDCycleScrollView) -> UICollectionViewLayout {
        return flowLayout
    }
    
    
    func cycleViewShouldResetCollection(withCustomScrollPosition cycleView: RITLSDCycleScrollView) -> Bool {
        return isScrollPosition
    }
    
    
    func cycleViewCustomCollectionViewScrollPosition(_ cycleView: RITLSDCycleScrollView) -> UICollectionView.ScrollPosition {
        return scrollPosition
    }
    
    
    func cycle(_ cycleView: RITLSDCycleScrollView, currentIndexWithContentOffset contentOffset: CGPoint) -> Int {
        return index(contentOffset)
    }
    
    // MARK: SDCycleScrollViewDelegate
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {
        scroll(index)
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        select(index)
    }
}


/// 装载 RITLSDCycleScrollView
protocol RITLSDCycleScrollViewContainer {
    
    associatedtype RITLSDCycleScrollViewType: RITLSDCycleScrollView
    var cycleView: RITLSDCycleScrollViewType { get }
}


extension RITLSDCycleScrollViewContainer {
    
    /// 初始化标签以及滚动视图属性
    func buildCycleView(contentView: UIView){
        cycleView.autoScroll = false
        cycleView.pageEnable = false
        cycleView.infiniteLoop = false
        cycleView.showPageControl = false
        cycleView.backgroundColor = .white
        
        contentView.addSubview(cycleView)

    }
}


protocol RITLSDCycleScrollViewDataSourceManagerContainer {
    
    associatedtype CellType: UICollectionViewCell & RITLSDCycleScrollViewCell
    var cycleManager: RITLSDCycleScrollViewActionManager<CellType> { get }
}


extension RITLSDCycleScrollViewContainer where Self: RITLSDCycleScrollViewDataSourceManagerContainer {
    
    /// 使用 RITLSDCycleScrollViewDataSourceManager
    func useScrollViewDataSourceManager(isDataSource: Bool = true,isDelegate: Bool = true){
        
        if isDelegate {
            cycleView.delegate = cycleManager
        }
        if isDataSource {
            cycleView.dataSource = cycleManager
        }
    }
}

