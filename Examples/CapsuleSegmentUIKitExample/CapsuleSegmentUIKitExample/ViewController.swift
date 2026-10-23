import UIKit

/// 用 UIKit（純 Swift 程式碼，不用 Storyboard）使用 CapsuleSegmentKit 的範例
final class ViewController: UIViewController {

    // MARK: - 範例 1：自訂顏色，切換頁面內容

    private let pageSegment = CapsuleSegmentHostingController(
        items: ["推薦", "追蹤中", "熱門"],
        style: CapsuleSegmentStyle(
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.15),
            selectedSegmentColor: .systemOrange,
            textColor: .systemOrange,
            selectedTextColor: .white
        )
    )

    private let pages: [(title: String, color: UIColor)] = [
        ("📰 推薦內容", .systemOrange),
        ("👥 追蹤中的內容", .systemBlue),
        ("🔥 熱門內容", .systemPink)
    ]

    private let contentView = UIView()
    private let contentLabel = UILabel()
    private let statusLabel = UILabel()

    // MARK: - 範例 2：預設樣式（2 個項目、兩側半圓）

    private let defaultSegment = CapsuleSegmentHostingController()

    // MARK: - 範例 3：自訂兩側弧度、關閉拖曳

    private let roundedSegment = CapsuleSegmentHostingController(
        items: ["日", "週", "月"],
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
        title = "UIKit 範例"
        view.backgroundColor = .systemBackground

        setupContent()
        layout()

        // 2️⃣ 監聽切換事件
        pageSegment.onSelectionChanged = { [weak self] index in
            self?.showPage(index, animated: true)
        }
        defaultSegment.onSelectionChanged = { [weak self] index in
            self?.statusLabel.text = "預設樣式選中：選項 \(index + 1)"
        }
        roundedSegment.onSelectionChanged = { [weak self] index in
            self?.statusLabel.text = "自訂弧度選中：\(["日", "週", "月"][index])"
        }

        showPage(pageSegment.selectedIndex, animated: false)
    }

    // MARK: - UI

    private func setupContent() {
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous

        contentLabel.font = .preferredFont(forTextStyle: .title2)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.text = "點擊或拖曳下方的 segment"
    }

    private func layout() {
        // 3️⃣ 把 segment 加進畫面（當作 child view controller）
        [pageSegment, defaultSegment, roundedSegment].forEach { addChild($0) }

        let jumpButton = UIButton(configuration: .tinted(), primaryAction: UIAction(title: "用程式切到「熱門」") { [weak self] _ in
            // 4️⃣ 也可以用程式設定選中項目
            self?.pageSegment.selectedIndex = 2
        })

        let stack = UIStackView(arrangedSubviews: [
            sectionTitle("範例 1：自訂顏色 + 切換內容"),
            pageSegment.view,
            contentView,
            jumpButton,
            sectionTitle("範例 2：預設樣式"),
            defaultSegment.view,
            sectionTitle("範例 3：cornerRadius 8、關閉拖曳"),
            roundedSegment.view,
            statusLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(24, after: jumpButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -16),

            // segment 預設高度為 40
            pageSegment.view.heightAnchor.constraint(equalToConstant: 40),
            defaultSegment.view.heightAnchor.constraint(equalToConstant: 40),
            roundedSegment.view.heightAnchor.constraint(equalToConstant: 40),
            contentView.heightAnchor.constraint(equalToConstant: 180)
        ])

        [pageSegment, defaultSegment, roundedSegment].forEach { $0.didMove(toParent: self) }
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }

    private func showPage(_ index: Int, animated: Bool) {
        let page = pages[index]
        let update = {
            self.contentLabel.text = page.title
            self.contentLabel.textColor = page.color
            self.contentView.backgroundColor = page.color.withAlphaComponent(0.12)
        }
        if animated {
            UIView.transition(with: contentView, duration: 0.25, options: .transitionCrossDissolve, animations: update)
        } else {
            update()
        }
    }
}
