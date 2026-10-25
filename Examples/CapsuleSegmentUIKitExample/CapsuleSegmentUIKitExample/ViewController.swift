import UIKit

/// Shows how to use CapsuleSegmentKit in a UIKit app built entirely in code.
final class ViewController: UIViewController {
    // MARK: - Example 1: Custom Colors That Switch Content

    private let pageSegment = CapsuleSegmentHostingController(
        items: ["For You", "Following", "Trending"],
        style: CapsuleSegmentStyle(
                
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.15),
            selectedSegmentColor: .systemOrange,
            textColor: .systemOrange,
            selectedTextColor: .white
        )
    )

    private let pages: [(title: String, color: UIColor)] = [
        ("Recommended for You", .systemOrange),
        ("From People You Follow", .systemBlue),
        ("Trending Now", .systemPink),
    ]

    private let contentView = UIView()
    private let contentLabel = UILabel()
    private let statusLabel = UILabel()

    // MARK: - Example 2: Default Style

    private let defaultSegment = CapsuleSegmentHostingController()

    // MARK: - Example 3: Custom Corner Radius Without Dragging

    private let roundedSegment = CapsuleSegmentHostingController(
        items: ["Day", "Week", "Month"],
        style: CapsuleSegmentStyle(
            backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.15),
            selectedSegmentColor: .systemIndigo,
            textColor: .systemIndigo,
            selectedTextColor: .white,
            cornerRadius: 8,
            isDragEnabled: false
        )
    )

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit Example"
        view.backgroundColor = .systemBackground

        configureContent()
        layOutViews()

        pageSegment.onSelectionChanged = { [weak self] index in
            self?.showPage(at: index, animated: true)
        }
        defaultSegment.onSelectionChanged = { [weak self] index in
            guard let self else { return }
            statusLabel.text = "Default style selected: \(defaultSegment.items[index])"
        }
        roundedSegment.onSelectionChanged = { [weak self] index in
            guard let self else { return }
            statusLabel.text = "Custom radius selected: \(roundedSegment.items[index])"
        }

        showPage(at: pageSegment.selectedIndex, animated: false)
    }

    // MARK: - Views

    private func configureContent() {
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous

        contentLabel.font = .preferredFont(forTextStyle: .title2)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.text = "Tap or drag a segment above."
    }

    private func layOutViews() {
        // Add each segment as a child view controller.
        [pageSegment, defaultSegment, roundedSegment].forEach { addChild($0) }

        let switchAction = UIAction(title: "Switch to Trending in Code") { [weak self] _ in
            self?.pageSegment.selectedIndex = 2
        }
        let switchButton = UIButton(configuration: .tinted(), primaryAction: switchAction)

        let stackView = UIStackView(arrangedSubviews: [
            makeSectionTitle("Example 1: Custom Colors"),
            pageSegment.view,
            contentView,
            switchButton,
            makeSectionTitle("Example 2: Default Style"),
            defaultSegment.view,
            makeSectionTitle("Example 3: Corner Radius 8, No Dragging"),
            roundedSegment.view,
            statusLabel,
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.setCustomSpacing(24, after: switchButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -16),

            // The control's default height is 40 points.
            pageSegment.view.heightAnchor.constraint(equalToConstant: 40),
            defaultSegment.view.heightAnchor.constraint(equalToConstant: 40),
            roundedSegment.view.heightAnchor.constraint(equalToConstant: 40),
            contentView.heightAnchor.constraint(equalToConstant: 180),
        ])

        [pageSegment, defaultSegment, roundedSegment].forEach { $0.didMove(toParent: self) }
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }

    private func showPage(at index: Int, animated: Bool) {
        let page = pages[index]
        let update = {
            self.contentLabel.text = page.title
            self.contentLabel.textColor = page.color
            self.contentView.backgroundColor = page.color.withAlphaComponent(0.12)
        }
        if animated {
            UIView.transition(
                with: contentView,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: update
            )
        } else {
            update()
        }
    }
}
