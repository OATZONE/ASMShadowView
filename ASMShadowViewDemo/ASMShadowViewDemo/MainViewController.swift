//
//  MainViewController.swift
//  ASMShadowViewDemo
//
//  Created by Ps on 18/1/2564 BE.
//

import UIKit
import ASMShadowView

class MainViewController: UIViewController {

    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var heightLine: NSLayoutConstraint!
    var  shadow22 : ASMShadowView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        settupAnimation()
    }

    func setupView(){
         shadow22 =  ASMShadowView(ASMShadowViewOption(cornerRadius: 10, shadow:  Shadow(offset: CGSize(), blur: 6, color: UIColor.darkGray.withAlphaComponent(1) ), corner:[.allCorners], effect:  UIBlurEffect(style: .light)))
        shadow22.visualView.isHidden = false
        shadow22.visualView.alpha = 0.7
        shadowView.layer.cornerRadius = 10
        fixInView(mainView:shadow22 , shadowView)
        
      
       
    }
    
    func settupAnimation(){
      
        UIView.animate(withDuration: 0.5) {
            self.heightLine.constant = 500
           self.view.layoutIfNeeded()

        }
        UIView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: [.curveLinear]) {
         //   self.shadow22.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
          //  self.heightLine.constant = 1000
    
           // self.updateViewConstraints()
            self.shadowView.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)

        } completion: { (value) in
        // self.shadow22.showShadow = false
        }

        
    }
    private func fixInView(mainView :UIView, _ container: UIView!,index:Int? = 0) -> Void{
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.frame = container.frame
        
        if let index = index {
            container.insertSubview(mainView, at: index)
        }else {
            container.addSubview(mainView)
        }
        
        //  container.addSubview(self);
        NSLayoutConstraint(item: mainView, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: mainView, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: mainView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: mainView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
