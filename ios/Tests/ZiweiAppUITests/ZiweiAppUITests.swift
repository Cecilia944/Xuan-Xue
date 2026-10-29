import XCTest

final class ZiweiAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreatesFirstChartAndShowsFiveRootTabs() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-reset"]
        app.launch()

        XCTAssertTrue(app.navigationBars["开始排盘"].waitForExistence(timeout: 5))
        let nickname = app.textFields["昵称"]
        nickname.tap()
        nickname.typeText("自动化样例")
        app.buttons["继续"].tap()

        XCTAssertTrue(app.navigationBars["出生资料"].waitForExistence(timeout: 3))
        app.buttons["继续"].tap()

        XCTAssertTrue(app.navigationBars["时间校正"].waitForExistence(timeout: 3))
        app.buttons["继续"].tap()

        XCTAssertTrue(app.navigationBars["确认并生成"].waitForExistence(timeout: 3))
        app.buttons["生成命盘"].tap()

        XCTAssertTrue(app.tabBars.buttons["今日"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.tabBars.buttons["命盘"].exists)
        XCTAssertTrue(app.tabBars.buttons["解读"].exists)
        XCTAssertTrue(app.tabBars.buttons["学堂"].exists)
        XCTAssertTrue(app.tabBars.buttons["我的"].exists)

        app.tabBars.buttons["命盘"].tap()
        XCTAssertTrue(app.segmentedControls.buttons["卡片"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.segmentedControls.buttons["罗盘"].exists)
    }
}
