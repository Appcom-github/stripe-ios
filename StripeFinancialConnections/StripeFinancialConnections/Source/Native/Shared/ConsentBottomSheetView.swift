//
//  ConsentBottomSheetView.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 7/13/22.
//

import Foundation
import SafariServices
@_spi(STP) import StripeUICore
import UIKit

@available(iOSApplicationExtension, unavailable)
final class ConsentBottomSheetView: UIView {

    private let didSelectOKAction: () -> Void

    init(
        model: ConsentBottomSheetModel,
        didSelectOK: @escaping () -> Void,
        didSelectURL: @escaping (URL) -> Void
    ) {
        self.didSelectOKAction = didSelectOK
        super.init(frame: .zero)
        backgroundColor = .customBackgroundColor

        let padding: CGFloat = 24
        let verticalStackView = HitTestStackView(
            arrangedSubviews: [
                CreateContentView(
                    headerTitle: model.title,
                    headerSubtitle: model.subtitle,
                    bulletItems: model.body.bullets,
                    extraNotice: model.extraNotice,
                    learnMoreText: model.learnMore,
                    didSelectURL: didSelectURL
                ),
                CreateFooterView(
                    cta: model.cta,
                    actionTarget: self
                ),
            ]
        )
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 24
        verticalStackView.isLayoutMarginsRelativeArrangement = true
        verticalStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: padding,
            leading: padding,
            bottom: padding,
            trailing: padding
        )
        addAndPinSubview(verticalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners() // needs to be in `layoutSubviews` to get the correct size for the mask
    }

    private func roundCorners() {
        clipsToBounds = true
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 8, height: 8)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    @IBAction fileprivate func didSelectOK() {
        didSelectOKAction()
    }
}

@available(iOSApplicationExtension, unavailable)
private func CreateContentView(
    headerTitle: String,
    headerSubtitle: String?,
    bulletItems: [FinancialConnectionsBulletPoint],
    extraNotice: String?,
    learnMoreText: String,
    didSelectURL: @escaping (URL) -> Void
) -> UIView {
    let verticalStackView = HitTestStackView(
        arrangedSubviews: {
            var subviews: [UIView] = []
            subviews.append(
                CreateHeaderView(
                    title: headerTitle,
                    subtitle: headerSubtitle,
                    didSelectURL: didSelectURL
                )
            )
            bulletItems.forEach { bulletItem in
                subviews.append(
                    CreateBulletinView(
                        title: bulletItem.title,
                        subtitle: bulletItem.content,
                        iconUrl: bulletItem.icon?.default,
                        didSelectURL: didSelectURL
                    )
                )
            }
            if let extraNotice = extraNotice {
                let extraNoticeLabel = ClickableLabel(
                    font: .stripeFont(forTextStyle: .detail),
                    boldFont: .stripeFont(forTextStyle: .detailEmphasized),
                    linkFont: .stripeFont(forTextStyle: .detailEmphasized),
                    textColor: .textSecondary
                )
                extraNoticeLabel.setText(extraNotice, action: didSelectURL)
                subviews.append(extraNoticeLabel)
            }
            subviews.append(
                CreateLearnMoreLabel(
                    text: learnMoreText,
                    didSelectURL: didSelectURL
                )
            )
            return subviews
        }()
    )
    verticalStackView.axis = .vertical
    verticalStackView.spacing = 16
    return verticalStackView
}

@available(iOSApplicationExtension, unavailable)
private func CreateHeaderView(
    title: String,
    subtitle: String?,
    didSelectURL: @escaping (URL) -> Void
) -> UIView {
    let verticalStack = UIStackView()
    verticalStack.axis = .vertical
    verticalStack.spacing = 4

    let headerLabel = ClickableLabel(
        font: .stripeFont(forTextStyle: .heading),
        boldFont: .stripeFont(forTextStyle: .heading),
        linkFont: .stripeFont(forTextStyle: .heading),
        textColor: .textPrimary
    )
    headerLabel.setText(title, action: didSelectURL)
    verticalStack.addArrangedSubview(headerLabel)

    if let subtitle = subtitle {
        let subtitleLabel = ClickableLabel(
            font: .stripeFont(forTextStyle: .body),
            boldFont: .stripeFont(forTextStyle: .bodyEmphasized),
            linkFont: .stripeFont(forTextStyle: .bodyEmphasized),
            textColor: .textPrimary
        )
        subtitleLabel.setText(subtitle, action: didSelectURL)
        verticalStack.addArrangedSubview(subtitleLabel)
    }
    return verticalStack
}

@available(iOSApplicationExtension, unavailable)
private func CreateBulletinView(
    title: String?,
    subtitle: String?,
    iconUrl: String?,
    didSelectURL: @escaping (URL) -> Void
) -> UIView {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    if let iconUrl = iconUrl {
        imageView.setImage(with: iconUrl)
    } else {
        imageView.image = Image.bullet.makeImage().withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .textPrimary
    }
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 16),
        imageView.heightAnchor.constraint(equalToConstant: 16),
    ])

    let horizontalStackView = HitTestStackView(
        arrangedSubviews: [
            imageView,
            BulletPointLabelView(
                title: title,
                content: subtitle,
                didSelectURL: didSelectURL
            ),
        ]
    )
    horizontalStackView.axis = .horizontal
    horizontalStackView.spacing = 10
    horizontalStackView.alignment = .top
    return horizontalStackView
}

@available(iOSApplicationExtension, unavailable)
private func CreateLearnMoreLabel(
    text: String,
    didSelectURL: @escaping (URL) -> Void
) -> UIView {
    let label = ClickableLabel(
        font: .stripeFont(forTextStyle: .detail),
        boldFont: .stripeFont(forTextStyle: .detailEmphasized),
        linkFont: .stripeFont(forTextStyle: .detailEmphasized),
        textColor: .textSecondary
    )
    label.setText(text, action: didSelectURL)
    return label
}

@available(iOSApplicationExtension, unavailable)
private func CreateFooterView(
    cta: String,
    actionTarget: ConsentBottomSheetView
) -> UIView {
    let okButton = Button(configuration: .financialConnectionsPrimary)
    okButton.title = cta
    okButton.addTarget(actionTarget, action: #selector(ConsentBottomSheetView.didSelectOK), for: .touchUpInside)
    okButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        okButton.heightAnchor.constraint(equalToConstant: 56),
    ])
    return okButton
}

#if DEBUG

import SwiftUI

@available(iOSApplicationExtension, unavailable)
private struct ConsentBottomSheetViewUIViewRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> ConsentBottomSheetView {
        ConsentBottomSheetView(
            model: ConsentBottomSheetModel(
                title: "When will [Merchant] use your data?",
                subtitle: "[Merchant] will use your account and routing number, balances and transactions when:",
                body: ConsentBottomSheetModel.Body(
                    bullets: [
                        FinancialConnectionsBulletPoint(
                            icon: FinancialConnectionsImage(default: nil),
                            title: nil,
                            content: "Transferring money between your bank account and Merchant"
                        ),
                    ]
                ),
                extraNotice: nil,
                learnMore: "[Learn more](https://www.stripe.com)",
                cta: "Got it"
            ),
            didSelectOK: {},
            didSelectURL: { _ in }
        )
    }

    func updateUIView(_ uiView: ConsentBottomSheetView, context: Context) {
        uiView.sizeToFit()
    }
}

@available(iOSApplicationExtension, unavailable)
struct ConsentBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            VStack {
                    ConsentBottomSheetViewUIViewRepresentable()
                        .frame(width: 320)
                        .frame(height: 350)

            }
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
        }
    }
}

#endif
