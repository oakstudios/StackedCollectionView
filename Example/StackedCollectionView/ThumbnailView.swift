//
//  ThumbnailView.swift
//
//  Copyright © 2018 Oak, LLC (https://oak.is)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class ThumbnailView: UIView {
    
    var imageSpacing: CGFloat = 2.0
    
    var images: [UIImage]? {
        didSet {
            
            let count = images?.count ?? 0
            
            if count == 1 {
                
                // Hide/Show views
                imageView.isHidden = false
                
                topImageView.isHidden = true
                bottomImageView.isHidden = true
                
                topLeftImageView.isHidden = true
                topRightImageView.isHidden = true
                bottomLeftImageView.isHidden = true
                bottomRightImageView.isHidden = true
                
                // Set image
                imageView.image = images![0]
                
            } else if count == 2 {
                
                // Hide/Show views
                imageView.isHidden = true
                
                topImageView.isHidden = false
                bottomImageView.isHidden = false
                
                topLeftImageView.isHidden = true
                topRightImageView.isHidden = true
                bottomLeftImageView.isHidden = true
                bottomRightImageView.isHidden = true
                
                // Set image
                topImageView.image = images![0]
                bottomImageView.image = images![1]
                
            } else if count == 3 {
                
                // Hide/Show views
                imageView.isHidden = true
                
                topImageView.isHidden = false
                bottomImageView.isHidden = true
                
                topLeftImageView.isHidden = true
                topRightImageView.isHidden = true
                bottomLeftImageView.isHidden = false
                bottomRightImageView.isHidden = false
                
                // Set image
                topImageView.image = images![0]
                bottomLeftImageView.image = images![1]
                bottomRightImageView.image = images![2]
                
            } else if count >= 4 || count == 0 {
                
                // Hide/Show views
                imageView.isHidden = true
                
                topImageView.isHidden = true
                bottomImageView.isHidden = true
                
                topLeftImageView.isHidden = false
                topRightImageView.isHidden = false
                bottomLeftImageView.isHidden = false
                bottomRightImageView.isHidden = false
                
                // Set image
                topLeftImageView.image = count == 0 ? nil : images![0]
                topRightImageView.image = count == 0 ? nil : images![1]
                bottomLeftImageView.image = count == 0 ? nil : images![2]
                bottomRightImageView.image = count == 0 ? nil : images![3]
                
            }
        }
    }
    
    // One image
    var imageView: UIImageView!
    
    // Two images
    var topImageView: UIImageView!
    var bottomImageView: UIImageView!
    
    // Three images (makes use of topImageView)
    var bottomLeftImageView: UIImageView!
    var bottomRightImageView: UIImageView!
    
    // Four images (makes use of bottomLeftImageView and bottomRightImageView)
    var topLeftImageView: UIImageView!
    var topRightImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6.0
        
        func autoLayoutImageView() -> UIImageView {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = UIColor.white
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }
        
        // One image
        
        imageView = autoLayoutImageView()
        addSubview(imageView)
        topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        // Two images
        
        topImageView = autoLayoutImageView()
        addSubview(topImageView)
        topAnchor.constraint(equalTo: topImageView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: topImageView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: topImageView.trailingAnchor).isActive = true
        centerYAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: imageSpacing/2).isActive = true
        
        bottomImageView = autoLayoutImageView()
        addSubview(bottomImageView)
        centerYAnchor.constraint(equalTo: bottomImageView.topAnchor, constant: -imageSpacing/2).isActive = true
        leadingAnchor.constraint(equalTo: bottomImageView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: bottomImageView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: bottomImageView.bottomAnchor).isActive = true
        
        // Three images (makes use of topImageView)
        
        bottomLeftImageView = autoLayoutImageView()
        addSubview(bottomLeftImageView)
        centerYAnchor.constraint(equalTo: bottomLeftImageView.topAnchor, constant: -imageSpacing/2).isActive = true
        leadingAnchor.constraint(equalTo: bottomLeftImageView.leadingAnchor).isActive = true
        centerXAnchor.constraint(equalTo: bottomLeftImageView.trailingAnchor, constant: imageSpacing/2).isActive = true
        bottomAnchor.constraint(equalTo: bottomLeftImageView.bottomAnchor).isActive = true
        
        bottomRightImageView = autoLayoutImageView()
        addSubview(bottomRightImageView)
        centerYAnchor.constraint(equalTo: bottomRightImageView.topAnchor, constant: -imageSpacing/2).isActive = true
        centerXAnchor.constraint(equalTo: bottomRightImageView.leadingAnchor, constant: -imageSpacing/2).isActive = true
        trailingAnchor.constraint(equalTo: bottomRightImageView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: bottomRightImageView.bottomAnchor).isActive = true
        
        // Four images (makes use of bottomLeftImageView and bottomRightImageView)
        
        topLeftImageView = autoLayoutImageView()
        addSubview(topLeftImageView)
        topAnchor.constraint(equalTo: topLeftImageView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: topLeftImageView.leadingAnchor).isActive = true
        centerXAnchor.constraint(equalTo: topLeftImageView.trailingAnchor, constant: imageSpacing/2).isActive = true
        centerYAnchor.constraint(equalTo: topLeftImageView.bottomAnchor, constant: imageSpacing/2).isActive = true
        
        topRightImageView = autoLayoutImageView()
        addSubview(topRightImageView)
        topAnchor.constraint(equalTo: topRightImageView.topAnchor).isActive = true
        centerXAnchor.constraint(equalTo: topRightImageView.leadingAnchor, constant: -imageSpacing/2).isActive = true
        trailingAnchor.constraint(equalTo: topRightImageView.trailingAnchor).isActive = true
        centerYAnchor.constraint(equalTo: topRightImageView.bottomAnchor, constant: imageSpacing/2).isActive = true
        
    }
}
