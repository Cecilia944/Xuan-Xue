public enum ChartDisplayMode: String, CaseIterable, Codable, Sendable {
    case card
    case compass
}

public struct PalaceSelection: Equatable, Sendable {
    public let branch: Int
    public let highlightedBranches: Set<Int>

    public init(branch: Int) {
        self.branch = branch
        self.highlightedBranches = Set([
            branch,
            (branch + 4) % 12,
            (branch + 6) % 12,
            (branch + 8) % 12,
        ])
    }
}

public struct PalaceAccessibilityItem: Equatable, Sendable {
    public let branch: Int
    public let label: String
}

public struct ChartPresentationModel: Sendable {
    public let chart: ZiweiChart
    public private(set) var displayMode: ChartDisplayMode
    public private(set) var selection: PalaceSelection?

    public init(chart: ZiweiChart, displayMode: ChartDisplayMode = .card) {
        self.chart = chart
        self.displayMode = displayMode
    }

    public var selectedPalace: ZiweiPalace? {
        guard let selection else { return nil }
        return chart.palaces.first { $0.branch == selection.branch }
    }

    public var accessibilityItems: [PalaceAccessibilityItem] {
        chart.palaces.map { palace in
            let stars = (palace.majorStars + palace.auxiliaryStars).map(\.name)
            let starDescription = stars.isEmpty ? "无主星" : stars.joined(separator: "、")
            return PalaceAccessibilityItem(
                branch: palace.branch,
                label: "\(palace.name)宫，\(Self.branchNames[palace.branch])位，星曜：\(starDescription)"
            )
        }
    }

    public mutating func setDisplayMode(_ mode: ChartDisplayMode) {
        displayMode = mode
    }

    public mutating func selectPalace(branch: Int) {
        guard chart.palaces.contains(where: { $0.branch == branch }) else {
            selection = nil
            return
        }
        selection = PalaceSelection(branch: branch)
    }

    private static let branchNames = [
        "子", "丑", "寅", "卯", "辰", "巳",
        "午", "未", "申", "酉", "戌", "亥",
    ]
}

public enum ChartDeviceClass: Sendable {
    case phone
    case pad
}

public enum ChartOrientation: Sendable {
    case portrait
    case landscape
}

public enum ChartLayoutStyle: Equatable, Sendable {
    case stacked
    case split
}

public enum ChartLayoutResolver {
    public static func resolve(
        device: ChartDeviceClass,
        orientation: ChartOrientation
    ) -> ChartLayoutStyle {
        switch (device, orientation) {
        case (.phone, .portrait): return .stacked
        case (.phone, .landscape), (.pad, _): return .split
        }
    }
}

public struct CompassGridCell: Hashable, Sendable {
    public let column: Int
    public let row: Int

    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }
}

public struct CompassPalaceLayout: Sendable {
    private static let cells = [
        CompassGridCell(column: 0, row: 3),
        CompassGridCell(column: 0, row: 2),
        CompassGridCell(column: 0, row: 1),
        CompassGridCell(column: 0, row: 0),
        CompassGridCell(column: 1, row: 0),
        CompassGridCell(column: 2, row: 0),
        CompassGridCell(column: 3, row: 0),
        CompassGridCell(column: 3, row: 1),
        CompassGridCell(column: 3, row: 2),
        CompassGridCell(column: 3, row: 3),
        CompassGridCell(column: 2, row: 3),
        CompassGridCell(column: 1, row: 3),
    ]

    public init() {}

    public func cell(for branch: Int) -> CompassGridCell? {
        guard Self.cells.indices.contains(branch) else { return nil }
        return Self.cells[branch]
    }

    public func branch(at cell: CompassGridCell) -> Int? {
        Self.cells.firstIndex(of: cell)
    }
}
