import ZiweiCore

enum ChartPresentationTests {
    static func run() {
        defaultsToCardAndSwitchesModes()
        selectsPalaceAndHighlightsSanFangSiZheng()
        exposesStableVoiceOverOrder()
        resolvesResponsiveLayouts()
        mapsCompassCellsWithoutChartRules()
        TestSupport.record(17, suite: "ChartPresentationTests")
    }

    private static func defaultsToCardAndSwitchesModes() {
        var model = ChartPresentationModel(chart: chart())
        TestSupport.equal(model.displayMode, .card, "chart defaults to card mode")
        model.setDisplayMode(.compass)
        TestSupport.equal(model.displayMode, .compass, "chart switches to compass mode")
    }

    private static func selectsPalaceAndHighlightsSanFangSiZheng() {
        var model = ChartPresentationModel(chart: chart())
        model.selectPalace(branch: 0)

        TestSupport.equal(model.selection?.branch, 0, "palace selection records branch")
        TestSupport.equal(model.selection?.highlightedBranches, Set([0, 4, 6, 8]), "selection highlights trines and opposite")
        TestSupport.equal(model.selectedPalace?.branch, 0, "selected palace resolves from chart")
        model.selectPalace(branch: 12)
        TestSupport.equal(model.selection, nil, "invalid branch clears selection")
    }

    private static func exposesStableVoiceOverOrder() {
        let chart = chart()
        let model = ChartPresentationModel(chart: chart)
        let items = model.accessibilityItems

        TestSupport.equal(items.count, 12, "voice over exposes all palaces")
        TestSupport.equal(items.map(\.branch), chart.palaces.map(\.branch), "voice over follows visual palace order")
        TestSupport.equal(items.first?.label.contains(chart.palaces[0].name), true, "voice over names the palace")
        TestSupport.equal(items.first?.label.contains("宫"), true, "voice over uses meaningful palace wording")
    }

    private static func resolvesResponsiveLayouts() {
        TestSupport.equal(
            ChartLayoutResolver.resolve(device: .phone, orientation: .portrait),
            .stacked,
            "portrait phone uses stacked layout"
        )
        TestSupport.equal(
            ChartLayoutResolver.resolve(device: .phone, orientation: .landscape),
            .split,
            "landscape phone uses split layout"
        )
        TestSupport.equal(
            ChartLayoutResolver.resolve(device: .pad, orientation: .portrait),
            .split,
            "ipad uses split layout"
        )
    }

    private static func mapsCompassCellsWithoutChartRules() {
        let layout = CompassPalaceLayout()
        TestSupport.equal(layout.cell(for: 0), CompassGridCell(column: 0, row: 3), "branch zero maps to lower-left cell")
        TestSupport.equal(layout.cell(for: 3), CompassGridCell(column: 0, row: 0), "branch three maps to upper-left cell")
        TestSupport.equal(layout.cell(for: 6), CompassGridCell(column: 3, row: 0), "branch six maps to upper-right cell")
        TestSupport.equal(layout.cell(for: 9), CompassGridCell(column: 3, row: 3), "branch nine maps to lower-right cell")
        TestSupport.equal(layout.branch(at: CompassGridCell(column: 2, row: 2)), nil, "center cells are not palaces")
    }

    private static func chart() -> ZiweiChart {
        let profile = BirthProfile(
            name: "展示样例",
            gender: .female,
            date: .gregorian(year: 1992, month: 6, day: 15),
            time: .exact(hour: 12, minute: 0),
            location: BirthLocation(city: "北京", longitude: 116.4, utcOffsetMinutes: 480)
        )
        return try! ZiweiChartEngine.generate(
            ZiweiChartRequest(
                profile: profile,
                confirmedTime: ConfirmedBirthTime(
                    year: 1992, month: 6, day: 15, hour: 12, minute: 0, branch: 6
                )
            )
        )
    }
}
