//
//  HomeTabViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 27/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class HomeTabViewController: UIViewController, Tab {
    
    private static let onboardingHeight: CGFloat = 230
    
    @IBOutlet weak var passiveContainerView: UIView!
    @IBOutlet weak var centreBar: UIView!
    
    var miniOnboardingController: OnboardingMiniViewController?
    
    weak var tabDelegate: HomeTabDelegate?
    
    let omniBarStyle: OmniBar.Style = .home
    let showsUrlInOmniBar = false
    
    var name: String? = UserText.homeLinkTitle
    var url: URL? = AppUrls.base
    var favicon: URL? = AppUrls.favicon
    
    var canGoBack = false
    var canGoForward = false
    var canShare = false
    
    private var activeMode = false
    private lazy var tabIconMaker = TabIconMaker()
    private lazy var groupData = GroupDataStore()
    
    static func loadFromStoryboard() -> HomeTabViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabViewController") as! HomeTabViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObserver()
    }
    
    deinit {
        removeKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetNavigationBar()
        activeMode = false
        refreshMode()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissMiniOnboardingFlow()
    }
    
    private func resetNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    private func refreshMode() {
        if activeMode {
            enterActiveMode()
        } else {
            enterPassiveMode()
        }
    }
    
    @IBAction func onEnterActiveModeTapped(_ sender: Any) {
        enterActiveMode()
    }
    
    @IBAction func onEnterPassiveModeTapped(_ sender: Any) {
        enterPassiveMode()
    }
    
    func enterPassiveMode() {
        navigationController?.isNavigationBarHidden = true
        passiveContainerView.isHidden = false
        dismissMiniOnboardingFlow()
        tabDelegate?.homeTabDidDeactivateOmniBar(homeTab: self)
    }
    
    func enterActiveMode() {
        navigationController?.isNavigationBarHidden = false
        passiveContainerView.isHidden = true
        showMiniOnboardingFlow()
        tabDelegate?.homeTabDidActivateOmniBar(homeTab: self)
    }
    
    private func showMiniOnboardingFlow() {
        dismissMiniOnboardingFlow()
        let miniOnboardingController = OnboardingMiniViewController.loadFromStoryboard()
        self.miniOnboardingController = miniOnboardingController
        addChildViewController(miniOnboardingController)
        view.addSubview(miniOnboardingController.view)
    }
    
    private func dismissMiniOnboardingFlow() {
        miniOnboardingController?.view.removeFromSuperview()
        miniOnboardingController?.removeFromParentViewController()
        miniOnboardingController = nil
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] else { return }
        guard let keyboardValue = keyboardInfo as? NSValue else { return }
        let keyboardRect = keyboardValue.cgRectValue
        if UIApplication.shared.statusBarOrientation.isLandscape, traitCollection.verticalSizeClass == .compact {
            centreMiniOnboardingScreen()
        } else {
            floatMiniOnboaridngScreenAboveKeyboard(keyboardRect: keyboardRect)
        }
    }
    
    private func centreMiniOnboardingScreen() {
        centreMiniOnboardingScreenWithin(height: view.frame.height)
    }
    
    private func floatMiniOnboaridngScreenAboveKeyboard(keyboardRect: CGRect) {
        let availableHeight = view.frame.height - keyboardRect.height
        centreMiniOnboardingScreenWithin(height: availableHeight)
    }
    
    private func centreMiniOnboardingScreenWithin(height: CGFloat) {
        guard let onboardingView = miniOnboardingController?.view else { return }
        let navbarHeight = navigationController?.navigationBar.frame.height ?? 0
        let decorHeight = InterfaceMeasurement.defaultStatusBarHeight + navbarHeight
        let availableHeight = height - decorHeight
        let y = decorHeight + (availableHeight / 2) - (HomeTabViewController.onboardingHeight / 2)
        onboardingView.frame = CGRect(x: 0, y: y, width: view.frame.width, height: HomeTabViewController.onboardingHeight)
    }
    
    func load(url: URL) {
        tabDelegate?.homeTab(self, didRequestUrl: url)
    }
    
    func goBack() {}
    
    func goForward() {}
    
    func reload() {}
    
    func dismiss() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
    func destroy() {
        dismiss()
    }
    
    func omniBarWasDismissed() {
        enterPassiveMode()
    }
}
