import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testViewController() throws {
        let mockDataProvider = MockDataProvider()
        let sut = TrackersViewController(dataProvider: mockDataProvider)
        mockDataProvider.createMockData()

        assertSnapshot(matching: sut, as: .image(traits: .init(userInterfaceStyle: .light)))

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = sut
        window.makeKeyAndVisible()

        // Wait for the view to update to dark mode
        RunLoop.current.run(until: Date())

        assertSnapshot(matching: sut, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

final class MockDataProvider: DataProviderProtocol {
    var delegate: DataProviderDelegate?

    var mockData: TrackerCategory = TrackerCategory(header: "", trackers: [], isLastSelected: false)

    func createMockData() {
        self.mockData = TrackerCategory(
            header: "Tests",
            trackers:
                [
                    Tracker(name: "Test1", emoji: "😀", color: "#FF674D", schedule: [], kind: .habit),
                    Tracker(name: "Test2", emoji: "🥹", color: "#FF684D", schedule: [], kind: .habit),
                    Tracker(name: "Test3", emoji: "😊", color: "#FF694D", schedule: [], kind: .habit),
                    Tracker(name: "Test4", emoji: "😜", color: "#FF704D", schedule: [], kind: .habit),
                ]
            ,
            isLastSelected: false)
    }

    var isEmpty = false

    var numberOfSections = 1

    func numberOfRowsInSection(_ section: Int) -> Int {
        mockData.trackers.count
    }

    func header(for section: Int) -> String {
        mockData.header
    }

    func daysTracked(for indexPath: IndexPath) -> Int {
        .zero
    }

    func getCategories() -> [TrackerCategory] {
        []
    }

    func addTrackerCategory(_ category: TrackerCategory) throws {}

    func getTracker(at indexPath: IndexPath) -> Tracker? {
        mockData.trackers[indexPath.row]
    }

    func deleteTracker(at indexPath: IndexPath) throws {}

    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: String) -> Bool {
        false
    }

    func saveAsCompletedTracker(with indexPath: IndexPath, for day: String) throws {}

    func fetchTrackersBy(name: String, weekDay: String) throws {}

    func fetchTrackersBy(weekDay: String) throws {}

    func attachTrackerAt(indexPath: IndexPath) {}

    func unattachTrackerAt(indexPath: IndexPath) {}

    func getCompletedTrackersFor(date: String) throws {}

    func getUnCompletedTrackersFor(date: String, weekDay: String) throws {}

    func getTrackersForToday() throws {}

    func getAllTrackersFor(day: String) throws {}

    func getUnCompletedTrackersWithNameFor(date: String, weekDay: String, name: String) throws {}

    func getCompletedTrackersWithNameFor(date: String, name: String) throws {}
}
