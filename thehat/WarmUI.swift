import UIKit

/// Presentation only. The storyboard controls, targets, gestures, and controller
/// state machines remain the source of all interaction and navigation.
enum WarmUI {
    static func text(_ key: String) -> String { LS.localizedString(forKey: key) }
    static func displayFont(_ size: CGFloat) -> UIFont {
        UIFont(name: "Georgia-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }
    static func label(_ text: String = "", size: CGFloat = 17, serif: Bool = false,
                      color: UIColor = AppColors.textPrimary, centered: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = serif ? displayFont(size) : .systemFont(ofSize: size)
        label.textColor = color
        label.numberOfLines = 0
        label.textAlignment = centered ? .center : .left
        label.isUserInteractionEnabled = false
        return label
    }
    static func styleLabel(_ label: UILabel, size: CGFloat, serif: Bool = false, color: UIColor = AppColors.textPrimary) {
        label.font = serif ? displayFont(size) : .systemFont(ofSize: size, weight: .medium)
        label.textColor = color
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.65
        label.numberOfLines = 0
    }
    static func card() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColors.surface
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColors.separator.cgColor
        view.isUserInteractionEnabled = false
        return view
    }
    static func divider() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColors.separator
        view.isUserInteractionEnabled = false
        return view
    }
    static func symbol(_ name: String, fallback: String) -> UIView {
        if #available(iOS 13.0, *) {
            let image = UIImageView(image: UIImage(systemName: name))
            image.tintColor = AppColors.primaryDark
            image.contentMode = .scaleAspectFit
            return image
        }
        return label(fallback, size: 24, centered: true)
    }
    static func navigation(_ vc: UIViewController) {
        if #available(iOS 14.0, *) {
            vc.navigationItem.backButtonTitle = nil
            vc.navigationItem.backButtonDisplayMode = .minimal
        }
        let bar = vc.navigationController?.navigationBar
        bar?.tintColor = AppColors.primaryDark
        bar?.barTintColor = AppColors.background
        let attributes: [NSAttributedString.Key: Any] = [.font: displayFont(23), .foregroundColor: AppColors.textPrimary]
        bar?.titleTextAttributes = attributes
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = AppColors.background
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = attributes
            bar?.standardAppearance = appearance
            bar?.scrollEdgeAppearance = appearance
            bar?.compactAppearance = appearance
        }
        if let title = vc.navigationItem.titleView as? UILabel {
            styleLabel(title, size: 23, serif: true)
            title.numberOfLines = 1
            title.sizeToFit()
        }
    }

    /// Reuse the actual controls rather than replacing them with new actions.
    static func install(on vc: UIViewController, keeping controls: [UIView]) -> WarmCanvas {
        controls.forEach { $0.removeFromSuperview(); $0.translatesAutoresizingMaskIntoConstraints = true }
        NSLayoutConstraint.deactivate(vc.view.constraints)
        vc.view.subviews.forEach { $0.removeFromSuperview() }
        let canvas = WarmCanvas(frame: vc.view.bounds)
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.view.backgroundColor = AppColors.background
        vc.view.addSubview(canvas)
        controls.forEach { canvas.addSubview($0) }
        navigation(vc)
        return canvas
    }

    static func prepareContainer(_ view: UIView, preserving progressView: UIView? = nil) {
        NSLayoutConstraint.deactivate(view.constraints.filter { constraint in
            if let progress = progressView,
               (constraint.firstItem as? UIView === progress || constraint.secondItem as? UIView === progress) { return false }
            return true
        })
        for child in view.subviews where child !== progressView {
            child.translatesAutoresizingMaskIntoConstraints = true
        }
    }

    static func actionSurface(_ view: UIView, color: UIColor = AppColors.primary) {
        view.backgroundColor = color
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        let gradient = CAGradientLayer()
        gradient.name = "warm-surface"
        gradient.colors = [UIColor.white.withAlphaComponent(0.08).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.05).cgColor]
        gradient.locations = [0, 0.45, 1]
        view.layer.insertSublayer(gradient, at: 0)
    }
    static func layoutAction(_ container: UIView, label: UILabel, hint: UILabel? = nil, symbol: UILabel? = nil) {
        let bounds = container.bounds
        container.layer.sublayers?.first(where: { $0.name == "warm-surface" })?.frame = bounds
        container.subviews.compactMap { $0 as? UIButton }.forEach { $0.frame = bounds }
        if let symbol = symbol {
            symbol.frame = CGRect(x: 8, y: 12, width: bounds.width - 16, height: 34)
            label.frame = CGRect(x: 10, y: 48, width: bounds.width - 20, height: bounds.height - 54)
        } else {
            let showsHint = hint?.isHidden == false
            label.frame = CGRect(x: 12, y: showsHint ? 19 : 0, width: bounds.width - 24, height: bounds.height - (showsHint ? 19 : 0))
            hint?.frame = CGRect(x: 8, y: 5, width: bounds.width - 16, height: 17)
        }
        label.textAlignment = .center
    }

    static func menu(_ vc: MenuController) {
        guard let rules = vc.rulesLabel.superview, let about = vc.aboutLabel.superview else { return }
        let controls: [UIView] = [vc.newGameView, rules, about, vc.historyButton, vc.languageButton]
        let canvas = install(on: vc, keeping: controls)
        [vc.newGameView!, rules, about].forEach { prepareContainer($0) }
        actionSurface(vc.newGameView)
        styleLabel(vc.newGameLabel, size: 28, serif: true, color: AppColors.surface)
        styleLabel(vc.holdToStartLabel, size: 12, color: AppColors.surface)
        styleLabel(vc.rulesLabel, size: 18)
        styleLabel(vc.aboutLabel, size: 15)
        rules.backgroundColor = .clear
        about.backgroundColor = .clear
        vc.historyButton.backgroundColor = .clear
        vc.historyButton.setTitleColor(AppColors.textPrimary, for: .normal)
        vc.historyButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        vc.historyButton.contentHorizontalAlignment = .left
        vc.historyButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 24)
        vc.languageButton.backgroundColor = AppColors.surface
        vc.languageButton.setTitleColor(AppColors.textPrimary, for: .normal)
        vc.languageButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        vc.languageButton.layer.cornerRadius = 17
        vc.languageButton.layer.borderWidth = 1
        vc.languageButton.layer.borderColor = AppColors.separator.cgColor
        if #available(iOS 13.0, *) { vc.languageButton.setImage(UIImage(systemName: "globe"), for: .normal); vc.languageButton.tintColor = AppColors.primaryDark }
        vc.languageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        let title = label(text("warm_title"), size: 58, serif: true, centered: true)
        let hat = UIImageView(image: UIImage(named: "WarmHat"))
        hat.contentMode = .scaleAspectFit
        let tagline = label(text("warm_tagline"), size: 21, serif: false, centered: true)
        tagline.font = UIFont(name: "Georgia", size: 21)
        let linksCard = card()
        let line = divider()
        let book = symbol("book", fallback: "≡")
        let history = symbol("clock.arrow.circlepath", fallback: "↶")
        let arrow = label("→", size: 30, color: AppColors.surface, centered: true)
        let chevron1 = label("›", size: 26, color: AppColors.primaryDark, centered: true)
        let chevron2 = label("›", size: 26, color: AppColors.primaryDark, centered: true)
        canvas.insertSubview(linksCard, at: 0)
        [title, hat, tagline, line, book, history, arrow, chevron1, chevron2].forEach(canvas.addSubview)
        rules.subviews.compactMap { $0 as? UIButton }.first?.accessibilityIdentifier = "menu.rules"
        about.subviews.compactMap { $0 as? UIButton }.first?.accessibilityIdentifier = "menu.about"
        vc.historyButton.accessibilityIdentifier = "menu.history"
        vc.newGameView.accessibilityIdentifier = "menu.play"
        vc.newGameLabel.accessibilityIdentifier = "menu.play.label"
        canvas.arrange = { [weak vc] c in
            guard let vc = vc else { return }
            let r = c.contentRect
            let unit = r.height / 840
            func y(_ value: CGFloat) -> CGFloat { r.minY + value * unit }
            vc.languageButton.frame = CGRect(x: r.maxX - 136, y: y(10), width: 136, height: 36)
            title.frame = CGRect(x: r.minX, y: y(90), width: r.width, height: min(76, 80 * unit))
            hat.frame = CGRect(x: r.minX + 28, y: y(180), width: r.width - 56, height: 265 * unit)
            tagline.frame = CGRect(x: r.minX, y: y(455), width: r.width, height: 58 * unit)
            vc.newGameView.frame = CGRect(x: r.minX, y: y(535), width: r.width, height: 76 * unit)
            layoutAction(vc.newGameView, label: vc.newGameLabel, hint: vc.holdToStartLabel)
            arrow.frame = CGRect(x: r.maxX - 55, y: y(548), width: 40, height: 46 * unit)
            vc.newGameLabel.frame.size.width -= 24
            linksCard.frame = CGRect(x: r.minX, y: y(628), width: r.width, height: 128 * unit)
            rules.frame = CGRect(x: r.minX, y: y(628), width: r.width, height: 64 * unit)
            vc.rulesLabel.frame = CGRect(x: 60, y: 0, width: r.width - 104, height: rules.bounds.height)
            rules.subviews.compactMap { $0 as? UIButton }.forEach { $0.frame = rules.bounds }
            vc.historyButton.frame = CGRect(x: r.minX, y: y(692), width: r.width, height: 64 * unit)
            line.frame = CGRect(x: r.minX + 20, y: y(692), width: r.width - 40, height: 1)
            book.frame = CGRect(x: r.minX + 20, y: y(647), width: 26, height: 26)
            history.frame = CGRect(x: r.minX + 20, y: y(711), width: 26, height: 26)
            chevron1.frame = CGRect(x: r.maxX - 40, y: y(641), width: 24, height: 36)
            chevron2.frame = CGRect(x: r.maxX - 40, y: y(705), width: 24, height: 36)
            about.frame = CGRect(x: r.minX, y: y(772), width: r.width, height: 44)
            vc.aboutLabel.frame = about.bounds
            vc.aboutLabel.textAlignment = .center
            about.subviews.compactMap { $0 as? UIButton }.forEach { $0.frame = about.bounds }
        }
    }

    static func settings(_ vc: GameSettingsViewController) {
        let canvas = install(on: vc, keeping: [vc.playersTableView, vc.difficultyPicker, vc.wordsInTheHatStepper, vc.wordsInTheHatLabel, vc.wordsLabel, vc.roundLabel, vc.roundLengthStepper, vc.roundLengthLabel, vc.gameTypeLabel, vc.gameTypeSegmentControl])
        let roster = card(), settings = card()
        canvas.insertSubview(roster, at: 0)
        canvas.insertSubview(settings, at: 0)
        let playersTitle = label(text("players"), size: 19, color: AppColors.primaryDark)
        playersTitle.font = .systemFont(ofSize: 19, weight: .semibold)
        let settingsTitle = label(text("warm_settings"), size: 19, color: AppColors.primaryDark)
        settingsTitle.font = playersTitle.font
        let difficulty = label(text("warm_difficulty"), size: 16)
        let skips = label(text("allow_skips"), size: 16)
        let toggle = vc.allowsSkippingSwitch
        toggle.onTintColor = AppColors.primary
        toggle.accessibilityLabel = skips.text
        toggle.accessibilityIdentifier = "setup.allowSkips"
        [playersTitle, settingsTitle, difficulty, skips, toggle].forEach(canvas.addSubview)
        let lines = (0..<4).map { _ in divider() }
        lines.forEach(canvas.addSubview)
        [vc.wordsLabel!, vc.roundLabel!, vc.gameTypeLabel!].forEach {
            styleLabel($0, size: 16)
            $0.textAlignment = .left
        }
        [vc.wordsInTheHatLabel!, vc.roundLengthLabel!].forEach { styleLabel($0, size: 17); $0.textAlignment = .right }
        vc.playersTableView.backgroundColor = .clear
        vc.playersTableView.separatorColor = AppColors.separator
        vc.playersTableView.rowHeight = 54
        vc.playersTableView.contentInset = .zero
        vc.playersTableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 16)
        if #available(iOS 15.0, *) { vc.playersTableView.sectionHeaderTopPadding = 0 }
        vc.gameTypeSegmentControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .medium)], for: .normal)
        vc.gameTypeSegmentControl.tintColor = AppColors.primaryDark
        if #available(iOS 13.0, *) { vc.gameTypeSegmentControl.selectedSegmentTintColor = AppColors.secondary }
        vc.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "setup.done"
        vc.playersTableView.accessibilityIdentifier = "setup.players"
        canvas.arrange = { [weak vc] c in
            guard let vc = vc else { return }
            let r = c.contentRect
            let settingsHeight: CGFloat = min(350, max(260, r.height * 0.51))
            let tableHeight = max(60, min(CGFloat(vc.players.count + 1) * 54, r.height - settingsHeight - 114))
            playersTitle.frame = CGRect(x: r.minX, y: r.minY + 8, width: r.width, height: 28)
            roster.frame = CGRect(x: r.minX, y: r.minY + 46, width: r.width, height: tableHeight)
            vc.playersTableView.frame = roster.frame.insetBy(dx: 5, dy: 4)
            let top = roster.frame.maxY + 24
            settingsTitle.frame = CGRect(x: r.minX, y: top, width: r.width, height: 26)
            settings.frame = CGRect(x: r.minX, y: top + 40, width: r.width, height: settingsHeight)
            let inner = settings.frame.insetBy(dx: 18, dy: 10)
            let row: CGFloat = 48
            vc.wordsLabel.frame = CGRect(x: inner.minX, y: inner.minY, width: inner.width - 160, height: row)
            vc.wordsInTheHatLabel.frame = CGRect(x: inner.maxX - 151, y: inner.minY, width: 44, height: row)
            vc.wordsInTheHatStepper.frame = CGRect(x: inner.maxX - 94, y: inner.minY + 9, width: 94, height: 32)
            vc.roundLabel.frame = CGRect(x: inner.minX, y: inner.minY + row, width: inner.width - 160, height: row)
            vc.roundLengthLabel.frame = CGRect(x: inner.maxX - 151, y: inner.minY + row, width: 44, height: row)
            vc.roundLengthStepper.frame = CGRect(x: inner.maxX - 94, y: inner.minY + row + 9, width: 94, height: 32)
            let pickerHeight = settingsHeight - 3 * row - 68
            difficulty.frame = CGRect(x: inner.minX, y: inner.minY + 2 * row, width: inner.width * 0.4, height: pickerHeight)
            vc.difficultyPicker.frame = CGRect(x: inner.minX + inner.width * 0.4, y: inner.minY + 2 * row, width: inner.width * 0.6, height: pickerHeight)
            let skipY = inner.maxY - 48
            let lastY = skipY - 48
            vc.gameTypeLabel.frame = CGRect(x: inner.minX, y: lastY, width: inner.width * 0.36, height: 48)
            vc.gameTypeSegmentControl.frame = CGRect(x: inner.minX + inner.width * 0.38, y: lastY + 4, width: inner.width * 0.62, height: 40)
            toggle.sizeToFit()
            toggle.frame.origin = CGPoint(x: inner.maxX - toggle.bounds.width, y: skipY + (48 - toggle.bounds.height) / 2)
            skips.frame = CGRect(x: inner.minX, y: skipY, width: inner.width - 68, height: 48)
            for (i, y) in [inner.minY + row, inner.minY + 2 * row, lastY - 4, skipY].enumerated() {
                lines[i].frame = CGRect(x: inner.minX, y: y, width: inner.width, height: 1)
            }
        }
    }

    static func preparation(_ vc: PreparationViewController) {
        let progress = vc.loadingViewWidth.firstItem as? UIView
        let canvas = install(on: vc, keeping: [vc.speaker, vc.listener, vc.startButtonView])
        prepareContainer(vc.startButtonView, preserving: progress)
        actionSurface(vc.startButtonView)
        vc.startButtonView.startColor = AppColors.primary
        vc.startButtonView.finishColor = AppColors.primary
        progress?.backgroundColor = AppColors.secondary
        progress?.alpha = 0.25
        styleLabel(vc.startLabel, size: 28, serif: true, color: AppColors.surface)
        styleLabel(vc.holdToStartLabel, size: 12, color: AppColors.surface)
        [vc.speaker!, vc.listener!].forEach { styleLabel($0, size: 24, serif: true); $0.textAlignment = .center }
        let title = label(text("warm_your_turn"), size: 34, serif: true, centered: true)
        let avatarA = label(size: 40, serif: true, centered: true)
        let avatarB = label(size: 40, serif: true, centered: true)
        [avatarA, avatarB].forEach { $0.backgroundColor = AppColors.secondary; $0.clipsToBounds = true }
        let explains = label(text("warm_explains"), size: 15, color: AppColors.primaryDark, centered: true)
        let guesses = label(text("warm_guesses"), size: 15, color: AppColors.primaryDark, centered: true)
        [explains, guesses].forEach { $0.backgroundColor = AppColors.secondary; $0.layer.cornerRadius = 14; $0.clipsToBounds = true }
        let arrow = label("→", size: 35, color: AppColors.primaryDark, centered: true)
        [title, avatarA, avatarB, explains, guesses, arrow].forEach(canvas.addSubview)
        vc.startButtonView.accessibilityIdentifier = "handoff.start"
        vc.startLabel.accessibilityIdentifier = "handoff.start.label"
        canvas.arrange = { [weak vc] c in
            guard let vc = vc else { return }
            let r = c.contentRect
            let unit = r.height / 740
            title.frame = CGRect(x: r.minX, y: r.minY + 105 * unit, width: r.width, height: 70)
            let avatarSize: CGFloat = min(90, r.width * 0.24)
            let centerY = r.minY + 300 * unit
            let left = r.minX + r.width * 0.24, right = r.minX + r.width * 0.76
            avatarA.text = String((vc.speaker.text ?? "").prefix(1))
            avatarB.text = String((vc.listener.text ?? "").prefix(1))
            avatarA.frame = CGRect(x: left - avatarSize / 2, y: centerY - avatarSize / 2, width: avatarSize, height: avatarSize)
            avatarB.frame = CGRect(x: right - avatarSize / 2, y: centerY - avatarSize / 2, width: avatarSize, height: avatarSize)
            [avatarA, avatarB].forEach { $0.layer.cornerRadius = avatarSize / 2 }
            arrow.frame = CGRect(x: r.midX - 24, y: centerY - 24, width: 48, height: 48)
            vc.speaker.frame = CGRect(x: r.minX, y: avatarA.frame.maxY + 14, width: r.width * 0.48, height: 44)
            vc.listener.frame = CGRect(x: r.minX + r.width * 0.52, y: avatarB.frame.maxY + 14, width: r.width * 0.48, height: 44)
            explains.frame = CGRect(x: left - 60, y: vc.speaker.frame.maxY + 8, width: 120, height: 30)
            guesses.frame = CGRect(x: right - 60, y: vc.listener.frame.maxY + 8, width: 120, height: 30)
            vc.startButtonView.frame = CGRect(x: r.minX, y: r.maxY - 80, width: r.width, height: 70)
            layoutAction(vc.startButtonView, label: vc.startLabel, hint: vc.holdToStartLabel)
        }
    }

    static func preparationNavigation(_ vc: PreparationViewController) {
        vc.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "handoff.review"
        vc.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "handoff.menu"
        vc.navigationItem.rightBarButtonItems?.forEach { item in
            if let label = item.customView as? UILabel {
                styleLabel(label, size: 16, color: AppColors.primaryDark)
                label.sizeToFit()
            }
        }
    }

    static func round(_ vc: RoundViewController) {
        guard let guessed = vc.gotItLabel.superview else { return }
        let canvas = install(on: vc, keeping: [vc.timerView, vc.wordLabel, vc.redErrorView, guessed])
        prepareContainer(vc.timerView)
        prepareContainer(vc.redErrorView)
        prepareContainer(guessed)
        vc.timerView.backgroundColor = .clear
        vc.timerView.layer.cornerRadius = 0
        vc.timerView.clipsToBounds = false
        styleLabel(vc.timerLabel, size: 45, serif: true)
        vc.timerLabel.textAlignment = .center
        styleLabel(vc.wordLabel, size: 45, serif: true)
        vc.wordLabel.textAlignment = .center
        vc.wordLabel.numberOfLines = 3
        styleLabel(vc.errorLabel, size: 26, serif: true, color: AppColors.surface)
        styleLabel(vc.gotItLabel, size: 26, serif: true, color: AppColors.surface)
        let skipping = vc.gameInstance.allowsSkipping
        let secondaryActionColor = skipping ? AppColors.returnedWord : AppColors.fail
        actionSurface(vc.redErrorView, color: secondaryActionColor)
        actionSurface(guessed)
        vc.redErrorView.startColor = secondaryActionColor
        vc.redErrorView.finishColor = UIColor(red: 0.41, green: 0.17, blue: 0.10, alpha: 1)
        styleLabel(vc.actionHint, size: 13, color: AppColors.surface)
        vc.actionHint.textAlignment = .center
        vc.actionHint.accessibilityIdentifier = "round.actionHint"
        vc.redErrorView.addSubview(vc.actionHint)
        let wordCard = card()
        wordCard.layer.shadowColor = AppColors.textPrimary.cgColor
        wordCard.layer.shadowOffset = CGSize(width: 0, height: 5)
        wordCard.layer.shadowOpacity = 0.04
        wordCard.layer.shadowRadius = 14
        canvas.insertSubview(wordCard, at: 0)
        let cross = vc.actionSymbol
        styleLabel(cross, size: 32, color: AppColors.surface)
        cross.textAlignment = .center
        cross.isAccessibilityElement = false
        let check = label("✓", size: 36, color: AppColors.surface, centered: true)
        vc.redErrorView.addSubview(cross)
        guessed.addSubview(check)
        if !skipping { vc.redErrorView.accessibilityIdentifier = "round.mistake" }
        vc.timerLabel.accessibilityIdentifier = "round.timer"
        vc.wordLabel.accessibilityIdentifier = "round.word"
        guessed.subviews.compactMap { $0 as? UIButton }.first?.accessibilityIdentifier = "round.guessed"
        canvas.arrange = { [weak vc] c in
            guard let vc = vc else { return }
            let r = c.contentRect
            let unit = r.height / 840
            // Storyboard size-class font overrides can be reapplied after load.
            vc.wordLabel.font = displayFont(45)
            let diameter: CGFloat = 184 * min(1, unit)
            vc.timerView.frame = CGRect(x: r.midX - diameter / 2, y: r.minY + 90 * unit, width: diameter, height: diameter)
            vc.timerLabel.frame = vc.timerView.bounds.insetBy(dx: 10, dy: 10)
            wordCard.frame = CGRect(x: r.minX, y: r.minY + 355 * unit, width: r.width, height: 210 * unit)
            vc.wordLabel.frame = wordCard.frame.insetBy(dx: 16, dy: 16)
            let width = (r.width - 14) / 2
            vc.redErrorView.frame = CGRect(x: r.minX, y: r.maxY - 124, width: width, height: 112)
            guessed.frame = CGRect(x: r.minX + width + 14, y: r.maxY - 124, width: width, height: 112)
            layoutAction(vc.redErrorView, label: vc.errorLabel, symbol: cross)
            cross.frame = CGRect(x: 8, y: 6, width: width - 16, height: 29)
            vc.errorLabel.frame = CGRect(x: 6, y: 35, width: width - 12, height: 38)
            vc.actionHint.frame = CGRect(x: 6, y: 73, width: width - 12, height: 30)
            layoutAction(guessed, label: vc.gotItLabel, symbol: check)
            guessed.bringSubviewToFront(check)
        }
    }

    static func review(_ vc: EditWordsGuessedViewController) {
        let canvas = install(on: vc, keeping: [vc.guessedWordsTableView, vc.saveView])
        prepareContainer(vc.saveView)
        actionSurface(vc.saveView)
        styleLabel(vc.saveLabel, size: 27, serif: true, color: AppColors.surface)
        vc.guessedWordsTableView.backgroundColor = AppColors.surface
        vc.guessedWordsTableView.layer.cornerRadius = 20
        vc.guessedWordsTableView.layer.borderColor = AppColors.separator.cgColor
        vc.guessedWordsTableView.layer.borderWidth = 1
        vc.guessedWordsTableView.separatorStyle = .singleLine
        vc.guessedWordsTableView.separatorColor = AppColors.separator
        vc.guessedWordsTableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        vc.guessedWordsTableView.rowHeight = 58
        vc.guessedWordsTableView.tableFooterView = UIView()
        vc.guessedWordsTableView.sectionHeaderHeight = 0
        vc.guessedWordsTableView.sectionFooterHeight = 0
        let title = label(text("GUESSED_WORDS"), size: 30, serif: true)
        let hint = label(text("review_instruction"), size: 16, color: AppColors.textSecondary)
        title.accessibilityTraits.insert(.header)
        [title, hint].forEach(canvas.addSubview)
        if #available(iOS 15.0, *) { vc.guessedWordsTableView.sectionHeaderTopPadding = 0 }
        vc.saveView.subviews.compactMap { $0 as? UIButton }.first?.accessibilityIdentifier = "review.save"
        canvas.arrange = { [weak vc] c in
            guard let vc = vc else { return }
            let r = c.contentRect
            title.frame = CGRect(x: r.minX, y: r.minY + 16, width: r.width, height: 44)
            let hintHeight = ceil(hint.sizeThatFits(CGSize(width: r.width, height: .greatestFiniteMagnitude)).height)
            hint.frame = CGRect(x: r.minX, y: title.frame.maxY + 3, width: r.width, height: hintHeight)
            vc.saveView.frame = CGRect(x: r.minX, y: r.maxY - 80, width: r.width, height: 70)
            let top = hint.frame.maxY + 18
            let height = min(CGFloat(vc.wordList.count) * 58, max(0, vc.saveView.frame.minY - 16 - top))
            vc.guessedWordsTableView.frame = CGRect(x: r.minX, y: top, width: r.width, height: height)
            layoutAction(vc.saveView, label: vc.saveLabel)
        }
    }

    static func reviewCell(_ cell: GuessedWordCell, at indexPath: IndexPath) {
        styleLabel(cell.wordLabel, size: 19)
        cell.wordLabel.numberOfLines = 2
        cell.wordStatus.font = .systemFont(ofSize: 18, weight: .semibold)
        cell.wordStatus.textAlignment = .center
        cell.wordStatus.layer.cornerRadius = 16
        cell.wordStatus.clipsToBounds = true
        cell.wordStatus.backgroundColor = cell.wordStatus.textColor.withAlphaComponent(0.12)
        cell.backgroundColor = AppColors.surface
        cell.accessibilityIdentifier = "review.word.\(indexPath.row)"
    }
    static func playerCell(_ cell: PlayerTableViewCell) {
        cell.applyWarmAppearance()
    }
    static func addPlayerCell(_ cell: UITableViewCell) {
        cell.backgroundColor = .clear
        let images = cell.contentView.subviews.compactMap { $0 as? UIImageView }
        images.forEach { image in
            if #available(iOS 13.0, *) { image.image = UIImage(systemName: "person.badge.plus") }
            image.tintColor = AppColors.primaryDark
        }
        cell.contentView.subviews.compactMap { $0 as? UIButton }.first?.accessibilityIdentifier = "setup.addPlayer"
    }
}

/// A layout host with no input handlers, timers, navigation or game state.
final class WarmCanvas: UIView {
    var arrange: ((WarmCanvas) -> Void)?
    var contentRect: CGRect {
        let safe = bounds.inset(by: safeAreaInsets)
        let width = min(520, safe.width - 48)
        return CGRect(x: safe.midX - width / 2, y: safe.minY + 8, width: width, height: max(1, safe.height - 16))
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.background
    }
    required init?(coder: NSCoder) { fatalError("Use init(frame:)") }
    override func layoutSubviews() { super.layoutSubviews(); arrange?(self) }
}

extension WarmUI {
    /// Compact editorial header for scrollable secondary screens.
    static func brandHeader(title: String, subtitle: String, image: String, width: CGFloat) -> UIView {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 154))
        let panel = card()
        let art = UIImageView(image: UIImage(named: image))
        art.contentMode = .scaleAspectFit
        let heading = label(title, size: 30, serif: true)
        heading.adjustsFontSizeToFitWidth = true
        heading.minimumScaleFactor = 0.7
        let detail = label(subtitle, size: 15, color: AppColors.textSecondary)
        let copy = UIStackView(arrangedSubviews: [heading, detail]); copy.axis = .vertical; copy.spacing = 5
        host.addSubview(panel); panel.addSubview(art); panel.addSubview(copy)
        [panel, art, copy].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let panelWidth = panel.widthAnchor.constraint(equalTo: host.widthAnchor, constant: -40); panelWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: host.centerXAnchor), panelWidth, panel.widthAnchor.constraint(lessThanOrEqualToConstant: 520),
            panel.topAnchor.constraint(equalTo: host.topAnchor, constant: 12), panel.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -8),
            art.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12), art.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
            art.widthAnchor.constraint(equalTo: panel.widthAnchor, multiplier: 0.28), art.heightAnchor.constraint(equalTo: panel.heightAnchor, multiplier: 0.8),
            copy.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 18), copy.trailingAnchor.constraint(equalTo: art.leadingAnchor, constant: -6), copy.centerYAnchor.constraint(equalTo: panel.centerYAnchor)
        ])
        return host
    }

    static func sectionHeading(_ text: String, width: CGFloat) -> UIView {
        let host = UIView(); host.backgroundColor = AppColors.background
        let title = label(text, size: 16, color: AppColors.primaryDark)
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(title)
        let titleWidth = title.widthAnchor.constraint(equalTo: host.widthAnchor, constant: -48)
        titleWidth.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([title.centerXAnchor.constraint(equalTo: host.centerXAnchor),
            titleWidth, title.widthAnchor.constraint(lessThanOrEqualToConstant: 512),
            title.topAnchor.constraint(equalTo: host.topAnchor), title.bottomAnchor.constraint(equalTo: host.bottomAnchor)])
        return host
    }
}

extension WarmUI {
    static func scoreboard(_ vc: ResultsViewController) {
        let table = vc.resultsTableView!
        let canvas = install(on: vc, keeping: [table])
        table.backgroundColor = .clear
        table.rowHeight = 56
        table.separatorColor = AppColors.separator
        table.separatorInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        table.tableFooterView = UIView()
        if #available(iOS 15.0, *) { table.sectionHeaderTopPadding = 0 }
        let header = brandHeader(title: text("warm_scorecard"), subtitle: "", image: "WarmRulesResults", width: table.bounds.width)
        table.tableHeaderView = header
        canvas.arrange = { host in table.frame = host.contentRect }
    }

    private static func scoreColumns(_ labels: [UILabel], in cell: UITableViewCell, heading: Bool) {
        let host = cell.contentView
        guard host.viewWithTag(9080) == nil else { return }
        labels.forEach { $0.removeFromSuperview(); NSLayoutConstraint.deactivate($0.constraints) }
        host.subviews.forEach { $0.removeFromSuperview() }
        let row = UIStackView(arrangedSubviews: labels); row.tag = 9080; row.spacing = 3
        row.translatesAutoresizingMaskIntoConstraints = false; host.addSubview(row)
        host.backgroundColor = heading ? AppColors.secondary : AppColors.surface
        NSLayoutConstraint.activate([row.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -12), row.topAnchor.constraint(equalTo: host.topAnchor), row.bottomAnchor.constraint(equalTo: host.bottomAnchor)])
        for (i, label) in labels.enumerated() {
            label.textColor = i == 3 || heading ? AppColors.primaryDark : AppColors.textPrimary
            label.font = heading ? .systemFont(ofSize: 13, weight: .semibold) : (i == 3 ? displayFont(22) : .systemFont(ofSize: 17, weight: .medium))
            label.numberOfLines = 1; label.textAlignment = i == 0 ? .left : .center
            label.adjustsFontSizeToFitWidth = true; label.minimumScaleFactor = 0.73
            label.lineBreakMode = .byTruncatingTail
            if i > 0 { label.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.18).isActive = true }
        }
    }
    static func scoreHeader(_ cell: UITableViewCell) -> UITableViewCell {
        scoreColumns(["warm_player_placeholder", "warm_explained", "warm_guessed", "warm_total"].map { label(text($0)) }, in: cell, heading: true)
        return cell
    }
    static func scorePlayer(_ cell: PlayerResultCell) {
        scoreColumns([cell.playerNameLabel, cell.playerExplainedLabel, cell.playerGuessedLabel, cell.playerSumLabel], in: cell, heading: false)
    }
}
