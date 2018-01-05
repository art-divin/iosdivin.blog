//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class Spinner : UIView {
    
    private var _sublayer = CALayer()
    var sublayer: CALayer {
        return self._sublayer
    }
    
    var shapePath : UIBezierPath {
        let shapeFrame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        return UIBezierPath(ovalIn: shapeFrame)
    }
    
    func calculateStroke(shape: CAShapeLayer, previousShape: CAShapeLayer?, originStart: Float, originEnd: Float) {
        let shapeWidthVariance : CGFloat = round((self.shapeOriginWidth * CGFloat(self.shapeLength)) * 10) / 10
        var lineWidth: CGFloat = 0
        var strokeStart: CGFloat = 0
        var strokeEnd: CGFloat = 0
        if let previousShape = previousShape {
            strokeStart = previousShape.strokeStart - CGFloat(self.shapeElementLength)
            strokeEnd = previousShape.strokeEnd - CGFloat(self.shapeElementLength)
            lineWidth = previousShape.lineWidth - shapeWidthVariance
        } else {
            strokeStart = CGFloat(originStart)
            strokeEnd = CGFloat(originEnd)
            lineWidth = self.shapeOriginWidth
        }
        
        shape.lineWidth = lineWidth
        shape.strokeStart = strokeStart.normalizedShapePoint
        shape.strokeEnd = strokeEnd.normalizedShapePoint
    }
    
    func generateShape(previousShape: CAShapeLayer?, originStart: Float, originEnd: Float) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.path = self.shapePath.cgPath
        
        self.calculateStroke(shape: shape, previousShape: previousShape, originStart: originStart, originEnd: originEnd)
        
        shape.lineCap = kCALineCapRound
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = self.strokeColor.cgColor
        return shape
    }
    
    func drawShape(from: Float, to: Float) {
        var prevShape: CAShapeLayer? = nil
        stride(from: from, to: to, by: self.shapeElementLength).forEach { _ in
            let previousShape = self.generateShape(previousShape: prevShape, originStart: from - self.shapeElementLength, originEnd: from)
            
            self.sublayer.addSublayer(previousShape)
            previousShape.strokeColor = self.strokeColor.cgColor
            prevShape = previousShape
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupStartPoints()
        self.setupSublayer()
        self.draw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupStartPoints()
        self.setupSublayer()
        self.draw()
    }
    
    private var startPoints: [Float] = []
    private let shapeElementLength: Float = 0.01
    private let shapeLength: Float = 0.1
    
    var shapeOriginWidth: CGFloat = 15.0
    var numberOfShapes = 5
    
    var strokeColor: UIColor = UIColor(red: 94 / 255.0, green: 192 / 255.0, blue: 224 / 255.0, alpha: 1.0)
    
    func setupSublayer() {
        self.sublayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.layer.addSublayer(self.sublayer)
    }
    
    func setupStartPoints() {
        for i in 1...self.numberOfShapes {
            let fraction = (100 / self.numberOfShapes)
            let pointStart = Float(fraction * i) / 100
            self.startPoints.append(pointStart - (self.shapeLength * 0.5))
        }
    }
    
    func draw() {
        for point in self.startPoints {
            self.drawShape(from: point, to: point + self.shapeLength)
        }
    }
    
}

extension CGFloat {
    
    var normalizedShapePoint : CGFloat {
        if self < 0 {
            return 1 - abs(self)
        }
        return self
    }
    
}

fileprivate extension UIView {
    
    enum Direction {
        case clockwise
        case counterclockwise
    }
    
    func rotate(direction: Direction, timingFunction: String) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        switch direction {
        case .clockwise: animation.toValue = NSNumber(value: Float.pi * 2.0)
        case .counterclockwise: animation.toValue = NSNumber(value: -Float.pi * 2.0)
        }
        
        animation.duration = 3.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        self.layer.add(animation, forKey: nil)
    }
    
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
view.backgroundColor = UIColor.white
let frame = CGRect(x: 50, y: 50, width: 100, height: 100)


let animatable3 = Spinner(frame: frame)
view.addSubview(animatable3)
animatable3.rotate(direction: .clockwise, timingFunction: kCAMediaTimingFunctionEaseOut)

PlaygroundPage.current.liveView = view
