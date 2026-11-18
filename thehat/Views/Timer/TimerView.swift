import UIKit

final class TimerView: UIView {
    var percent: CGFloat = 1

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 6
        let track = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)
        track.lineWidth = 7
        AppColors.secondary.setStroke()
        track.stroke()
        let progress = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: -.pi / 2 + 2 * .pi * min(1, abs(percent)), clockwise: true)
        progress.lineWidth = 7
        progress.lineCapStyle = .round
        (percent < 0 ? AppColors.fail : AppColors.primary).setStroke()
        progress.stroke()
    }
}
