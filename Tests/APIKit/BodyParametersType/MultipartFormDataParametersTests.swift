import Foundation
import XCTest
import APIKit

class MultipartFormDataParametersTests: XCTestCase {
    func testMultipartFormDataSuccess() {
        let value1 = "1".dataUsingEncoding(NSUTF8StringEncoding)!
        let value2 = "2".dataUsingEncoding(NSUTF8StringEncoding)!

        let parameters = MultipartFormDataBodyParameters(parts: [
            MultipartFormDataBodyParameters.Part(data: value1, name: "foo"),
            MultipartFormDataBodyParameters.Part(data: value2, name: "bar"),
        ])

        do {
            guard case .Data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let encodedData = String(data: data, encoding:NSUTF8StringEncoding)!
            let returnCode = "\r\n"

            let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
            let regexp = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: parameters.contentType.characters.count)
            let match = regexp.matchesInString(parameters.contentType, options: [], range: range)
            XCTAssertTrue(match.count > 0)

            let boundary = (parameters.contentType as NSString).substringWithRange(match.first!.rangeAtIndex(1))
            XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
            XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
        } catch {
            XCTFail()
        }
    }
}
