//
//  SSDPMessageParser.swift
//  RxSSDP
//
//  Created by Stefan Renne on 18/06/2018.
//  Copyright © 2018 Uberweb. All rights reserved.
//

import Foundation

class SSDPMessageParser {
    fileprivate let scanner: Scanner
    
    init(message: String) {
        scanner = Scanner(string: message)
        scanner.charactersToBeSkipped = CharacterSet.newlines
    }
    
    func parse() -> SSDPResponse? {
        guard let firstLine = scanLine(),
            let firstWord = firstLine.components(separatedBy: " ").first,
            firstWord == "HTTP/1.1" else {
            return nil
        }
        
        var keyBuffer: NSString? = nil
        var valueBuffer: String? = nil
        
        
        var message = [String: String]()
        while self.scanner.scanUpTo(":", into: &keyBuffer) {
            self.advancePastColon()
            if self.scanner.isAtEnd{
                break;
            }
            
            let unicodeScalars = self.scanner.string.unicodeScalars
            let index = unicodeScalars.index(unicodeScalars.startIndex, offsetBy: self.scanner.scanLocation)
            
            if CharacterSet.newlines.contains(unicodeScalars[index]) {
                valueBuffer = ""
            } else {
                valueBuffer = self.scanLine()
            }
            
            if let keyBuffer = keyBuffer as String?, let valueBuffer = valueBuffer {
                message[keyBuffer] = valueBuffer
            }
        }
        
        return SSDPResponse(data: message)
    }
    
    fileprivate func scanLine() -> String? {
        var buffer: NSString? = nil
        scanner.scanUpToCharacters(from: CharacterSet.newlines, into: &buffer)
        
        return (buffer as String?)
    }
    
    fileprivate func advancePastColon() {
        var string: NSString? = nil
        
        let characterSet = CharacterSet(charactersIn: ": ")
        scanner.scanCharacters(from: characterSet, into: &string)
    }
}
