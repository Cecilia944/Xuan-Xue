@main
enum TestMain {
    static func main() {
        AppLaunchTests.run()
        BirthDateValidatorTests.run()
        print("ZiweiCoreTests: \(TestSupport.total) passed")
    }
}

enum TestSupport {
    static var total = 0

    static func equal<T: Equatable>(_ actual: T, _ expected: T, _ name: String) {
        guard actual == expected else {
            fatalError("FAIL \(name): expected \(expected), got \(actual)")
        }
    }

    static func record(_ count: Int, suite: String) {
        total += count
        print("\(suite): \(count) passed")
    }
}
