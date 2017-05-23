//
//  ViewController_UICollectionViewDataSource.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/23/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrYear.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearCollectionViewCell.identifier(), for: indexPath) as! YearCollectionViewCell
        
        cell.setYearLabelText(text: String(arrYear[indexPath.row]))
        cell.setYearLabelColor(color: UIColor.lightGray)
        cell.setIndicatorViewColor(color: UIColor.white)
        
        if firstYearCollectionView {
            if indexPath.row == 0 {
                cell.setIndicatorViewColor(color: UIColor.red)
            }
            firstYearCollectionView = false
        }
        
        if indexPath == indexPathSelected {
            cell.setYearLabelColor(color: UIColor.black)
            cell.setIndicatorViewColor(color: UIColor.red)
        }
        
        return cell
    }
}
