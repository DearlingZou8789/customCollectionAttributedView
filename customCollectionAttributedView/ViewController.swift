//
//  ViewController.swift
//  customCollectionAttributedView
//
//  Created by zmj27404 on 03/04/2017.
//  Copyright © 2017 zmj27404. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    var myCollectionView: UICollectionView!
    var xmCustomAttributed = XMCustomAttributedLayout.init()
    var xmCustomAttributed3D = XMCustomAttributed3DLayout.init()
    
    var resultArray = [UIColor]()
    let cellID = "UICollectionViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        initNavigationItem()
        initSubView()
        initDatas()
    }
    
    func initNavigationItem() {
        let rightItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(changeCollectionAttributedItem))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func initSubView() {
//        self.myCollectionView = UICollectionView.init(frame: CGRect.init(x: 30, y: 30, width: self.view.frame.width - 60, height: 100), collectionViewLayout: self.xmCustomAttributed)
        self.myCollectionView = UICollectionView.init(frame: CGRect.init(x: 30, y: 30, width: self.view.frame.width - 60, height: 100), collectionViewLayout: self.xmCustomAttributed3D)
        self.view.addSubview(self.myCollectionView)
        self.myCollectionView.backgroundColor = UIColor.white
        self.myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        self.myCollectionView.dataSource = self
        self.myCollectionView.showsVerticalScrollIndicator = false
        self.myCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    func createCollectionViewCell() {
        let cell = UICollectionViewCell.init(frame: CGRect.init(x: 10, y: 150, width: 200, height: 100))
//        cell.contentView.layer.shadowOffset = CGSize.init(width: 10, height: 10)
        cell.contentView.layer.shadowRadius = 5.0
        cell.contentView.layer.shadowColor = UIColor.red.cgColor
        cell.contentView.layer.shadowPath = UIBezierPath.init(rect: cell.bounds).cgPath
        cell.contentView.layer.shadowOpacity = 0.8
        cell.contentView.backgroundColor = UIColor.gray
        self.view.addSubview(cell)
    }
    
    func initDatas() {
        for _ in 0...20 {
            let color = UIColor.init(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1.0)
            self.resultArray.append(color)
        }
        self.myCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resultArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        configureCell(cell, self.resultArray[indexPath.row])
        if cell.contentView.subviews.count == 0 {
            let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 30))
            label.center = CGPoint.init(x: cell.contentView.frame.width / 2.0, y: cell.contentView.frame.height / 2.0)
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = UIColor.black
            cell.contentView.addSubview(label)
        }
        let label = cell.contentView.subviews.last as! UILabel
        label.text = "\(indexPath.row)"
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, _ color: UIColor) {
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.backgroundColor = color
        cell.contentView.layer.masksToBounds = false
        if self.myCollectionView.collectionViewLayout == self.xmCustomAttributed {
            cell.contentView.layer.borderWidth = 2.0
            cell.contentView.layer.borderColor = UIColor.black.cgColor
        }
        else if self.myCollectionView.collectionViewLayout == self.xmCustomAttributed3D {
            cell.contentView.layer.shadowOffset = CGSize.init(width: 10, height: 10)
            cell.contentView.layer.shadowRadius = 10.0
            cell.contentView.layer.shadowColor = color.withAlphaComponent(0.3).cgColor
            cell.contentView.layer.shadowPath = UIBezierPath.init(rect: cell.bounds).cgPath
            cell.contentView.layer.shadowOpacity = 1.0
        }
    }
    
    func changeCollectionAttributedItem() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

