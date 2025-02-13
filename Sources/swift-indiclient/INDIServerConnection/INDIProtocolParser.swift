//
//  INDIProtocolParser.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/12/22.
//

import Foundation

actor INDIProtocolParser {
    // MARK: - Class Property
    static let lf: UInt8 = 0x0a
    static let lt: UInt8 = 0x3c
    static let gt: UInt8 = 0x3e
    static let space: UInt8 = 0x20
    static let slash: UInt8 = 0x2f
    
    // MARK: - Fundamental Property
    private var _data: Data
    private var _isBlob: Bool
    private var _root: INDIProtocolElement?
    private var _child: INDIProtocolElement?
    private var _tagNames: [String]
    
    // MARK: - Initializer
    public init() {
        self._data = Data()
        self._isBlob = false
        self._tagNames = []
    }
    
    // MARK: - Fundamental Method
    public func parse(data: Data) -> [INDIProtocolElement] {
        var elements: [INDIProtocolElement] = []
        
        _data.append(data)
        repeat {
            if !_isBlob {
                trimmingLineFeedAndWhiteSpace()
                if _data.isEmpty { break }
                if let lfIndex = _data.firstIndex(of: Self.lf) {
                    let subdata = _data.subdata(in: _data.startIndex..<lfIndex)
                    var tagString = String(data: subdata, encoding: .ascii)!
                    
                    if !_tagNames.isEmpty && tagString == "</\(_tagNames.last!)>" {
                        
                        _ = _tagNames.popLast()
                        if _tagNames.isEmpty {
                            elements.append(_root!)
                            _root = nil
                        } else {
                            _root!.setChildElement(element: _child!)
                            _child = nil
                        }
                    } else if tagString.contains("<") {
                        tagString = String(tagString.dropFirst())
                        let tagName = String(tagString[tagString.startIndex..<tagString.firstIndex(of: " ")!])
                        var element = INDIProtocolElement(tagName: tagName, stringValue: "")
                        
                        let attributes = analyzeAttribute(string: String(tagString[tagString.firstIndex(of: " ")!..<tagString.endIndex].dropFirst()).replacingOccurrences(of: "/>", with: "").replacingOccurrences(of: ">", with: ""))
                        for attribute in attributes {
                            element.setAttribute(key: attribute.key, value: attribute.value)
                        }
                        
                        if tagString.hasSuffix("/>") {
                            if _root == nil {
                                elements.append(element)
                            } else {
                                _root?.setChildElement(element: element)
                            }
                        } else if tagString.hasSuffix(">") {
                            _tagNames.append(tagName)
                            
                            if _root == nil {
                                _root = element
                            } else {
                                _child = element
                                
                                if _root!.tagName == "setBLOBVector" && tagName == "oneBLOB" {
                                    _isBlob = true
                                }
                            }
                        }
                    } else {
                        _child?.stringValue = tagString
                    }
                    
                    if (lfIndex + 1) >= _data.endIndex {
                        _data.removeAll()
                    } else {
                        _data = _data.subdata(in: (lfIndex + 1)..<_data.endIndex)
                    }
                } else {
                    break
                }
            } else {
                if let lfIndex = _data.firstIndex(of: Self.lf) {
                    _child?.blobData.append(_data.subdata(in: _data.startIndex..<lfIndex))
                    _isBlob = false
                    
                    if (lfIndex + 1) >= _data.endIndex {
                        _data.removeAll()
                    } else {
                        _data = _data.subdata(in: lfIndex..<_data.endIndex)
                    }
                } else {
                    _child?.blobData.append(_data)
                    _data.removeAll()
                }
            }
        } while !_data.isEmpty
        
        return elements
    }
    
    private func analyzeAttribute(string: String) -> [String : String] {
        var attributes: [String : String] = [:]
        let stringArray = string.split(separator: "\" ")
        
        for element in stringArray {
            if element.isEmpty { continue }
            let elementArray = element.split(separator: "=")
            attributes[String(elementArray[0])] = String(elementArray[1]).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
        }
        
        return attributes
    }
    
    private func trimmingLineFeedAndWhiteSpace() {
        while !_data.isEmpty && (_data.first! == Self.lf || _data.first! == Self.space) {
            _data = _data.dropFirst()
        }
    }
}
