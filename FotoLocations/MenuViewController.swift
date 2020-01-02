//
//  MenuViewController.swift
//  FotoLocations
//
//  Created by Marc Felden on 29/12/2019.
//  Copyright © 2019 madeTK.com. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftOverlays


struct DataSet:Codable {
    var uid:String
    var lat:Double
    var lon:Double
    var address:String
    var category:String
    var picurl:String
    var date:Date
}

class MenuViewController:UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate,PopupMessageProtocol {
    
    // image muesse vorliegen, ebenson location und bereich wurde gerade gewahlt.
    func popupMessagesOrSwiping(popupMessagesOrSwiping: PopupMessagesOrSwiping, didSelect: String) {

        
        if let uid = Auth.auth().currentUser?.uid {
            let values = [
                "uid":uid,
                "lat":self.location?.coordinate.latitude ?? 0,
                "lon":self.location?.coordinate.longitude ?? 0,
                "address":address ?? "N/A",
                "category":didSelect,
                "date":Date().timeIntervalSecondsSince1970,
                "picurl":imageUrl
                ] as [String : Any]
            Database.database().reference().child("data").child(uid).childByAutoId().updateChildValues(values)
        }
        popupMessagesOrSwiping.dismiss(animated: true)
        
    }
    

    
    
    let locationManager = CLLocationManager()
    var imageUrl:String!
    var address: String? {
        didSet {
            currentLocation?.text = address
        }
    }
    var location:CLLocation?
    
    @IBOutlet weak var currentLocation: UILabel!
    

    
    var dataSets = [DataSet]()
    
    override func viewDidLoad() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            // lade alle bisherigen Daten
            dataSets.removeAll()
            Database.database().reference().child("data").child(uid).observe(.value) { (snap) in
                self.dataSets.removeAll()
                for snap in snap.children {
                    if let snap = snap as? DataSnapshot {
                        if let dataset:DataSet = try!snap.decoded() {
                            self.dataSets.append(dataset)
                        }
                    }
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "eat":
            let destVC = segue.destination as! FotoListViewController
            destVC.dataSets = self.dataSets.filter({$0.category == "eat"})
            case "drink":
                let destVC = segue.destination as! FotoListViewController
                destVC.dataSets = self.dataSets.filter({$0.category == "drink"})
            case "shop":
                let destVC = segue.destination as! FotoListViewController
                destVC.dataSets = self.dataSets.filter({$0.category == "shop"})
            case "none":
                let destVC = segue.destination as! FotoListViewController
                destVC.dataSets = self.dataSets.filter({$0.category == "none"})
        case .none:
            let destVC = segue.destination as! FotoListViewController
            destVC.dataSets = self.dataSets.filter({$0.category == "eat"})
        case .some(_):
            let destVC = segue.destination as! FotoListViewController
            destVC.dataSets = self.dataSets.filter({$0.category == "eat"})
        }
    }
    
    @IBAction func takeFoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerController.SourceType.camera
        self.present(picker, animated: true, completion:nil)
    }
    

    
    // Photo Picker Stuff
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // Location Stuff
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if let location = locations.first {
            
            locationManager.stopUpdatingLocation()
            self.location = location
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                
               if error != nil {
                self.presentMessage(message: "Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if let pm = placemarks?.first {
                    
                    let street = pm.addressDictionary?["Street"] as? String ?? "Street N/A"
                    let zip = pm.addressDictionary?["ZIP"] as? String ?? ""
                    let city = pm.addressDictionary?["City"] as? String ?? ""
                    let countryCode = pm.addressDictionary?["CountryCode"] as? String ?? ""
                    let region = pm.administrativeArea ?? ""
                    let y = pm.administrativeArea ?? ""
                    let country = pm.country ?? ""
                    self.address = "\(street), \(city), \(region), \(country)"
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
  //      SwiftOverlays.showBlockingTextOverlay("saving picture...")
        
        
        picker.dismiss(animated: true, completion:nil)
        // speicher image, show bereichs popup und dann speicher das ganze zeug
        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        savePic(image: image) { (downloadUrl) in
            self.imageUrl = downloadUrl
                    let destVC = UIViewController.instantiate(.Main, PopupMessagesOrSwiping.self)
            destVC.modalPresentationStyle = .overCurrentContext
            destVC.delegate = self
            DispatchQueue.main.async {
                            self.present(destVC, animated: true, completion: nil)
                            
                //            SwiftOverlays.removeAllBlockingOverlays()
            }

        }
    }
    
    private func savePic(image:UIImage, completion: @escaping (_ urlString: String?) -> Void) {
        let compressedImgData = compressImageLikeWhatsAppAsData(image: image)
        let picuid = NSUUID().uuidString
        if let uid = Auth.auth().currentUser?.uid {
            let storageRef = Storage.storage().reference().child("\(uid)/\(picuid).jpg")
            storageRef.putData(compressedImgData, metadata: nil) { (_, err) in

                if err != nil {
                    self.presentMessage(message: err!.localizedDescription)
                    print("\(err!.localizedDescription) occured saving Foto")
                    return
                }
                storageRef.downloadURL { (url, _) in
                    guard let downloadURL = url else {
                        print("ERROR: Probably you do not have permissions to write")
                        return
                    }
                    let urlString = downloadURL.absoluteString
                    completion(urlString)
                }
            }
        } else {
            presentMessage(message: "Error with UID")
        }

    }
    

}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

func compressImageLikeWhatsAppAsData(image:UIImage) -> Data {
    var actualHeight = image.size.height
    var actualWidth = image.size.width
    let maxHeight:CGFloat = 600
    let maxWidth:CGFloat = 800
    var imgRatio = actualWidth / actualHeight
    let maxRatio = maxWidth / maxHeight
    let compressionQuality = 0.7
    if actualHeight > maxHeight || actualWidth > maxWidth {
        if imgRatio < maxRatio {
            imgRatio = maxHeight / actualHeight
            actualWidth = imgRatio * actualWidth
            actualHeight = maxHeight
        } else if imgRatio > maxRatio {
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth
        } else {
            actualHeight = maxHeight
            actualWidth = maxWidth
            
        }
    }
    let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 1.0)
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()!
    let imageData = img.jpegData(compressionQuality: CGFloat(compressionQuality))
    //   let size = Int([UInt8](UIImagePNGRepresentation(imageView.image!)!).count/1024)
    print("Image Size After compression:\(imageData!.count/1024)KB")
    return imageData!
}



extension UIStoryboard {
    enum Name: String {
        case Main
        case Onboarding
        case Chat
        case Filter
        case PhotoAlbums
        case Purchase
        case Likes
        case Favs
        case PopUps
    }
}

extension UIViewController {
    static func instantiate<ViewController: UIViewController>(_ storyboardName: UIStoryboard.Name,
                                                              _ viewControllerType: ViewController.Type) -> ViewController {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: ViewController.self)) as! ViewController
    }
}
extension Date {
    var timeIntervalSecondsSince1970:Int {
        let ti = Int(self.timeIntervalSince1970)
        return ti
    }
    var timeIntervalMilliSecondsSince1970:Int {
        let ti = Int(self.timeIntervalSince1970*1000)
        return ti
    }
    var toYYYMMDDforUTC:String {
        let today = self
        
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd"
        let date = df.string(from: today)
        return date
    }
}
