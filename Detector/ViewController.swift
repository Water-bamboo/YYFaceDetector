//
//  ViewController.swift
//  Detector
//
//  Created by Mac on 10/21/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import CoreImage
//import FaceDe

class ViewController: UIViewController {
    @IBOutlet weak var personPic: UIImageView!
    @IBOutlet weak var faceCount: UILabel!
    
    var imageTag: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()

//        let vc = CGAffineTransformDemoVC()
//        self.present(vc, animated: false, completion: nil)
        
//        let vc2 = FaceDetectorViewController()
//        self.present(vc2, animated: false, completion: nil)

        let uiImage = UIImage(named: "face-1");
        personPic.image = uiImage;
        imageTag = 1;
        
//        self.personPic.transform = CGAffineTransform(scaleX: 1, y:-1);
//        self.view.transform = CGAffineTransform(scaleX: 1, y:-1);
        
        // 调用detect
        detect1()
        
//        detectorFace
    }
    
    @IBAction func theLastPicture(_ sender: AnyObject) {
        if imageTag > 1 {
            imageTag -= 1
        } else {
            imageTag = 1
            let alert = UIAlertController(title: "提示", message: "已经是第一张图片了", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        personPic.image = UIImage(named: "face-\(imageTag)")
        detect1()
    }
    
    @IBAction func theNextPicture(_ sender: AnyObject) {
        if imageTag < 10 {
            imageTag += 1
        } else {
            imageTag = 10
            let alert = UIAlertController(title: "提示", message: "已经是最后一张图片了", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        personPic.image = UIImage(named: "face-\(imageTag)")
        detect1()
    }
    
    
    // MARK: - 识别面部(识别准确)
    func detect1() {
        
        for view in personPic.subviews {
            view.removeFromSuperview()
        }
        
        guard let personciImage = CIImage(image: personPic.image!) else {
            return
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = personciImage.extent.size
        print("ciImageSize:\(ciImageSize)")//800,534
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)

        for face in faces as! [CIFaceFeature] {
            
            print("face.bounds are \(face.bounds)")//(314.0, 243.0, 196.0, 196.0)
            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            print("after transform: face.bounds==\(faceViewBounds)")//(314.0, 95.0, 196.0, 196.0)

            // Calculate the actual position and size of the rectangle in the image view
            let personPicViewSize = personPic.bounds.size
            print("personPicViewSize:\(personPicViewSize)")//(383.0, 667.0)//全屏，由于content.scale=center
            print("ciImageSize:\(ciImageSize)")//由于显示的部分是：800,534。
            
            //算scale
            let scale = min(personPicViewSize.width / ciImageSize.width,
                            personPicViewSize.height / ciImageSize.height)
            print("scale=\(scale)")
            let offsetX = (personPicViewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (personPicViewSize.height - ciImageSize.height * scale) / 2
            
            print("offsetX=\(offsetX), offsetY=\(offsetY)")//offsetX=0.0, offsetY=205.67375

            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            //faceViewBounds.afterScale=(150.3275, 251.155, 93.835, 93.835)
            print("faceViewBounds.afterScale=\(faceViewBounds)")
            
            let faceBox = UIView(frame: faceViewBounds)
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            
            personPic.addSubview(faceBox)

            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")//(387.0, 386.0)

                var eyeBounds = CGRect(origin:CGPoint(x: (face.leftEyePosition.x - 5), y:(face.leftEyePosition.y - 2.5)), size:CGSize(width:10, height:5))

                eyeBounds.origin.x += offsetX
                eyeBounds.origin.y += offsetY
                
                let eyeBox = UIView()
                eyeBox.frame = eyeBounds;
                eyeBox.layer.borderWidth = 2;
                eyeBox.layer.borderColor = UIColor.blue.cgColor;
                
                eyeBox.transform = transform;
                
//                faceBox.addSubview(eyeBox)
                
                personPic.addSubview(eyeBox)
            }
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
            }
            
        }
        faceCount.text = "识别出\((faces?.count)!)张脸"
    }
    
    //MARK: - 识别面部(识别不准确) 弃用
    func detect2() {
        // 创建personciImage变量保存从故事板中的UIImageView提取图像并将其转换为CIImage，使用Core Image时需要用CIImage
        guard let personciImage = CIImage(image: personPic.image!) else {
            return
        }
        // 上下文
        let content = CIContext()
        // 创建accuracy变量并设为CIDetectorAccuracyHigh，可以在CIDetectorAccuracyHigh(较强的处理能力)与CIDetectorAccuracyLow(较弱的处理能力)中选择，因为想让准确度高一些在这里选择CIDetectorAccuracyHigh
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        // 这里定义了一个属于CIDetector类的faceDetector变量，并输入之前创建的accuracy变量
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: content, options: accuracy)
        // 调用faceDetector的featuresInImage方法，识别器会找到所给图像中的人脸，最后返回一个人脸数组
        let faces = faceDetector?.features(in: personciImage)
        
        
        // 循环faces数组里的所有face，并将识别到的人脸强转为CIFaceFeature类型
        for face in faces as! [CIFaceFeature] {
            
            print("Found bounds are \(face.bounds)")
            // 创建名为faceBox的UIView，frame设为返回的faces.first的frame，绘制一个矩形框来标识识别到的人脸
            let faceBox = UIView(frame: face.bounds)
            // 设置faceBox的边框宽度为3
            faceBox.layer.borderWidth = 3
            // 设置边框颜色为红色
            faceBox.layer.borderColor = UIColor.blue.cgColor
            // 将背景色设为clear，意味着这个视图没有可见的背景
            faceBox.backgroundColor = UIColor.clear
            // 最后，把这个视图添加到personPic imageView上
            
            let cgAffineScale = CGAffineTransform(scaleX: 1, y: -1);
            faceBox.transform = cgAffineScale
            
            personPic.addSubview(faceBox)
            
            // API不仅可以帮助你识别人脸，也可识别脸上的左右眼，我们不在图像中标识出眼睛，只是给你展示一下CIFaceFeature的相关属性
            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
            }
        }
    }
    
}
