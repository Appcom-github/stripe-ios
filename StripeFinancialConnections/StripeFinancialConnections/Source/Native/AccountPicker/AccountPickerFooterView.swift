//
//  AccountPickerFooterView.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 8/10/22.
//

import Foundation
@_spi(STP) import StripeUICore
import UIKit

@available(iOSApplicationExtension, unavailable)
final class AccountPickerFooterView: UIView {

    private let singleAccount: Bool
    private let institutionHasAccountPicker: Bool
    private let didSelectLinkAccounts: () -> Void

    private lazy var linkAccountsButton: Button = {
        let linkAccountsButton = Button(configuration: .financialConnectionsPrimary)
        linkAccountsButton.addTarget(self, action: #selector(didSelectLinkAccountsButton), for: .touchUpInside)
        linkAccountsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            linkAccountsButton.heightAnchor.constraint(equalToConstant: 56),
        ])
        return linkAccountsButton
    }()

    init(
        isStripeDirect: Bool,
        businessName: String?,
        permissions: [StripeAPI.FinancialConnectionsAccount.Permissions],
        singleAccount: Bool,
        institutionHasAccountPicker: Bool,
        didSelectLinkAccounts: @escaping () -> Void,
        didSelectMerchantDataAccessLearnMore: @escaping () -> Void
    ) {
        self.singleAccount = singleAccount
        self.institutionHasAccountPicker = institutionHasAccountPicker
        self.didSelectLinkAccounts = didSelectLinkAccounts
        super.init(frame: .zero)

        let verticalStackView = HitTestStackView(
            arrangedSubviews: [
                CreateDataAccessDisclosureView(
                    isStripeDirect: isStripeDirect,
                    businessName: businessName,
                    permissions: permissions,
                    didSelectLearnMore: didSelectMerchantDataAccessLearnMore
                ),
                linkAccountsButton,
            ]
        )
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 20
        addSubview(verticalStackView)
        addAndPinSubviewToSafeArea(verticalStackView)

        didSelectAccounts(count: 0) // set the button title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didSelectLinkAccountsButton() {
        didSelectLinkAccounts()
    }

    func didSelectAccounts(count numberOfAccountsSelected: Int) {
        linkAccountsButton.isEnabled = (numberOfAccountsSelected > 0)

        if institutionHasAccountPicker {
            linkAccountsButton.title = STPLocalizedString("Confirm", "A button that allows users to confirm the process of saving their bank accounts for future payments. This button appears in a screen that allows users to select which bank accounts they want to use to pay for something.")
        } else {
            let singleAccountButtonTitle = STPLocalizedString("Link account", "A button that allows users to confirm the process of saving their bank account for future payments. This button appears in a screen that allows users to select which bank accounts they want to use to pay for something.")
            let multipleAccountButtonTitle = STPLocalizedString("Link accounts", "A button that allows users to confirm the process of saving their bank accounts for future payments. This button appears in a screen that allows users to select which bank accounts they want to use to pay for something.")

            if numberOfAccountsSelected == 0 {
                if singleAccount {
                    linkAccountsButton.title = singleAccountButtonTitle
                } else {
                    linkAccountsButton.title = multipleAccountButtonTitle
                }
            } else if numberOfAccountsSelected == 1 {
                linkAccountsButton.title = singleAccountButtonTitle
            } else { // numberOfAccountsSelected > 1
                linkAccountsButton.title = multipleAccountButtonTitle
            }
        }
    }
}

@available(iOSApplicationExtension, unavailable)
private func CreateDataAccessDisclosureView(
    isStripeDirect: Bool,
    businessName: String?,
    permissions: [StripeAPI.FinancialConnectionsAccount.Permissions],
    didSelectLearnMore: @escaping () -> Void
) -> UIView {
    let stackView = HitTestStackView(
        arrangedSubviews: [
            MerchantDataAccessView(
                isStripeDirect: isStripeDirect,
                businessName: businessName,
                permissions: permissions,
                didSelectLearnMore: didSelectLearnMore
            ),
        ]
    )
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
        top: 10,
        leading: 12,
        bottom: 10,
        trailing: 12
    )
    stackView.backgroundColor = .backgroundContainer
    stackView.layer.cornerRadius = 8
    return stackView
}
