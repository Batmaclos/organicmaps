final class BottomMenuItemCell: UITableViewCell {
  private enum Constants {
    static let badgeSpacing: CGFloat = 8
    static let badgeBackgroundWidth: CGFloat = 32
  }

  @IBOutlet private var label: UILabel!
  @IBOutlet private var badgeBackground: UIView!
  @IBOutlet private var badgeCountLabel: UILabel!
  @IBOutlet private var separator: UIView!
  @IBOutlet private var icon: UIImageView!
  var anchorView: UIView {
    icon
  }

  private(set) var isEnabled: Bool = true

  func configure(image: UIImage,
                 title: String,
                 badgeCount: UInt = .zero,
                 imageStyle: GlobalStyleSheet = .black,
                 enabled: Bool = true) {
    icon.setStyleAndApply(isEnabled ? imageStyle : .gray)
    icon.image = image
    label.text = title
    label.setFontStyleAndApply(.regular16, color: isEnabled ? .blackPrimary : .blackHint)
    badgeBackground.isHidden = badgeCount == 0
    badgeCountLabel.text = "\(badgeCount)"
    badgeCountLabel.setFontStyleAndApply(.medium14, color: .whitePrimary)
    isEnabled = enabled
  }
}
