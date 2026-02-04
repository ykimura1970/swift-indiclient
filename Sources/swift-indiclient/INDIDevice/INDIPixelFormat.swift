//
//  INDIPixelFormat.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2026/02/03.
//

import Foundation

public enum INDIPixelFormat: Int, Sendable {
    case Mono       = 0
    case BayerRGGB  = 8
    case BayerGRBG  = 9
    case BayerGBRG  = 10
    case BayerBGGR  = 11
    case BayerCYYM  = 16
    case BayerYCMY  = 17
    case BayerYMCY  = 18
    case BayerMYYC  = 19
    case RGB        = 100
    case BGR        = 101
    case JPG        = 200
}
