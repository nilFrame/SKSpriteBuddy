//
//  XMLParser.swift
//  SKSpriteBuddy
//
//  Created by Rafael Moura on 01/04/2023.
//  Copyright © 2023 Nilframe. All rights reserved.
//

import Foundation

/**
    This is base class for holding XML structure.

    You can access its structure by using subscript like this:
    `element["foo"]["bar"]` would return `<bar></bar>` element from `<element><foo><bar></bar></foo></element>` XML as an `AEXMLElement` object.
*/
open class AEXMLElement: NSObject {

    // MARK: Properties

    /// Every `AEXMLElement` should have its parent element instead of `AEXMLDocument` which parent is `nil`.
    fileprivate(set) weak var parent: AEXMLElement?

    /// Child XML elements.
    fileprivate(set) var children: [AEXMLElement] = [AEXMLElement]()

    /// XML Element name (defaults to empty string).
    var name: String

    /// XML Element value.
    var value: String?

    /// XML Element attributes (defaults to empty dictionary).
    var attributes: [String : String]

    /// String representation of `value` property (if `value` is `nil` this is empty String).
    var stringValue: String { return value ?? String() }

    /// String representation of `value` property with special characters escaped (if `value` is `nil` this is empty String).
    var escapedStringValue: String {
        // we need to make sure "&" is escaped first. Not doing this may break escaping the other characters
        var escapedString = stringValue.replacingOccurrences(of: "&", with: "&amp;", options: .literal)

        // replace the other four special characters
        let escapeChars = ["<" : "&lt;", ">" : "&gt;", "'" : "&apos;", "\"" : "&quot;"]
        for (char, echar) in escapeChars {
            escapedString = escapedString.replacingOccurrences(of: char, with: echar, options: .literal)
        }

        return escapedString
    }

    /// Boolean representation of `value` property (if `value` is "true" or 1 this is `True`, otherwise `False`).
    var boolValue: Bool { return stringValue.lowercased() == "true" || Int(stringValue) == 1 ? true : false }

    /// Integer representation of `value` property (this is **0** if `value` can't be represented as Integer).
    var intValue: Int { return Int(stringValue) ?? 0 }

    /// Double representation of `value` property (this is **0.00** if `value` can't be represented as Double).
    var doubleValue: Double { return (stringValue as NSString).doubleValue }

    fileprivate struct Defaults {
        static let name = String()
        static let attributes = [String : String]()
    }

    // MARK: Lifecycle

    /**
        Designated initializer - all parameters are optional.

        :param: name XML element name.
        :param: value XML element value
        :param: attributes XML element attributes

        :returns: An initialized `AEXMLElement` object.
    */
    init(_ name: String? = nil, value: String? = nil, attributes: [String : String]? = nil) {
        self.name = name ?? Defaults.name
        self.value = value
        self.attributes = attributes ?? Defaults.attributes
    }

    // MARK: XML Read

    /// This element name is used when unable to find element.
    static let errorElementName = "AEXMLError"

    // The first element with given name **(AEXMLError element if not exists)**.
    subscript(key: String) -> AEXMLElement {
        if name == AEXMLElement.errorElementName {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            return filtered.count > 0 ? filtered.first! : AEXMLElement(AEXMLElement.errorElementName, value: "element <\(key)> not found")
        }
    }

    /// Returns all of the elements with equal name as `self` **(nil if not exists)**.
    var all: [AEXMLElement]? { return parent?.children.filter { $0.name == self.name } }

    /// Returns the first element with equal name as `self` **(nil if not exists)**.
    var first: AEXMLElement? { return all?.first }

    /// Returns the last element with equal name as `self` **(nil if not exists)**.
    var last: AEXMLElement? { return all?.last }

    /// Returns number of all elements with equal name as `self`.
    var count: Int { return all?.count ?? 0 }

    fileprivate func allWithCondition(_ fulfillCondition: (_ element: AEXMLElement) -> Bool) -> [AEXMLElement]? {
        var found = [AEXMLElement]()
        if let elements = all {
            for element in elements {
                if fulfillCondition(element) {
                    found.append(element)
                }
            }
            return found.count > 0 ? found : nil
        } else {
            return nil
        }
    }

    /**
        Returns all elements with given value.

        :param: value XML element value.

        :returns: Optional Array of found XML elements.
    */
    func allWithValue(_ value: String) -> [AEXMLElement]? {
        let found = allWithCondition { (element) -> Bool in
            return element.value == value
        }
        return found
    }

    /**
        Returns all elements with given attributes.

        :param: attributes Dictionary of Keys and Values of attributes.

        :returns: Optional Array of found XML elements.
    */
    func allWithAttributes(_ attributes: [String : String]) -> [AEXMLElement]? {
        let found = allWithCondition { (element) -> Bool in
            var countAttributes = 0
            for (key, value) in attributes {
                if element.attributes[key] == value {
                    countAttributes += 1
                }
            }
            return countAttributes == attributes.count
        }
        return found
    }

    // MARK: XML Write

    /**
        Adds child XML element to `self`.

        :param: child Child XML element to add.

        :returns: Child XML element with `self` as `parent`.
    */
    func addChild(_ child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }

    /**
        Adds child XML element to `self`.

        :param: name Child XML element name.
        :param: value Child XML element value.
        :param: attributes Child XML element attributes.

        :returns: Child XML element with `self` as `parent`.
    */
    func addChild(name: String, value: String? = nil, attributes: [String : String]? = nil) -> AEXMLElement {
        let child = AEXMLElement(name, value: value, attributes: attributes)
        return addChild(child)
    }

    /// Removes `self` from `parent` XML element.
    open func removeFromParent() {
        parent?.removeChild(self)
    }

    fileprivate func removeChild(_ child: AEXMLElement) {
        if let childIndex = children.firstIndex(of: child) {
            children.remove(at: childIndex)
        }
    }

    fileprivate var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent {
            count += 1
            element = parent
        }
        return count
    }

    fileprivate func indentation(_ count: Int) -> String {
        var indent = String()
        var countAux = count
        while countAux > 0 {
            indent += "\t"
            countAux -= 1
        }
        return indent
    }

    /// Complete hierarchy of `self` and `children` in **XML** escaped and formatted String
    var xmlString: String {
        var xml = String()

        // open element
        xml += indentation(parentsCount - 1)
        xml += "<\(name)"

        if attributes.count > 0 {
            // insert attributes
            for (key, value) in attributes {
                xml += " \(key)=\"\(value)\""
            }
        }

        if value == nil && children.count == 0 {
            // close element
            xml += " />"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indentation(parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(escapedStringValue)</\(name)>"
            }
        }

        return xml
    }

}

// MARK: -

/**
    This class is inherited from `AEXMLElement` and has a few addons to represent **XML Document**.

    XML Parsing is also done with this object.
*/
class AEXMLDocument: AEXMLElement {

    // MARK: Properties

    /// This is only used for XML Document header (default value is 1.0).
    let version: Double

    /// This is only used for XML Document header (default value is "utf-8").
    let encoding: String

    /// This is only used for XML Document header (default value is "no").
    let standalone: String

    /// Root (the first child element) element of XML Document **(AEXMLError element if not exists)**.
    var root: AEXMLElement { return children.count == 1 ? children.first! : AEXMLElement(AEXMLElement.errorElementName, value: "XML Document must have root element.") }

    struct Defaults {
        static let version = 1.0
        static let encoding = "utf-8"
        static let standalone = "no"
        static let documentName = "AEXMLDocument"
    }

    // MARK: Lifecycle

    /**
        Designated initializer - Creates and returns XML Document object.

        :param: version Version value for XML Document header (defaults to 1.0).
        :param: encoding Encoding value for XML Document header (defaults to "utf-8").
        :param: standalone Standalone value for XML Document header (defaults to "no").
        :param: root Root XML element for XML Document (defaults to `nil`).

        :returns: An initialized XML Document object.
    */
    init(version: Double = Defaults.version,
         encoding: String = Defaults.encoding,
         standalone: String = Defaults.standalone,
         root: AEXMLElement? = nil) {

        // set document properties
        self.version = version
        self.encoding = encoding
        self.standalone = standalone

        // init super with default name
        super.init(Defaults.documentName)

        // document has no parent element
        parent = nil

        // add root element to document (if any)
        if let rootElement = root {
            _ = addChild(rootElement)
        }
    }

    /**
        Convenience initializer - used for parsing XML data (by calling `loadXMLData:` internally).

        :param: version Version value for XML Document header (defaults to 1.0).
        :param: encoding Encoding value for XML Document header (defaults to "utf-8").
        :param: standalone Standalone value for XML Document header (defaults to "no").
        :param: xmlData XML data to parse.
        :param: error If there is an error reading in the data, upon return contains an `NSError` object that describes the problem.

        :returns: An initialized XML Document object containing the parsed data. Returns `nil` if the data could not be parsed.
    */
    convenience init(version: Double = Defaults.version, encoding: String = Defaults.encoding, standalone: String = Defaults.standalone, xmlData: Data) throws {
        self.init(version: version, encoding: encoding, standalone: standalone)
        try loadXMLData(xmlData)
    }

    // MARK: Read XML

    /**
        Creates instance of `AEXMLParser` (private class which is simple wrapper around `NSXMLParser`) and starts parsing the given XML data.

        :param: data XML which should be parsed.

        :returns: `NSError` if parsing is not successfull, otherwise `nil`.
    */
    func loadXMLData(_ data: Data) throws {
        children.removeAll(keepingCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        try xmlParser.parse()
    }

    // MARK: Override

    /// Override of `xmlString` property of `AEXMLElement` - it just inserts XML Document header at the beginning.
    override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }

}

// MARK: -

private class AEXMLParser: NSObject, XMLParserDelegate {

    // MARK: Properties

    let xmlDocument: AEXMLDocument
    let xmlData: Data

    var currentParent: AEXMLElement?
    var currentElement: AEXMLElement?
    var currentValue = String()
    var parseError: NSError?

    // MARK: Lifecycle

    init(xmlDocument: AEXMLDocument, xmlData: Data) {
        self.xmlDocument = xmlDocument
        self.xmlData = xmlData
        currentParent = xmlDocument
        super.init()
    }

    // MARK: XML Parse

    func parse() throws {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        let success = parser.parse()
        if !success {
            throw parseError ?? NSError(domain: "net.tadija.AEXML", code: 1, userInfo: nil)
        }
    }

    // MARK: NSXMLParserDelegate

    @objc
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentValue = String()
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
    }

    @objc
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
        let newValue = currentValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        currentElement?.value = newValue == String() ? nil : newValue
    }

    @objc
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentParent = currentParent?.parent
        currentElement = nil
    }

    @objc
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError as NSError?
    }
}

