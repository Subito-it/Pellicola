//
//  CheckmarkView.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 22/12/2017.
//

import UIKit

class CheckmarkView: UIView {
    
    let borderWidth: CGFloat = 1.0
    let checkmarkLineWidth: CGFloat = 1.2
    
    let borderColor: UIColor = .white
    let bodyColor: UIColor = #colorLiteral(red: 0.07843137255, green: 0.4352941176, blue: 0.8745098039, alpha: 1)
    let checkmarkColor: UIColor = .white

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 2.0
    }
    
    override func draw(_ rect: CGRect) {
        
        //Border
        self.borderColor.setFill()
        UIBezierPath(ovalIn: self.bounds).fill()
        
        // Body
        self.bodyColor.setFill()
        UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth)).fill()
        
        // Checkmark
        let checkmarkPath = UIBezierPath()
        checkmarkPath.lineWidth = self.checkmarkLineWidth
        
        checkmarkPath.move(to: CGPoint(x: self.bounds.width * (6.0 / 24.0), y: self.bounds.height * (12.0 / 24.0)))
        checkmarkPath.addLine(to: CGPoint(x: self.bounds.width * (10.0 / 24.0), y: self.bounds.height * (16.0 / 24.0)))
        checkmarkPath.addLine(to: CGPoint(x: self.bounds.width * (18.0 / 24.0), y: self.bounds.height * (8.0 / 24.0)))
        
        checkmarkColor.setStroke()
        checkmarkPath.stroke()
    }

}
