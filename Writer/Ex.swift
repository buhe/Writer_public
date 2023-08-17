//
//  File.swift
//  Writer
//
//  Created by 顾艳华 on 2023/8/11.
//

import Foundation
import UIKit
import SwiftUI
import LoadingView

extension View {
    public func circleIndicatorWithSize(when binding: Binding<Bool>, lineWidth: CGFloat = 30, size: CGFloat, pathColor: Color, lineColor: Color, text: String) -> some View {
        show(when: binding) {
            // 显示过程
            VStack {
                CircleActivityView(lineWidth: lineWidth, pathColor: pathColor, lineColor: lineColor)
                    .frame(width: size, height: size)
                Text(text)
            }
        }
    }
}

extension UIScreen {
    static var screenWidth: CGFloat {
        return main.bounds.width
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
