//
//  CGSize+.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/6.
//

import Foundation

extension CGSize: RawRepresentable {
    public typealias RawValue = String

    public var rawValue: String {
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

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "inf",
                                                                            negativeInfinity: "-inf",
                                                                            nan: "NaN")
            let size = try decoder.decode(CGSize.self, from: data)
            self = size
        } catch {
            print("Decode CGSize error: \(error)")
            return nil
        }
    }
}
