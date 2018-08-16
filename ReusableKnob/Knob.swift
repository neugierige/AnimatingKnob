/// Copyright (c) 2018 Razeware LLC
///

import UIKit

class Knob: UIControl {

  let viewModel = KnobRenderer(startAngleRadians: -1, lengthRadians: 1)

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    viewModel.updateBounds(bounds, origin: frame.origin)
    viewModel.color = tintColor
    viewModel.setPointerAngle(viewModel.startAngle)

    layer.addSublayer(viewModel.trackLayer)
    layer.addSublayer(viewModel.pointerLayer)

    let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    addGestureRecognizer(gestureRecognizer)
  }

  var minimumValue: Float = 0
  var maximumValue: Float = 1
  private(set) var knobValue: Float = 0

  var lineWidth: CGFloat {
    get { return viewModel.lineWidth }
    set { viewModel.lineWidth = newValue}
  }

  var startAngle: CGFloat {
    get { return viewModel.startAngle }
    set { viewModel.startAngle = newValue}
  }

  var endAngle: CGFloat {
    get { return viewModel.endAngle }
    set { viewModel.endAngle = newValue}
  }

  var pointerLength: CGFloat {
    get { return viewModel.pointerLength }
    set { viewModel.pointerLength = newValue}
  }

  func setKnobValue(_ newValue: Float, animated: Bool = false) {
    knobValue = min(maximumValue, max(minimumValue, newValue))

    let angleRange = endAngle - startAngle
    let valueRange = maximumValue - minimumValue // 1 - 0
    let angleValue = (CGFloat(knobValue - minimumValue) / CGFloat(valueRange) * angleRange) + startAngle
    viewModel.setPointerAngle(angleValue, animated: animated)
  }

  var isContinuous = true

  @objc func handleGesture(_ gesture: RotationGestureRecognizer) {

    let midPointAngle = (2 * CGFloat(Double.pi) + startAngle - endAngle)/2 + endAngle
    var boundedAngle = gesture.touchAngle

    if boundedAngle > midPointAngle {
      boundedAngle -= 2 * CGFloat(Double.pi)
    } else if boundedAngle < (midPointAngle - 2 * CGFloat(Double.pi)) {
      boundedAngle -= 2 * CGFloat(Double.pi)
    }
    boundedAngle = min(endAngle, max(startAngle, boundedAngle))

    let angleRange = endAngle - startAngle
    let valueRange = maximumValue - minimumValue
    let angleValue = Float(boundedAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
    setKnobValue(angleValue)

    if isContinuous {
      sendActions(for: .valueChanged)
    } else {
      if gesture.state == .ended || gesture.state == .cancelled {
        sendActions(for: .valueChanged)
      }
    }
  }

}

class KnobRenderer {

  let trackLayer = CAShapeLayer()
  let pointerLayer = CAShapeLayer()

  // CGFloat(Double.pi) * -5/8
  var startAngle: CGFloat

  // CGFloat(Double.pi) * -3/8
  var endAngle: CGFloat
  init(startAngleRadians: CGFloat, lengthRadians: CGFloat) {
    startAngle = CGFloat(Double.pi) * startAngleRadians
    endAngle = CGFloat(Double.pi) * (startAngleRadians + lengthRadians)

    trackLayer.fillColor = UIColor.clear.cgColor
    pointerLayer.fillColor = UIColor.clear.cgColor
  }

  var color: UIColor = .blue {
    didSet {
      trackLayer.strokeColor = color.cgColor
      pointerLayer.strokeColor = color.cgColor
    }
  }

  var lineWidth: CGFloat = 2 {
    didSet {
      trackLayer.lineWidth = lineWidth
      pointerLayer.lineWidth = lineWidth
    }
  }

  var pointerLength: CGFloat = 6

  private(set) var pointerAngle: CGFloat = 0

  func setPointerAngle(_ newValue: CGFloat, animated: Bool = false) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    pointerLayer.transform = CATransform3DMakeRotation(newValue, 0, 0, 1)

    if animated {
      let midAngleValue = (max(newValue, pointerAngle) - min(newValue, pointerAngle))/2 + min(newValue, pointerAngle)
      let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      animation.values = [pointerAngle, midAngleValue, newValue]
      animation.keyTimes = [0.0, 0.5, 1.0]
      animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
      pointerLayer.add(animation, forKey: nil)
    }
    CATransaction.commit()

    pointerAngle = newValue
  }

  var adjustedBounds: CGRect = CGRect.zero
  func updateBounds(_ bounds: CGRect, origin: CGPoint) {
    adjustedBounds = CGRect(x: bounds.minX + origin.x, y: bounds.minY, width: bounds.width, height: bounds.height)

    trackLayer.bounds = adjustedBounds
    pointerLayer.bounds = adjustedBounds

    trackLayer.position = CGPoint(x: adjustedBounds.midX, y: adjustedBounds.midY)
    pointerLayer.position = trackLayer.position

    updateLayers(origin: origin)
  }

  private func updateLayers(origin: CGPoint) {
    let bounds = adjustedBounds
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    let offset = max(pointerLength, lineWidth/2)
    let radius = min(bounds.width, bounds.height) / 2 - offset
    let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    trackLayer.path = ring.cgPath

    let pointer = UIBezierPath()

    pointer.move(to: CGPoint(x: bounds.width + origin.x - CGFloat(pointerLength) - CGFloat(lineWidth)/2, y: bounds.midY))
    pointer.addLine(to: CGPoint(x: bounds.width + origin.x, y: bounds.midY))
    pointerLayer.path = pointer.cgPath
  }

}
