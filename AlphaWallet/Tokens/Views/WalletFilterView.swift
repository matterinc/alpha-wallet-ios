// Copyright © 2018 Stormbird PTE. LTD.

import UIKit

protocol WalletFilterViewDelegate: class {
	func didPressWalletFilter(filter: WalletFilter, in filterView: WalletFilterView)
}

class WalletFilterView: UIView {
	private let allButton = UIButton(type: .system)
	private let currencyButton = UIButton(type: .system)
	private let assetsButton = UIButton(type: .system)
	private let collectiblesButton = UIButton(type: .system)
	private let highlightedBar = UIView()
	private var filter: WalletFilter = .all {
		didSet {
			viewModel.currentFilter = filter
			delegate?.didPressWalletFilter(filter: filter, in: self)
			configureButtonColors()
			configureHighlightedBar()
		}
	}
	private var highlightBarHorizontalConstraints: [NSLayoutConstraint]?
	weak var delegate: WalletFilterViewDelegate?
	private lazy var viewModel = WalletFilterViewModel(filter: filter)

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = viewModel.backgroundColor

		allButton.setTitle(R.string.localizable.aWalletContentsFilterAllTitle(), for: .normal)
		allButton.titleLabel?.font = viewModel.font
		allButton.addTarget(self, action: #selector(showAll), for: .touchUpInside)

		currencyButton.setTitle(R.string.localizable.aWalletContentsFilterCurrencyOnlyTitle(), for: .normal)
		currencyButton.titleLabel?.font = viewModel.font
		currencyButton.addTarget(self, action: #selector(showCurrencyOnly), for: .touchUpInside)

		assetsButton.setTitle(R.string.localizable.aWalletContentsFilterAssetsOnlyTitle(), for: .normal)
		assetsButton.titleLabel?.font = viewModel.font
		assetsButton.addTarget(self, action: #selector(showAssetsOnly), for: .touchUpInside)

		collectiblesButton.setTitle(R.string.localizable.aWalletContentsFilterCollectiblesOnlyTitle(), for: .normal)
		collectiblesButton.titleLabel?.font = viewModel.font
		collectiblesButton.addTarget(self, action: #selector(showCollectiblesOnly), for: .touchUpInside)

		let buttonsStackView = [allButton, currencyButton, assetsButton, collectiblesButton].asStackView(spacing: 20)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(buttonsStackView)

		let fullWidthBar = UIView()
		fullWidthBar.translatesAutoresizingMaskIntoConstraints = false
		fullWidthBar.backgroundColor = viewModel.barUnhighlightedColor
		addSubview(fullWidthBar)

		highlightedBar.translatesAutoresizingMaskIntoConstraints = false
		highlightedBar.backgroundColor = viewModel.barHighlightedColor
		fullWidthBar.addSubview(highlightedBar)

		let barHeightConstraint = fullWidthBar.heightAnchor.constraint(equalToConstant: 2)
		barHeightConstraint.priority = .defaultHigh
		let stackViewLeadingConstraint = buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17)
		stackViewLeadingConstraint.priority = .defaultHigh
		let stackViewTrailingConstraint = buttonsStackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -17)
		stackViewTrailingConstraint.priority = .defaultHigh
		NSLayoutConstraint.activate([
			stackViewLeadingConstraint,
			stackViewTrailingConstraint,
			buttonsStackView.topAnchor.constraint(equalTo: topAnchor),
			buttonsStackView.bottomAnchor.constraint(equalTo: fullWidthBar.topAnchor),

			fullWidthBar.leadingAnchor.constraint(equalTo: leadingAnchor),
			fullWidthBar.trailingAnchor.constraint(equalTo: trailingAnchor),
			barHeightConstraint,
			fullWidthBar.bottomAnchor.constraint(equalTo: bottomAnchor),

			highlightedBar.topAnchor.constraint(equalTo: fullWidthBar.topAnchor),
			highlightedBar.bottomAnchor.constraint(equalTo: fullWidthBar.bottomAnchor),
		])

		configureButtonColors()
		configureHighlightedBar()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	@objc func showAll() {
		filter = .all
	}

	@objc func showCurrencyOnly() {
		filter = .currencyOnly
	}

	@objc func showAssetsOnly() {
		filter = .assetsOnly
	}

	@objc func showCollectiblesOnly() {
		filter = .collectiblesOnly
	}

	func searchFor(keyword: String) {
		filter = .keyword(keyword)
	}

	func configureButtonColors() {
		allButton.setTitleColor(viewModel.colorForFilter(filter: .all), for: .normal)
		currencyButton.setTitleColor(viewModel.colorForFilter(filter: .currencyOnly), for: .normal)
		assetsButton.setTitleColor(viewModel.colorForFilter(filter: .assetsOnly), for: .normal)
		collectiblesButton.setTitleColor(viewModel.colorForFilter(filter: .collectiblesOnly), for: .normal)
	}

	func configureHighlightedBar() {
		var button: UIButton
		switch filter {
		case .all, .keyword:
			button = allButton
		case .currencyOnly:
			button = currencyButton
		case .assetsOnly:
			button = assetsButton
		case .collectiblesOnly:
            button = collectiblesButton
		}

		if let previousConstraints = highlightBarHorizontalConstraints {
			NSLayoutConstraint.deactivate(previousConstraints)
		}
		highlightBarHorizontalConstraints = [
			highlightedBar.leadingAnchor.constraint(equalTo: button.leadingAnchor),
			highlightedBar.trailingAnchor.constraint(equalTo: button.trailingAnchor),
		]
		if let constraints = highlightBarHorizontalConstraints {
			NSLayoutConstraint.activate(constraints)
		}
		UIView.animate(withDuration: 0.7) {
			self.layoutIfNeeded()
		}
	}
}
