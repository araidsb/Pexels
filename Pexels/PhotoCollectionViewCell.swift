//
//  PhotoCollectionViewCell.swift
//  Pexels
//
//  Created by Арай Дуйсебекова on 20.07.2023.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "PhotoCollectionViewCell"
    var photo: Photo?

    @IBOutlet weak var imageViewHolder: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewHolder.image = UIImage(named: "photoHolder2")
    }
    
    func setup(photo: Photo) {
        self.photo = photo
        
        let mediumPhotoURLString: String = photo.src.medium
        guard let meidumPhotoURL = URL(string: mediumPhotoURLString) else {
            print("Couldn't create URL with given mediumPhotoURLString:  \(mediumPhotoURLString)")
            return
        }
        
        self.activityIndicator.startAnimating()
        
        let dataTask = URLSession.shared.dataTask(with: meidumPhotoURL, completionHandler: imageLoadCompletionHandler(data:urlResponse:error:))
        dataTask.resume()
    }
    
    func imageLoadCompletionHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        if urlAreSame(responseURL: urlResponse?.url?.absoluteString) {
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
        if let error = error {
            
            print(" Error loading image: \(error.localizedDescription)")
            
        } else if let data = data {
            
            guard urlAreSame(responseURL: urlResponse?.url?.absoluteString) else {
                return
            }
            DispatchQueue.main.async {
                self.imageViewHolder.image = UIImage(data: data)
            }
        }
    }
    
    func urlAreSame(responseURL: String?) -> Bool {
        guard let currentPhotoURL = self.photo?.src.medium, let responseURL = responseURL else {
            print("current photo url OR response url are absent")
            return false
        }
        
        guard currentPhotoURL == responseURL else {
            print("ATTETNTION currentPhotoURL  and reponseURL are diffreent!")
            return false
        }
        return true
    }
}
