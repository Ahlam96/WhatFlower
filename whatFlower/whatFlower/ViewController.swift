//
//  ViewController.swift
//  whatFlower
//
//  Created by احلام المطيري on 27/12/2019.
//  Copyright © 2019 احلام المطيري. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    let Pickerimage = UIImagePickerController()
    
    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        Pickerimage.delegate = self
         Pickerimage.allowsEditing = true
        Pickerimage.sourceType = .camera
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if  let userpickedimage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            guard let ciImage = CIImage(image: userpickedimage) else{
                fatalError("couldnot convert image to ciimage")
            }
          
            detect(image: ciImage)
            imageview.image = userpickedimage
        
        Pickerimage.dismiss(animated: true, completion: nil)
    }
    
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else{
            fatalError("can not import model")
        }
        let request = VNCoreMLRequest(model: model){ (request, error) in
            
            guard  let classification = request.results?.first as? VNClassificationObservation else{
                fatalError("could not classify image")
            }
            
            self.navigationItem.title = classification.identifier.capitalized
            self.requestInfo(flowerName: classification.identifier)
        }
        
        let handeler = VNImageRequestHandler(ciImage: image)
        do{
            try handeler.perform([request])
        }
        catch{
            print (error)
        }
    }
    
    func requestInfo(flowerName: String){
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts",
        "exintro" : "",
        "explaintext" : "",
        "titles" : flowerName,
        "indexpageids" : "",
        "redirects" : "1",
        ]
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON{
            (response) in
            if response.result.isSuccess {
                
                print("got the wikipedia info")
                print(response)
                
                let flowerJSON :JSON = JSON(response.result.value)
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                self.label.text = flowerDescription
                
            }
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(Pickerimage, animated: true, completion: nil)
    }
    
}

