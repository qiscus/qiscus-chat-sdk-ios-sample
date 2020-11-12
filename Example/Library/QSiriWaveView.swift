//
//  QSiriWaveView.swift
//  Example
//
//  Created by Qiscus on 11/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import UIKit

public class QSiriWaveView: UIView {
    
    static let kDefaultFrequency:CGFloat          = 1.5
    static let kDefaultAmplitude:CGFloat          = 1.0
    static let kDefaultIdleAmplitude:CGFloat      = 0.01
    static let kDefaultNumberOfWaves:UInt         = 5
    static let kDefaultPhaseShift:CGFloat         = -0.15
    static let kDefaultDensity:CGFloat            = 5.0
    static let kDefaultPrimaryLineWidth:CGFloat   = 3.0
    static let kDefaultSecondaryLineWidth:CGFloat = 1.0

    public var numberOfWaves:UInt = 1
    public var waveColor:UIColor = UIColor.green
    public var primaryWaveWidth:CGFloat = 1.0
    public var secondaryWaveWidth:CGFloat = 1.0
    public var idleAmplitude:CGFloat = 1.0
    public var frequency:CGFloat = 1.0
    public var amplitude:CGFloat = 1.0
    public var density:CGFloat = 1.0
    public var phaseShift:CGFloat = 1.0
    
    private var phase : CGFloat = 0
    
    override public func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(self.bounds)
        self.backgroundColor?.set()
        context?.fill(rect)
        
        // draw multiple sinus waves, with equal phases but altered amplitudes, multiplied by a parable function.
        for i in 0...self.numberOfWaves{
            let context = UIGraphicsGetCurrentContext()
            let strokeLineWidth = (i == 0) ? self.primaryWaveWidth : self.secondaryWaveWidth
            
            context?.setLineWidth(strokeLineWidth)
            
            let halfHeight = self.bounds.height / 2.0
            let width = self.bounds.width
            let mid = width / 2
            
            let maxAmplitude = halfHeight - (strokeLineWidth * 2)
            
            let progress = 1.0 - CGFloat(i / self.numberOfWaves)
            let normedAmplitude = ((1.5 * progress) - CGFloat(2.0 / CGFloat(self.numberOfWaves))) * self.amplitude
            let multiplier = min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0))
            
            self.waveColor.withAlphaComponent(multiplier * self.waveColor.cgColor.alpha).set()
            
            var x = CGFloat(0)
            while x < (width + self.density) {
                let scaling:CGFloat = -pow((1.0 / mid * (x - mid)), 2) + 1.0
                let y:CGFloat = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(2.0 * Float(Double.pi) * Float(x / width) * Float(self.frequency) + Float(self.phase))) + halfHeight
                
                if x == 0 {
                    context?.move(to: CGPoint(x: x, y: y))
                }else{
                    context?.addLine(to: CGPoint(x: x, y: y))
                }
                x += self.density
            }
            context?.strokePath()
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    public func setup(){
        self.waveColor = UIColor.green
        
        self.frequency = QSiriWaveView.kDefaultFrequency
        
        self.amplitude = QSiriWaveView.kDefaultAmplitude
        self.idleAmplitude = QSiriWaveView.kDefaultIdleAmplitude
        
        self.numberOfWaves = QSiriWaveView.kDefaultNumberOfWaves
        self.phaseShift = QSiriWaveView.kDefaultPhaseShift
        self.density = QSiriWaveView.kDefaultDensity
        
        self.primaryWaveWidth = QSiriWaveView.kDefaultPrimaryLineWidth
        self.secondaryWaveWidth = QSiriWaveView.kDefaultSecondaryLineWidth
    }
    
    public func update(withLevel level:CGFloat){
        self.phase += self.phaseShift
        self.amplitude = fmax(level, self.idleAmplitude)
        self.setNeedsDisplay()
    }
    
}
