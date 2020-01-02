//
//  FotoListViewController.swift
//  FotoLocations
//
//  Created by Marc Felden on 29/12/2019.
//  Copyright © 2019 madeTK.com. All rights reserved.

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Kingfisher


class FotoListViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView:UICollectionView!
    var section:String!
    var fotoInfos = [FotoInfo]()
    
    
    var dataSets = [DataSet]()
    
    override func viewDidLoad() {

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Number of fotos:\(dataSets.count)")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FotoCell
        cell.image.kf.setImage(with: URL(string: dataSets[indexPath.row].picurl))
        cell.date.text =  dataSets[indexPath.row].date.prettyPrinted_yyyy_mm_dd_hh_mm
        return cell
    }
    
    
    
}

class FotoCell:UICollectionViewCell {
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var date:UILabel!
    
    
}

struct FotoInfo:Codable {
    var url:String!
    var date:Date!
    var address:String?
    var latitude:Double?
    var longitude:Double?
}

extension Date {
    var prettyPrinted_yyyy_mm_dd_hh_mm:String  {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:MM"
        return df.string(from: self)
    }
}
