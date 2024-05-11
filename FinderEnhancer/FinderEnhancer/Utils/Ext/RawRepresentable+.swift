//
//  CGSize+.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/6.
//

import Foundation

public extension RawRepresentable where RawValue == String, Self: Codable {
    var rawValue: String {
        do {
            let encoder = JSONEncoder()
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "inf",
                                                                          negativeInfinity: "-inf",
                                                                          nan: "NaN")
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Encode CGSize error: \(error)")
            return ""
        }
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "inf",
                                                                            negativeInfinity: "-inf",
                                                                            nan: "NaN")
            let instance = try decoder.decode(Self.self, from: data)
            self = instance
        } catch {
            print("Decode CGSize error: \(error)")
            return nil
        }
    }
}

extension CGSize: RawRepresentable {
    public typealias RawValue = String
}

extension CGPoint: RawRepresentable {
    public typealias RawValue = String
}

extension Array: RawRepresentable where Element: Codable {
    public typealias RawValue = String
}
