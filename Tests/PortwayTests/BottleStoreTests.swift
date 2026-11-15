import XCTest
@testable import Portway

final class BottleStoreTests: XCTestCase {
    var store: BottleStore!

    override func setUp() {
        super.setUp()
        // Use an in‑memory store by pointing to a temporary directory
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        // Override the store's directory for isolation
        store = BottleStore(baseURL: tempDir)
    }

    override func tearDown() {
        // Clean up temporary files
        try? FileManager.default.removeItem(at: store.baseURL)
        store = nil
        super.tearDown()
    }

    func testAddAndDeleteBottle() throws {
        let bottle = Bottle(id: UUID(), name: "TestBottle", path: "/tmp/test")
        // Add bottle
        try store.add(bottle)
        var all = try store.allBottles()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.name, "TestBottle")
        // Delete bottle
        try store.delete(bottle.id)
        all = try store.allBottles()
        XCTAssertTrue(all.isEmpty)
    }
}
