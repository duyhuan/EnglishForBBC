//
//  ViewController_UICollectionViewDelegate.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/23/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YearCollectionViewCell {
            if indexPath != indexPathSelected {
                startAnimating()
                cell.setIndicatorViewColor(color: UIColor.red)
                cell.setYearLabelColor(color: UIColor.black)
                year = arrYear[indexPath.row]
                self.getData()
                indexPathSelected = indexPath
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                    collectionView.reloadData()
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YearCollectionViewCell {
            cell.setIndicatorViewColor(color: UIColor.white)
            cell.setYearLabelColor(color: UIColor.lightGray)
        }
    }
}
