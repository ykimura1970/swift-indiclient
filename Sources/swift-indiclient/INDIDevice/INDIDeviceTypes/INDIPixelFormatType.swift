//
//  INDIPixelFormatType.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDI Pixel Format type.
public enum INDIPixelFormatType: Int, Sendable {
    case Mono = 0
    case BayerRGGB = 8
    case BayerGRBG = 9
    case BayerGBRG = 10
    case BayerBGGR = 11
    case ByaerCYYM = 16
    case BayerYCMY = 17
    case BayerYMCY = 18
    case BayerMYYC = 19
    case RGB = 100
    case BGR = 101
    case JPG = 200
}
