//
//  INDIProtocolStackParser.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation

class INDIProtocolStackParser: NSObject {
    var root: INDIProtocolElement?
    private var stack: [INDIProtocolElement] = []
    
    static func parse(with data: Data) throws -> INDIProtocolElement {
        let parser = INDIProtocolStackParser()
        let node = try parser.parse(with: data)
        return node
    }
    
    func parse(with data: Data) throws -> INDIProtocolElement {
        let xmlParser = XMLParser(data: data)
        xmlParser.shouldProcessNamespaces = false
        xmlParser.delegate = self
        
        guard !xmlParser.parse(), root == nil else { return root! }
        
        guard let error = xmlParser.parserError else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data could not be parsed into XML."))
        }
        
        throw error
    }
}

// MARK: - XMLParserDelegate Method
extension INDIProtocolStackParser: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        root = nil
        stack = []
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let attributes = attributeDict.map({ key, value in
            INDIProtocolElement.Attribute(key: key, value: value)
        })
        
        let element = INDIProtocolElement(tagName: elementName, attributes: attributes)
        self.stack.append(element)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let element = self.stack.popLast() else { return }
        
        let updatedElement = elementWithFilteredElements(element: element)
        
        withCurrentElement({ currentElement in
            currentElement.addChild(child: updatedElement)
        })
        
        if self.stack.isEmpty {
            self.root = updatedElement
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let processedString = trimWhitespaces(string)
        guard processedString.count > 0, string.count != 0 else { return }
        
        withCurrentElement({ currentElement in
            currentElement.addStringValue(string: processedString)
        })
    }
}

// MARK: - Helper Method
private extension INDIProtocolStackParser {
    func trimWhitespaces(_ string: String) -> String {
        string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func elementWithFilteredElements(element: INDIProtocolElement) -> INDIProtocolElement {
        var hasWhitespaceChildren = false
        var hasNonWhitespaceChildren = false
        var filteredElements: [INDIProtocolElement] = []
        
        element.children.forEach({ child in
            if child.isWhitespaceWithNoElements() {
                hasWhitespaceChildren = true
            } else {
                hasNonWhitespaceChildren = true
                filteredElements.append(child)
            }
        })
        
        if hasWhitespaceChildren && hasNonWhitespaceChildren {
            return INDIProtocolElement(tagName: element.tagName, children: filteredElements, attributes: element.attributes)
        }
        
        return element
    }
    
    func withCurrentElement(_ body: (inout INDIProtocolElement) throws -> ()) rethrows {
        guard !stack.isEmpty else { return }
        try body(&stack[stack.count - 1])
    }
}
