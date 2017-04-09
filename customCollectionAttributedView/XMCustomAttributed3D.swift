//
//  XMCustomAttributed3D.swift
//  customCollectionAttributedView
//
//  Created by zmj27404 on 03/04/2017.
//  Copyright © 2017 zmj27404. All rights reserved.
//

import UIKit

struct IndexOffset {
    var row: Int = 0
    var offsetX: CGFloat = 0
}

class XMCustomAttributed3DLayout: UICollectionViewLayout {
    let ShowCellNumber = 3
    var collectionViewWidth: CGFloat = 0.0
    let interWidthScale = 0.5
    var edgetInsert: UIEdgeInsets = UIEdgeInsets.init(top: 5, left: 0, bottom: 5, right: 0)
    //  该值不宜超过0.3
    var rotateScale:CGFloat = 0.5
    
    
    var XMLayoutAttributes = [Int: UICollectionViewLayoutAttributes]()
    
    //  这里竟然在shouldInvalidateLayout方法为NO时，还需要再次计算
    override func prepare() {
        super.prepare()
        self.collectionViewWidth = (self.collectionView?.frame.width)!
//
//        let numbers = self.collectionView?.numberOfItems(inSection: 0)
//        if let numbers = numbers {
//            for i in 0..<numbers {
//                self.XMLayoutAttributes.append(layoutAttributesForItem(at: IndexPath.init(item: i, section: 0))!)
//            }
//        }
    }
    
    var EachWidth: CGFloat {
        let width = self.collectionViewWidth - self.edgetInsert.left - self.edgetInsert.right
        let eWidth = width / CGFloat(self.ShowCellNumber - 1)
        return eWidth
    }
    
    var EachHeight: CGFloat = 100.0
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let flag = !newBounds.size.equalTo(self.collectionViewContentSize)
        return flag
    }
    
    override var collectionViewContentSize: CGSize {
        let number = self.collectionView?.numberOfItems(inSection: 0)
        let size = CGSize.init(width: Double(self.EachWidth * CGFloat(number!)) - self.interWidthScale * Double(self.EachWidth) * Double(number! - 1) + Double(self.edgetInsert.right), height: Double(self.EachHeight))
        return size
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.XMLayoutAttributes[indexPath.row] != nil {
            return self.XMLayoutAttributes[indexPath.row]
        }
        print("indexPath = \(indexPath)")
        let layoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        let width = self.EachWidth
        layoutAttributes.frame = CGRect.init(x: Double(width) * Double(indexPath.row) * interWidthScale + Double(self.edgetInsert.left), y: Double(self.edgetInsert.top), width: Double(width), height: Double(self.collectionViewContentSize.height - self.edgetInsert.top - self.edgetInsert.bottom))
        self.XMLayoutAttributes[indexPath.row] = layoutAttributes
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //  我也很奇怪，为啥rect跟self.collectionView.bounds不一样
        //  这里设置采用self.collectionView.bounds就只针对当前页面显示的布局，其他不关系
        let array = indexPathsForRect((self.collectionView?.bounds)!)
        var layoutArray = [UICollectionViewLayoutAttributes]()
        array.forEach{
            layoutArray.append(layoutAttributesForItem(at: $0)!)
        }

        let center = CGPoint.init(x: (self.collectionView?.contentOffset.x)! + ((self.collectionView?.frame.width)! / 2.0), y: (self.collectionView?.frame.height)! / 2.0)

        #if true
            //  布局核心逻辑
            var i = 0
            var rowOffset = IndexOffset.init(row: i, offsetX: CGFloat.greatestFiniteMagnitude)
            
            layoutArray.forEach({ (layoutAttribute) in
                let xy = (center.x - layoutAttribute.center.x)
                let scale = xy / self.EachWidth
                let fabsScale = fabs(scale)
                
                var scaleY = 1 - fabsScale * self.rotateScale
                if (scale > 0) {
                    scaleY = -scaleY
                }
                
                if rowOffset.offsetX >= fabs(xy) {
                    rowOffset.offsetX = fabs(xy)
                    rowOffset.row = i
                }
                
                //  3D Rotate
                var t: CATransform3D = CATransform3DIdentity
                t.m34 = 1 / -400
                t = CATransform3DRotate(t, (1 + scaleY) * CGFloat(Double.pi), 0.0, 1.0, 0.0)
                layoutAttribute.transform3D = t
                i = i + 1
            })
            
            //  最小值居中，旋转为0
            print("rowOffset = \(rowOffset)")
            let centerLayoutAttribute = layoutArray[rowOffset.row]
            centerLayoutAttribute.transform3D = CATransform3DIdentity
            
        #endif
        return layoutArray
    }
    
    func indexPathsForRect(_ rect: CGRect) -> Array<IndexPath> {
//        print("rect = \(rect), self.collectionView.bounds = \(String(describing: self.collectionView?.bounds))")
        let eachScaleWidth = self.EachWidth * CGFloat(self.interWidthScale)
        let minx = max(0, Int((rect.minX + self.edgetInsert.left) / eachScaleWidth))
        let maxx = min((self.collectionView?.numberOfItems(inSection: 0))!, Int((rect.maxX - self.edgetInsert.right) / eachScaleWidth))
        print("rect = \(rect), eachWidth = \(self.EachWidth), minx = \(minx), maxx = \(maxx)")
        var array = Array<IndexPath>()
        
        for i in minx..<maxx {
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
    
    func roundfloat(_ floatScale: CGFloat) -> Int {
        let intFloat = Int(floatScale)
        
        if floatScale >= CGFloat(intFloat) + 0.5 {
            return intFloat + 1
        }
        else {
            return intFloat
        }
    }
}
