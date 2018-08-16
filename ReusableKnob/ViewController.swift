/// Copyright (c) 2018 Razeware LLC
/// 

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var valueLabel: UILabel!
  @IBOutlet var valueSlider: UISlider!
  @IBOutlet var animateSwitch: UISwitch!
  @IBOutlet weak var knob: Knob!

  override func viewDidLoad() {
    super.viewDidLoad()
    knob.lineWidth = 4
    knob.pointerLength = 12
    knob.viewModel.updateBounds(knob.bounds, origin: knob.frame.origin)
    knob.addTarget(self, action: #selector(ViewController.handleValueChanged(_:)), for: .valueChanged)

    knob.setKnobValue(valueSlider.value)
    updateLabel()
  }

  @IBAction func handleValueChanged(_ sender: Any) {
    if sender is UISlider {
      knob.setKnobValue(valueSlider.value)
    } else {
      valueSlider.value = knob.knobValue
    }
    updateLabel()
  }

  @IBAction func handleRandomButtonPressed(_ sender: Any) {
    let randomValue = Float(arc4random_uniform(101)) / 100.0
    knob.setKnobValue(randomValue, animated: animateSwitch.isOn)
    valueSlider.setValue(randomValue, animated: animateSwitch.isOn)
    updateLabel()
  }

  func updateLabel() {
    valueLabel.text = String(format: "%.2f", knob.knobValue)
  }
}
