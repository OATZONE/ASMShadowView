//
//  Extension.swift
//  ASMShadowView
//
//  Created by Ps on 18/1/2564 BE.
//

import UIKit
extension Array where Element: Equatable {
    func equalContents(to other: [Element]) -> Bool {
        guard self.count == other.count else {return false}
        for e in self{
            guard self.filter({$0==e}).count == other.filter({$0==e}).count else {
                return false
            }
        }
        return true
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
