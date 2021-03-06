//
//  ASMShadowView.swift
//  ASMExtensions
//
//  Created by Ps on 18/1/2564 BE.
//

import UIKit
public final class ASMShadowView: UIView {
    public var option: ASMShadowViewOption = ASMShadowViewOption()
    
    public    var contentView: UIView {
        return visualEffectView.contentView
    }
    public   var nView: UIView {
        return shadowView
    }
    public  var visualView: UIView {
        return visualEffectView
    }
    public  var showCapInsetLines: Bool = false {
        didSet {
            //  if #available(iOS 13.0, *) {
            shadowView.image = resizeableShadowImage(
                withCornerRadius: option.cornerRadius,
                shadow:  option.shadow,
                corner: option.corner,
                shouldDrawCapInsets: showCapInsetLines
            )
            //  } else {
            // Fallback on earlier versions
            //  }
        }
    }
    
    // Debug option for showing/ hiding the shadow
    public var showShadow: Bool = true {
        didSet {
            shadowView.isHidden = !showShadow
        }
    }
    
    public  init(_ option: ASMShadowViewOption){
        self.option = option
        super.init(frame: .zero)
        self.selfInit()
    }
    
    fileprivate lazy var mainView =  UIView(frame: .zero)
    fileprivate lazy var shadowView = self.lazyShadowView()
    fileprivate lazy var visualEffectView = self.lazyVisualEffectView()
    var oldColor:UIColor?
    
    convenience init() {
        self.init(frame: CGRect())
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.selfInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.selfInit()
    }
    
    private func selfInit() {
        oldColor = backgroundColor
        backgroundColor = .clear
        
        addSubview(mainView)
        mainView.backgroundColor = .clear
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(shadowView)
        mainView.addSubview(visualEffectView)
        // visualEffectView.isHidden = true
        
        var mainConstrant:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        if !option.shadow.rect.value.equalContents(to:  [.top, .bottom,.leading,.trailing])  {
            mainView.clipsToBounds = true
            for item in option.shadow.rect.value {
                switch item {
                case .top:
                    mainConstrant.top =  option.shadow.blur
                case .bottom:
                    mainConstrant.bottom =  option.shadow.blur
                case .leading:
                    mainConstrant.left =  option.shadow.blur
                case .trailing:
                    mainConstrant.right =  option.shadow.blur
                default:
                    break
                }
            }
            
        }
        let blurRadius =  option.shadow.blur
        NSLayoutConstraint.activate([
            
            mainView.topAnchor.constraint(equalTo: topAnchor, constant: -mainConstrant.top),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: mainConstrant.bottom),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -mainConstrant.left),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: mainConstrant.right),
            
            visualEffectView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: mainConstrant.top),
            visualEffectView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -mainConstrant.bottom),
            
            visualEffectView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: mainConstrant.left),
            visualEffectView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -mainConstrant.right),
            
            shadowView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: -blurRadius + mainConstrant.top),
            shadowView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: blurRadius   - mainConstrant.bottom),
            
            shadowView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: -blurRadius + mainConstrant.left),
            shadowView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: blurRadius - mainConstrant.right),
        ])
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: option.corner, cornerRadii: CGSize(width: option.cornerRadius, height: option.cornerRadius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        visualEffectView.layer.mask = mask
    }
}


extension ASMShadowView {
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                transition(to: traitCollection.userInterfaceStyle)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 12.0, *)
    private func transition(to style: UIUserInterfaceStyle) {
        switch style {
        case .light, .unspecified:
            showShadow = true
        case .dark:
            showShadow = false
        @unknown default:
            fatalError()
        }
    }
}


extension ASMShadowView {
    
    fileprivate func lazyVisualEffectView() -> UIVisualEffectView {
        var view : UIVisualEffectView!
        view = UIVisualEffectView(effect: option.effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.backgroundColor = oldColor
        return view
    }
    
    fileprivate func lazyShadowView() -> UIImageView {
        
        let image = resizeableShadowImage(
            withCornerRadius: option.cornerRadius,
            shadow: option.shadow,
            corner: option.corner,
            shouldDrawCapInsets: showCapInsetLines
        )
        
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    fileprivate func resizeableShadowImage(
        withCornerRadius cornerRadius: CGFloat,
        shadow:  Shadow,
        corner: UIRectCorner,
        shouldDrawCapInsets: Bool
    ) -> UIImage {
        let sideLength: CGFloat = cornerRadius * 5
        return UIImage.resizableShadowImage(
            withSideLength: sideLength,
            cornerRadius: cornerRadius,
            shadow: shadow,
            corners:corner,
            shouldDrawCapInsets: showCapInsetLines
        )
    }
}
public struct Shadow {
    public let offset: CGSize
    public  let blur: CGFloat
    public let color: UIColor
    public  let rect: ASMShadowRect
    
    public init(offset: CGSize = CGSize(width: 0, height: 0), blur: CGFloat, color: UIColor, rect:  ASMShadowRect = .all) {
        
        self.offset = offset
        self.blur = blur
        self.color = color
        self.rect = rect
    }
}


public struct ASMShadowViewOption  {
    
    public var cornerRadius: CGFloat = 8
    public var shadow: Shadow = Shadow(offset: CGSize(), blur: 7, color: UIColor.gray.withAlphaComponent(1.0) )
    public var corner: UIRectCorner =   [.topLeft, .topRight, .bottomLeft,.bottomRight]
    public var effect: UIBlurEffect = UIBlurEffect(style: .light)
    
    public init(cornerRadius: CGFloat, shadow: Shadow, corner: UIRectCorner, effect:  UIBlurEffect ) {
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.corner = corner
        self.effect = effect
    }
    public  init() {
        
    }
}

public enum ASMShadowRect {
    case all
    case verticalTop
    case verticalMiddle
    case verticalBottom
    
    var value :[NSLayoutConstraint.Attribute] {
        switch self {
        case .all:
            return [.top, .bottom,.leading,.trailing]
        case .verticalTop:
            return [.top, .leading,.trailing]
        case .verticalMiddle:
            return [.leading,.trailing]
        case .verticalBottom:
            return [.bottom,.leading,.trailing]
        }
    }
}

