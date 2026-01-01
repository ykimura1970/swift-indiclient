//
//  File.swift
//  swift-indiclient
//
//  Created by 木村嘉男 on 2026/01/01.
//

import Foundation

public enum INDIEquatorialAxis: Int, Sendable {
    case Rightascension = 0
    case Declination = 1
}

public enum INDIHorizontalAxis: Int, Sendable {
    case Azimuth = 0
    case Altitude = 1
}

public enum INDIDirectionNS: Int, Sendable {
    case North = 0
    case South = 1
}


public enum INDIDirectionWE: Int, Sendable {
    case West = 0
    case East = 1
}


public enum INDIPixelFormat: Int, Sendable {
    case Mono = 0
    case BayerRGGB = 8
    case BayerGRBG = 9
    case BayerGBRG = 10
    case BayerBGGR = 11
    case BayerCYYM = 16
    case BayerYCMY = 17
    case BayerYMCY = 18
    case BayerMYYC = 19
    case RGB = 100
    case BGR = 101
    case JPG = 200
}
