//
//  CustomCollectionViewCell.swift
//
//  Created by Alex Givens http://alexgivens.com on 5/5/17
//  Copyright © 2017 Oak, LLC (https://oak.is)
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

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"
    
    var items: [Item]? {
        didSet {
            if let items = items {
                thumbnailView.images = items.map { $0.image! }
                nameLabel.text = items.count == 1 ? items[0].name : "\(items.count) items"
            } else {
                thumbnailView.images = nil
                nameLabel.text = nil
            }
        }
    }
    
    let thumbnailView = ThumbnailView()
    
    let stackIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6.0
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        return label
    }()
    
    var stackIndicatorWidthConstraint: NSLayoutConstraint!
    var stackIndicatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        items = nil
    }
    
    private func initialize() {
        
        addSubview(thumbnailView)
        topAnchor.constraint(equalTo: thumbnailView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: thumbnailView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: thumbnailView.rightAnchor).isActive = true
        thumbnailView.widthAnchor.constraint(equalTo: thumbnailView.heightAnchor).isActive = true
        
        insertSubview(stackIndicatorView, belowSubview: thumbnailView)
        thumbnailView.centerXAnchor.constraint(equalTo: stackIndicatorView.centerXAnchor).isActive = true
        thumbnailView.centerYAnchor.constraint(equalTo: stackIndicatorView.centerYAnchor).isActive = true
        stackIndicatorWidthConstraint = thumbnailView.widthAnchor.constraint(equalTo: stackIndicatorView.widthAnchor)
        stackIndicatorWidthConstraint.isActive = true
        stackIndicatorHeightConstraint = thumbnailView.heightAnchor.constraint(equalTo: stackIndicatorView.heightAnchor)
        stackIndicatorHeightConstraint.isActive = true
        
        addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 8.0).isActive = true
        leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
    }
    
}

