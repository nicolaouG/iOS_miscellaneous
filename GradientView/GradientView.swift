import UIKit

/**
 - Example usage:
 ```
 let gradientView = GradientView(type: .transparency(color: UIColor.red, from: 0, to: 0.8), direction: .topToBottom)
 ```
 */

class GradientView: UIView {
    enum GradientType {
        /// Add a color and the values in the range 0...1
        case transparency(color: UIColor, from: CGFloat, to: CGFloat)
        case multicolored(_ colors: [UIColor])
    }

    enum GradientDirection {
        case topToBottom
        case topLeftToBottomRight
        case leftToRight
        /// Specify start and end points in the unit coordinate space
        case manual(start: CGPoint, end: CGPoint)
    }

    private let gradientLayerName = "gradientLayerName" // to add the gradient only once

    let gradientType: GradientType
    let gradientDirection: GradientDirection

    lazy var gradient: CAGradientLayer = {
        getGradientLayer()
    }()

    init(type: GradientType, direction: GradientDirection) {
        gradientType = type
        gradientDirection = direction
        super.init(frame: .zero)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addGradientLayerIfNeeded()
    }

    func getGradientLayer() -> CAGradientLayer {
        let g = CAGradientLayer()
        g.name = gradientLayerName

        switch gradientType {
        case let .transparency(color, from, to):
            let _from = min(max(from, 0), 1)
            let _to = max(min(to, 1), 0)
            g.colors = [color.withAlphaComponent(_from).cgColor, color.withAlphaComponent(_to).cgColor]
        case let .multicolored(colors):
            g.colors = colors.map { $0.cgColor }
        }

        switch gradientDirection {
        case .topToBottom:
            g.startPoint = CGPoint(x: 1, y: 0)
            g.endPoint = CGPoint(x: 1, y: 1)
        case .topLeftToBottomRight:
            g.startPoint = .zero
            g.endPoint = CGPoint(x: 1, y: 1)
        case .leftToRight:
            g.startPoint = CGPoint(x: 0, y: 1)
            g.endPoint = CGPoint(x: 1, y: 1)
        case let .manual(start, end):
            g.startPoint = start
            g.endPoint = end
        }

        return g
    }

    func addGradientLayerIfNeeded(forceReplace: Bool = false) {
        if forceReplace, layer.sublayers?.first?.name == gradientLayerName {
            layer.sublayers?.first?.removeFromSuperlayer()
        }

        guard layer.sublayers?.first?.name != gradientLayerName else { return }
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
}

extension GradientView {
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            gradient = getGradientLayer()
            addGradientLayerIfNeeded(forceReplace: true)
        }
    }
}
