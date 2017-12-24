//
//  ModalViewController.swift
//  ProjectL
//
//  Created by Mansoor Shah Said on 2017-12-23.
//  Copyright © 2017 Mansoor Shah Said. All rights reserved.
//

import UIKit

class ModalVC: UIViewController {

    let mainView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let blurView:UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.7
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.layer.opacity = 0
        return blurEffectView
    }()
    
    var minimumVelocityToHide = 1500 as CGFloat
    var minimumScreenRatioToHide = 0.3 as CGFloat
    var animationDuration = 0.2 as TimeInterval
    var initialMainY:CGFloat!
    var maxHeight:CGFloat!
    var initialDragY:CGFloat!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initialMainY = (self.view.frame.height - mainView.frame.height)/2
        maxHeight = UIScreen.main.bounds.height
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mainView.frame.origin.y = maxHeight
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.mainView.frame.origin.y = self.initialMainY
            self.blurView.layer.opacity = 1
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.mainView.frame.origin.y = self.maxHeight
            self.blurView.layer.opacity = 0
        }, completion: nil)
    }

    func slideViewVerticallyTo(_ y: CGFloat, view:UIView) {
        view.frame.origin = CGPoint(x: view.frame.origin.x, y: y)
    }

    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: self.mainView)
            let y = max(initialMainY, translation.y)
            self.slideViewVerticallyTo(y, view: self.mainView)
            
            if (initialDragY == nil){
                initialDragY = y
            } else {
                let opacity = (initialDragY / y)
                self.blurView.layer.opacity = Float(opacity)
            }            
            break
        case .ended:
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: self.mainView)
            let velocity = panGesture.velocity(in: self.mainView)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
                (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // If closing, animate to the bottom of the view
                    self.blurView.layer.opacity = 0
                    self.slideViewVerticallyTo(self.view.frame.size.height, view: self.mainView)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // Dismiss the view when it dissapeared
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    self.blurView.layer.opacity = 1
                    self.slideViewVerticallyTo(self.initialMainY, view: self.mainView)
                })
            }
            break
        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                self.blurView.layer.opacity = 1
                self.slideViewVerticallyTo(self.initialMainY, view: self.mainView)
            })
            break
        }
    }
    
    func setupViews(){
        view.backgroundColor = UIColor.clear
        view.addSubview(blurView)
        blurView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        view.addSubview(mainView)
        mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        mainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.8).isActive = true
        mainView.setNeedsLayout()
        mainView.layoutIfNeeded()
        mainView.layer.cornerRadius = mainView.frame.height / 25
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        mainView.addGestureRecognizer(panGesture)
    }

}
