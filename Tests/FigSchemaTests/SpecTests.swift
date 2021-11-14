import XCTest
@testable import FigSchema

final class SpecTests: XCTestCase {

    func testIcons() throws {
        func check(_ icon: FigSpec.Icon, _ expected: String, file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual(icon.rawValue, expected, file: file, line: line)
        }
        check(.character("a"), "a")
        check(.path(URL(fileURLWithPath: "/a/b")), "fig:/a/b")
        check(.path(URL(fileURLWithPath: "/a/b"), .init(colorHex: "1da7ea")), "fig:/a/b?color=1da7ea")
        check(.path(URL(fileURLWithPath: "/a/b"), .init(colorHex: "1da7ea", badge: "1")), "fig:/a/b?color=1da7ea&badge=1")
        check(.preset("png"), "fig://icon?type=png")
        check(.preset(.apple, .init(colorHex: "ff0000")), "fig://icon?type=apple&color=ff0000")
        check(.template(.init(colorHex: "0000ff", badge: "12")), "fig://template?color=0000ff&badge=12")
        check(.template(.init(colorHex: "0000ff", badge: "1 2")), "fig://template?color=0000ff&badge=1%202")
    }

    // TODO: Add more tests

}
