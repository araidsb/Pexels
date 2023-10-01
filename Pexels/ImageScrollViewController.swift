//
//  ImageViewController.swift
//  Pexels
//
//  Created by Арай Дуйсебекова on 25.07.2023.
//

import UIKit

class ImageScrollViewController: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let imageURL: String
    init(imageURL: String) {
        self.imageURL = imageURL
        super.init(nibName: "ImageScrollViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImage()
        scrollView.delegate = self
        

        // Do any additional setup after loading the view.
    }
    func loadImage() {
        guard let url = URL(string: imageURL) else {
            print("Couldn't create url instance with image url \(imageURL)")
            return
        }
        self.activityIndicator.startAnimating()
        
        let dataTask = URLSession.shared.dataTask(with: url,completionHandler: (completionHandler(data:urlResponse:error:)))
        dataTask.resume()
    }
    
    func completionHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
        if let error = error {
            print("Image loading error:\(error.localizedDescription)")
        } else if let data = data {
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}

extension ImageScrollViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
