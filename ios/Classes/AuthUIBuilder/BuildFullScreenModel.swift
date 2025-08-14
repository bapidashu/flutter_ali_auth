//
//  BuildFullScreenModel.swift
//  ali_auth
//
//  Created by kangkang on 2022/10/1.
//

import ATAuthSDK
import CoreData
import Foundation
import UIKit

extension AuthUIBuilder {
    // MARK: - 构建全屏授权页面

    func buildFullScreenModel(config: AuthUIConfig) -> TXCustomModel {
        print("1111--\(String(describing: config))")
        var kHorizontal: Bool?
        var kLoginButtonSize = CGSize()
        let model = TXCustomModel()

        model.supportedInterfaceOrientations = .portrait

        // status bar
        if #available(iOS 13.0, *) {
            model.preferredStatusBarStyle = UIStatusBarStyle.darkContent
        } else {
            // Fallback on earlier versions
            model.preferredStatusBarStyle = UIStatusBarStyle.default
        }

        model.prefersStatusBarHidden = config.prefersStatusBarHidden ?? false

        if let backgroundImage = config.backgroundImage {
            if let image = FlutterAssetImage(backgroundImage) {
                model.backgroundImage = image
                model.backgroundImageContentMode = UIView.ContentMode.scaleAspectFill
            }
        } else {
            if let backgroundColor = config.backgroundColor {
                model.backgroundColor = backgroundColor.uicolor()
            } else {
                if #available(iOS 13.0, *) {
                    model.backgroundColor = UIColor.systemBackground
                }
            }
        }

        // customViewBlock
        if let customViewBlockList = config.customViewBlockList {
            buildCustomViewBlock(model: model, customViewConfigList: customViewBlockList)
        }

        // Nav

        model.navIsHidden = config.navIsHidden ?? false
        model.hideNavBackItem = config.hideNavBackItem ?? false
        model.navColor = config.navColor?.uicolor() ?? UIColor.white
        model.navBackImage = { () -> UIImage in
            guard let navBackImage = config.navBackImage else {
                return BundleImage("icon_nav_back_gray")!
            }
            return FlutterAssetImage(navBackImage)!
        }()

        var navTitleAttributes: [NSAttributedString.Key: Any] = [:]

        if let navTitleColor = config.navTitleColor {
            navTitleAttributes.updateValue(navTitleColor.uicolor(), forKey: NSAttributedString.Key.foregroundColor)
        }

        if let navTitleSize = config.navTitleSize {
            navTitleAttributes.updateValue(UIFont(name: PF_Regular, size: CGFloat(navTitleSize))!, forKey: NSAttributedString.Key.font)
        }

        model.navTitle = NSAttributedString(string: config.navTitle ?? "", attributes: navTitleAttributes)
        // Logo
        model.logoIsHidden = config.logoIsHidden ?? false

        if let logoImage = config.logoImage {
            if let logoImageAssets = FlutterAssetImage(logoImage) {
                model.logoImage = logoImageAssets
            }

            // logo的位置
            model.logoFrameBlock = {
                screenSize, _, _ -> CGRect in
                let offsetX: CGFloat = .init(config.logoFrameOffsetX ?? (Float(screenSize.width) / 2 - kLogoSize / 2))
                let offsetY: CGFloat = .init(config.logoFrameOffsetY ?? kLogoOffset)
                let imageWidth: CGFloat = .init(config.logoWidth ?? kLogoSize)
                let imageHeight: CGFloat = .init(config.logoHeight ?? kLogoSize)
                return CGRect(x: offsetX, y: offsetY, width: imageWidth, height: imageHeight)
            }
        }

        // Slogon
        model.sloganIsHidden = config.sloganIsHidden ?? false

        var sloganTextAtrributes: [NSAttributedString.Key: Any] = [:]

        sloganTextAtrributes.updateValue((config.sloganTextColor ?? "#151515").uicolor(), forKey: NSMutableAttributedString.Key.foregroundColor)

        sloganTextAtrributes.updateValue(UIFont(name: PF_Regular, size: CGFloat(config.sloganTextSize ?? Font_28))!, forKey: NSMutableAttributedString.Key.font)

        model.sloganText = NSAttributedString(string: config.sloganText ?? "欢迎登录\(AppDisplayName)", attributes: sloganTextAtrributes)

        model.sloganFrameBlock = {
            screenSize, _, frame -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                return CGRect.zero
            }
            let offsetX = CGFloat(config.sloganFrameOffsetX ?? Float(frame.origin.x))

            let offsetY = CGFloat(config.sloganFrameOffsetY ?? kLogoOffset + kLogoSize + kPadding)

            return CGRect(x: offsetX, y: offsetY, width: frame.width, height: frame.height)
        }
        // Phone Number

        model.numberColor = (config.numberColor ?? "#2BD180").uicolor()
        model.numberFont = UIFont(name: PF_Bold, size: CGFloat(config.numberFontSize ?? Font_24))!

        model.numberFrameBlock = {
            screenSize, _, frame -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                return CGRect.zero
            }

            let offsetX = CGFloat(config.numberFrameOffsetX ?? Float(frame.origin.x))

            let offsetY = CGFloat(config.numberFrameOffsetY ?? kLogoOffset + kLogoSize + Float(Font_28) + kPadding * 3)

            return CGRect(x: offsetX, y: offsetY, width: frame.width, height: frame.height)
        }

        // login button
        var loginBtnBgImgs = [UIImage]()

        if let loginBtnNormalImage = config.loginBtnNormalImage {
            if let loginBtnNormal = FlutterAssetImage(loginBtnNormalImage) {
                loginBtnBgImgs.append(loginBtnNormal)
            }
        }
        if let loginBtnUnableImage = config.loginBtnUnableImage {
            if let loginBtnUnable = FlutterAssetImage(loginBtnUnableImage) {
                loginBtnBgImgs.append(loginBtnUnable)
            }
        }
        if let loginBtnPressedImage = config.loginBtnPressedImage {
            if let loginBtnPressed = FlutterAssetImage(loginBtnPressedImage) {
                loginBtnBgImgs.append(loginBtnPressed)
            }
        }

        if !loginBtnBgImgs.isEmpty {
            model.loginBtnBgImgs = loginBtnBgImgs
        }

        var loginAttribute: [NSAttributedString.Key: Any] = [:]

        loginAttribute.updateValue(config.loginBtnTextColor?.uicolor() ?? UIColor.white, forKey: NSAttributedString.Key.foregroundColor)

        loginAttribute.updateValue(UIFont(name: PF_Bold, size: CGFloat(config.loginBtnTextSize ?? Font_17))!, forKey: NSAttributedString.Key.font)

        model.loginBtnText = NSAttributedString(string: config.loginBtnText ?? "一键登录", attributes: loginAttribute)

        var loginButtonOffsetY: Float = 0.0

        model.loginBtnFrameBlock = { screenSize, _, _ -> CGRect in

            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                kLoginButtonSize.width = CGFloat(config.loginBtnWidth ?? 296)
                kLoginButtonSize.height = CGFloat(config.loginBtnHeight ?? 48)
            } else {
                kLoginButtonSize.width = CGFloat(config.loginBtnWidth ?? Float(screenSize.width) * 0.85)
                kLoginButtonSize.height = CGFloat(config.loginBtnHeight ?? 48)
            }

            let offsetX = CGFloat(config.loginBtnFrameOffsetX ?? Float(screenSize.width / 2 - kLoginButtonSize.width / 2))

            // let kMiddleHeight = Float(screenSize.height / 2)

            loginButtonOffsetY = config.loginBtnFrameOffsetY ?? Float(screenSize.height) * 0.55 + kPadding

            let offsetY = CGFloat(loginButtonOffsetY)

            return CGRect(x: offsetX, y: offsetY, width: kLoginButtonSize.width, height: kLoginButtonSize.height)
        }

        // 其他登录
        model.changeBtnIsHidden = config.changeBtnIsHidden ?? false

        var changeBtnAttribute: [NSAttributedString.Key: Any] = [:]

        changeBtnAttribute.updateValue(config.changeBtnTextColor?.uicolor() ?? UIColor.darkGray, forKey: NSAttributedString.Key.foregroundColor)

        changeBtnAttribute.updateValue(UIFont(name: PF_Regular, size: CGFloat(config.changeBtnTextSize ?? Font_14))!, forKey: NSAttributedString.Key.font)

        model.changeBtnTitle = NSAttributedString(string: config.changeBtnTitle ?? "切换其他登录方式", attributes: changeBtnAttribute)

        model.changeBtnFrameBlock = { screenSize, _, frame -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                return CGRect.zero
            }
            let width: CGFloat = frame.width // 150

            let height: CGFloat = frame.height // 38

            let offsetX: CGFloat = screenSize.width / 2 - (width / 2)
            // let offsetY: CGFloat = screenSize.width / 2 + kLoginButtonSize.height + CGFloat(kPadding)

            let offsetY = CGFloat(config.changeBtnFrameOffsetY ?? loginButtonOffsetY + Float(kLoginButtonSize.height) + kPadding)

            return CGRect(x: offsetX, y: offsetY, width: width, height: height)
        }

        // CheckBox
        model.checkBoxIsChecked = config.checkBoxIsChecked ?? false
        model.checkBoxIsHidden = config.checkBoxIsHidden ?? false

        var checkBoxImages = [UIImage]()

        if config.uncheckImage != nil {
            if let uncheckIcon = FlutterAssetImage(config.uncheckImage) {
                checkBoxImages.append(uncheckIcon)
            }
        } else {
            checkBoxImages.append(BundleImage("icon_uncheck")!)
        }

        if config.checkedImage != nil {
            if let checkedIcon = FlutterAssetImage(config.checkedImage) {
                checkBoxImages.append(checkedIcon)
            }
        } else {
            checkBoxImages.append(BundleImage("icon_check")!)
        }

        if !checkBoxImages.isEmpty {
            model.checkBoxImages = checkBoxImages
        }

        model.checkBoxImageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        model.checkBoxWH = CGFloat((config.checkBoxWH ?? 15))

        // privacy
        model.privacyOne = [config.privacyOneName ?? "《使用协议》", config.privacyOneUrl ?? "http://******"]

        model.privacyTwo = [config.privacyTwoName ?? "《隐私协议》", config.privacyTwoUrl ?? "http://******"]

        model.privacyConectTexts = [config.privacyConnectTexts ?? "和", config.privacyConnectTexts ?? "和"]

        model.privacyOperatorPreText = config.privacyOperatorPreText ?? "《"

        model.privacyOperatorSufText = config.privacyOperatorSufText ?? "》"

        model.privacyPreText = config.privacyPreText ?? "已阅读并同意"

        model.privacyColors = [UIColor.darkGray, config.privacyFontColor?.uicolor() ?? UIColor.systemBlue]

        model.privacyFont = UIFont(name: PF_Regular, size: CGFloat(config.privacyFontSize ?? Font_14))!

        model.privacyFrameBlock = { screenSize, _, _ -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }

            let screenHeight = Float(screenSize.height)

            var offsetY: CGFloat

            if kHorizontal! {
                // (18.0, 715.5, 370.0, 39.5)
                offsetY = CGFloat(config.privacyFrameOffsetY ?? screenHeight - kPadding - kBottomInset)
            } else {
                offsetY = CGFloat(config.privacyFrameOffsetY ?? screenHeight - kPadding - 80)
            }

            let offsetX = CGFloat(screenSize.width / 2 - 148)

            return CGRect(x: offsetX, y: offsetY, width: 296, height: 48)
        }

        if let privacyNavBackIcon = BundleImage("icon_nav_back_gray") {
            model.privacyNavBackImage = privacyNavBackIcon
        }

                
        model.privacyAlertIsNeedShow = config.privacyAlertIsNeedShow ?? false
        print("1111--准备设置了privacyAlertIsNeedShow")
        if (model.privacyAlertIsNeedShow) {
            print("1111--已经设置了privacyAlertIsNeedShow,哈哈哈")
            //需要自动登录
            model.privacyAlertIsNeedAutoLogin = true
            //左上,左下,右下,右上的圆角
            model.privacyAlertCornerRadiusArray = [12,0,0,12]
            //弹窗背景颜色
            model.privacyAlertBackgroundColor = UIColor.init(hexString: "#272A35", alpha: 1)
            //弹窗标题
            model.privacyAlertTitleContent = "用户协议与隐私保护"
            //弹窗标题字体
            model.privacyAlertTitleFont = UIFont.systemFont(ofSize: 16,weight: .medium)
            //弹窗标题文字颜色
            model.privacyAlertTitleColor = UIColor.white.withAlphaComponent(0.9)
            //弹窗标题文字背景颜色
            model.privacyAlertTitleBackgroundColor = UIColor.init(hexString: "#272A35", alpha: 1)
            //标题位置,默认居中
            model.privacyAlertTitleAlignment = NSTextAlignment.center
            //协议内容文字大小
            model.privacyAlertContentFont = UIFont.systemFont(ofSize: 14)
            //协议内容间距
             model.privacyAlertLineSpaceDp = 4
            //协议内容背景色
            model.privacyAlertContentBackgroundColor = UIColor.init(hexString: "#272A35", alpha: 1)
            //协议内容颜色数组
            model.privacyAlertContentColors = [UIColor.white.withAlphaComponent(0.6),UIColor.white]
            //前缀文案
            model.privacyAlertPreText = "请先同意"
            //后缀文案
            model.privacyAlertSufText = ""
            //按钮文字
            model.privacyAlertBtnContent = "同意并登录"
            //按钮字体
            model.privacyAlertButtonFont = UIFont.systemFont(ofSize: 16,weight: .medium)
            //关闭按钮
            model.privacyAlertCloseButtonIsNeedShow = true
            //关闭按钮图片
            if let image = FlutterAssetImage("assets/login/login_alert_close_btn_img.png") {
                model.privacyAlertCloseButtonImage = image
            }
            //按钮背景图片
            if let image = FlutterAssetImage("assets/login/login_alert_btn_bg.png") {
                model.privacyAlertBtnBackgroundImages = [image,image]
            }
            //弹窗尺寸
            model.privacyAlertFrameBlock = { screenSize, surperSize, defaultFrame -> CGRect in
                return CGRect(x: 0, y: screenSize.height-244, width: screenSize.width, height: 244)
            }
            //标题尺寸
            model.privacyAlertTitleFrameBlock = { screenSize, surperSize, defaultFrame -> CGRect in
                return CGRect(x: defaultFrame.origin.x, y: 16, width: defaultFrame.size.width, height: defaultFrame.size.height)
            }
            //弹窗内容尺寸
            model.privacyAlertPrivacyContentFrameBlock = { screenSize, surperSize, defaultFrame -> CGRect in
                return CGRect(x: defaultFrame.origin.x+25, y: defaultFrame.origin.y+24, width: screenSize.width-50, height: defaultFrame.size.height+10)
            }
            //确认按钮尺寸
            model.privacyAlertButtonFrameBlock = { screenSize, surperSize, defaultFrame -> CGRect in
                return CGRect(x: 32, y: defaultFrame.origin.y+36, width: screenSize.width-64, height: defaultFrame.size.height)
            }
            //关闭按钮尺寸
            model.privacyAlertCloseFrameBlock = { screenSize, surperSize, defaultFrame -> CGRect in
                print("1111----关闭按钮frame=\(defaultFrame)")
                return CGRect(x: defaultFrame.origin.x+6, y: 12, width: 30, height: 30)
            }
        }

        return model
    }
}

import UIKit

extension UIColor {
    /// 用 16 进制值初始化颜色
    /// - Parameters:
    ///   - hex: 16 进制颜色值（支持格式：0xFFFFFF、0xFFFF00FF 等，前6位为RGB，后2位可选为透明度）
    ///   - alpha: 额外指定的透明度（0~1，若 hex 包含透明度，此参数会覆盖它）
    convenience init(hex: UInt32, alpha: CGFloat? = nil) {
        // 提取 RGB 分量（前6位）
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        // 提取透明度（若 hex 包含后2位，则取后2位；否则默认为1）
        let hexAlpha = CGFloat((hex >> 24) & 0xFF) / 255.0
        let finalAlpha = alpha ?? (hex > 0xFFFFFF ? hexAlpha : 1.0)
        
        self.init(red: red, green: green, blue: blue, alpha: finalAlpha)
    }
    
    /// 用 16 进制字符串初始化颜色
    /// - Parameters:
    ///   - hexString: 16 进制字符串（支持格式：#FFFFFF、FFFFFF、#FFFF00FF、FFFF00FF）
    ///   - alpha: 额外指定的透明度（0~1，优先级高于字符串中的透明度）
    convenience init(hexString: String, alpha: CGFloat? = nil) {
        // 处理字符串（去除 # 和空格）
        let cleanedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 验证长度（6位RGB或8位RGBA）
        guard [6, 8].contains(cleanedString.count) else {
            fatalError("无效的16进制颜色字符串：\(hexString)，长度必须为6或8位（不含#）")
        }
        
        // 转换为 UInt32
        guard let hex = UInt32(cleanedString, radix: 16) else {
            fatalError("无效的16进制颜色字符串：\(hexString)")
        }
        
        self.init(hex: hex, alpha: alpha)
    }
}
