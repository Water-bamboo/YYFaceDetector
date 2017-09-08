//
//  CGAffineTransformDemoVC.swift
//  Detector
//
//  Created by Shui on 2017/9/8.
//  Copyright © 2017年 Gregg Mojica. All rights reserved.
//

import Foundation
import UIKit

class CGAffineTransformDemoVC: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: UIImage(named: "face-1"))
        imageView.frame = CGRect(x: 80, y: 350, width: 200, height: 200)
        imageView.contentMode = .center

        var height = (-1*imageView.image!.size.height)
        var transform = CGAffineTransform(scaleX: 0.25, y: -1);
        transform = transform.translatedBy(x: 0, y: height)
//        CGAffineTransform(transform: transform, translate: -200)
//        imageView.transform = transform;
//        imageView.transform = CGAffineTransformTranslate(alertView.transform, 0, 600);

//        var transform = CGAffineTransform(scaleX: 1, y: -1)
//        imageView.frame.applying(transform)
        
        
        self.view.addSubview(imageView)
        self.view.backgroundColor = UIColor .red
        
    }
}
