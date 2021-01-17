//
//  ASMShadowView.swift
//  ASMExtensions
//
//  Created by Ps on 18/1/2564 BE.
//



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

extension UIImage {
    public static func resizableShadowImage(
        withSideLength sideLength: CGFloat,
        cornerRadius: CGFloat,
        shadow: Shadow,
        corners: UIRectCorner = .allCorners,
        shouldDrawCapInsets: Bool = false
    ) -> UIImage {
        
        let lengthAdjustment = sideLength + (shadow.blur * 2.0)
        let graphicContextSize = CGSize(width: lengthAdjustment, height: lengthAdjustment)
        let capInset = cornerRadius + shadow.blur
        
        let renderer = UIGraphicsImageRenderer(size: graphicContextSize)
        let shadowImage = renderer.image { (context) in
            drawSquareShadowImage(
                withSideLength: sideLength,
                cornerRadius: cornerRadius,
                shadow: shadow,
                corners: corners,
                shouldDrawCapInsets: shouldDrawCapInsets,
                in: context
            )
            
            if shouldDrawCapInsets {
                drawCapInsets(capInset, in: context)
            }
        }
        
        // Now let's make the square shadow image resizable based on the cap inset.
        let edgeInsets = UIEdgeInsets(top: capInset, left: capInset, bottom: capInset, right: capInset)
        return shadowImage.resizableImage(withCapInsets: edgeInsets, resizingMode: .tile) // you can play around with `.stretch`, too.
    }
    
    private static func drawSquareShadowImage(
        withSideLength sideLength: CGFloat,
        cornerRadius: CGFloat,
        shadow: Shadow,
        corners: UIRectCorner = .allCorners,
        shouldDrawCapInsets: Bool = false,
        in context: UIGraphicsImageRendererContext
    ) {
        // The image is a square, which makes it easier to set up the cap insets.
        //
        // Note: this implementation assumes an offset of CGSize(0, 0)
        // , corners: UIRectCorner = .allCorners,
        let cgContext = context.cgContext
        
        // This cuts a "hole" in the image leaving only the "shadow" border.
        let roundedRect = CGRect(x: shadow.blur, y: shadow.blur, width: sideLength, height: sideLength)
        // let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let shadowPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corners, cornerRadii: size)
        
        cgContext.addRect(cgContext.boundingBoxOfClipPath)
        cgContext.addPath(shadowPath.cgPath)
        cgContext.clip(using: .evenOdd)
        
        // Finally, let's draw the shadow
        let color = shadow.color.cgColor
        cgContext.setStrokeColor(color)
        cgContext.addPath(shadowPath.cgPath)
        cgContext.setShadow(offset: shadow.offset, blur: shadow.blur, color: color)
        cgContext.fillPath()
    }
    
    
    private static func drawCapInsets(
        _ capInset: CGFloat,
        in context: UIGraphicsImageRendererContext
    ) {
        
        let cgContext = context.cgContext
        cgContext.setStrokeColor(UIColor.purple.cgColor)
        cgContext.beginPath()
        
        let debugRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: context.format.bounds.size)
        
        // horizontal top line
        cgContext.move(to: CGPoint(x: debugRect.origin.x, y: debugRect.origin.y + capInset))
        cgContext.addLine(to: CGPoint(x: debugRect.size.width + capInset, y: debugRect.origin.y + capInset))
        
        // horizontal bottom line
        cgContext.move(to: CGPoint(x: debugRect.origin.x, y: debugRect.size.height - capInset))
        cgContext.addLine(to: CGPoint(x: debugRect.size.width + capInset, y: debugRect.size.height - capInset))
        
        // vertical left line
        cgContext.move(to: CGPoint(x: debugRect.origin.x + capInset, y: debugRect.origin.y))
        cgContext.addLine(to: CGPoint(x: debugRect.origin.x + capInset, y: debugRect.size.height))
        
        // vertical right line
        cgContext.move(to: CGPoint(x: debugRect.size.width - capInset, y: debugRect.origin.y))
        cgContext.addLine(to: CGPoint(x: debugRect.size.width - capInset, y: debugRect.size.height))
        
        cgContext.strokePath()
        
        // Finally, adding a red border around the entire image.
        cgContext.addRect(debugRect.insetBy(dx: 0.5, dy: 0.5))
        cgContext.setStrokeColor(UIColor.red.cgColor)
        cgContext.strokePath()
    }
}
