//
//  XMCustomAttributed.swift
//  customCollectionAttributedView
//
//  Created by zmj27404 on 03/04/2017.
//  Copyright © 2017 zmj27404. All rights reserved.
//

import UIKit

class XMCustomAttributedLayout: UICollectionViewLayout {
    let ShowCellNumber = 3
    var collectionViewWidth: CGFloat = 0.0
    var XMLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        self.collectionViewWidth = (self.collectionView?.frame.width)!

        let numbers = self.collectionView?.numberOfItems(inSection: 0)
        if let numbers = numbers {
            for i in 0..<numbers {
                self.XMLayoutAttributes.append(layoutAttributesForItem(at: IndexPath.init(item: i, section: 0))!)
            }
        }
    }
    
    var EachWidth: CGFloat {
        let width = self.collectionViewWidth
        let eWidth = width / CGFloat(self.ShowCellNumber)
        return eWidth
    }
    
    var EachHeight = 100.0
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        let number = self.collectionView?.numberOfItems(inSection: 0)
        let size = CGSize.init(width: Double(self.EachWidth * CGFloat(number!)), height: self.EachHeight)
        return size
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("indexPath = \(indexPath)")
        let layoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        let width = self.EachWidth
        layoutAttributes.frame = CGRect.init(x: Double(width) * Double(indexPath.row), y: 0.0, width: Double(width), height: Double((self.collectionView?.frame.height)!))
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let array = indexPathsForRect(rect)
        var layoutArray = [UICollectionViewLayoutAttributes]()
        array.forEach{
            layoutArray.append(layoutAttributesForItem(at: $0)!)
        }
        let center = CGPoint.init(x: (self.collectionView?.contentOffset.x)! + ((self.collectionView?.frame.width)! / 2.0), y: (self.collectionView?.frame.height)! / 2.0)
        
        //  布局核心逻辑
        layoutArray.forEach({ (layoutAttribute) in
            var scale = (center.x - layoutAttribute.center.x) / ((self.collectionView?.frame.width)! / 2.0)
            scale = (1 - fabs(scale * 0.1))
            layoutAttribute.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        })
        return layoutArray
    }
    
    func indexPathsForRect(_ rect: CGRect) -> Array<IndexPath> {
        let minx = max(0, Int(rect.minX / self.EachWidth) )
        let maxx = min((self.collectionView?.numberOfItems(inSection: 0))! - 1, Int(rect.maxX / self.EachWidth))
        print("rect = \(rect), eachWidth = \(self.EachWidth), minx = \(minx), maxx = \(maxx)")
        var array = Array<IndexPath>()
        
        for i in minx...maxx {
            array.append(IndexPath.init(row: i, section: 0))
        }
        return array
    }
    
    //  当滚动停止时，proposedContentOffset是此时的collectionView的偏移量
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rect = CGRect.init(x: proposedContentOffset.x, y: proposedContentOffset.y, width: (self.collectionView?.frame.width)!, height: (self.collectionView?.frame.height)!)
        let attributes = layoutAttributesForElements(in: rect)
        let centerX = proposedContentOffset.x + 0.5 * (self.collectionView?.frame.width)!
        var minOffsetX = CGFloat.greatestFiniteMagnitude
        attributes?.forEach{
            //  找到attributes中中心点与当前rect中的中心点最接近的偏移量，移动到此即可
            let offsetX = $0.center.x - centerX
            if abs(offsetX) < abs(minOffsetX) {
                minOffsetX = offsetX
            }
        }
        return CGPoint.init(x: proposedContentOffset.x + minOffsetX, y: proposedContentOffset.y)
    }
}
