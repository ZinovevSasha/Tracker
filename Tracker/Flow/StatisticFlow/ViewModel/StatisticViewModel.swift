import Combine

final class StatisticViewModel {
    // MARK: - Public
    var statisticData: [StatisticTableData] = []
    @Published var isAnyTrackers = false

    func statisticDataPublisher() -> AnyPublisher<[StatisticTableData], Never> {
        Just(statisticData).eraseToAnyPublisher()
    }

    func viewWillAppear() {
        // Check if there are any trackers
        let isAnyTrackers = trackerStore.isAnyTrackers

        // If there are any trackers
        if isAnyTrackers {
            // Get the number of completed trackers
            let completedTrackersCount = trackerRecordStore.getNumberOfCompletedTrackers()

            // If statisticData is empty, set initial values for each cell
            if statisticData.isEmpty {
                setInitialStatisticData(completedTrackersCount: completedTrackersCount)
            }
            // Otherwise, update the completed trackers cell with the current count
            else {
                updateCompletedTrackersCell(value: completedTrackersCount)
            }
        }
        // If there are no trackers, reset the statistic data
        else {
            resetStatisticData()
        }

        // Update the isAnyTrackers property
        self.isAnyTrackers = isAnyTrackers
    }

    private func setInitialStatisticData(completedTrackersCount: Int) {
        // Set up initial statistic data for each cell
        statisticData = [
            .bestPeriod(StatisticCellViewModel()),
            .idealDays(StatisticCellViewModel()),
            .completedTrackers(StatisticCellViewModel(value: "\(completedTrackersCount)")),
            .averageValue(StatisticCellViewModel())
        ]
    }

    private func updateCompletedTrackersCell(value: Int) {
        // Find the completed trackers cell and update its value
        for (index, data) in statisticData.enumerated() {
            if case .completedTrackers(let viewModel) = data {
                statisticData[index] = .completedTrackers(StatisticCellViewModel(value: "\(value)"))
                break
            }
        }
    }

    private func resetStatisticData() {
        // Reset the statistic data when there are no trackers
        statisticData = []
    }


    // MARK: - Private
    private let trackerRecordStore: TrackerRecordStoreProtocol
    private let trackerStore: TrackerStoreDataProviderProtocol

    // MARK: - Init
    init(
        trackerRecordStore: TrackerRecordStoreProtocol,
        trackerStore: TrackerStoreDataProviderProtocol
    ) {
        self.trackerRecordStore = trackerRecordStore
        self.trackerStore = trackerStore
    }
}

final class StatisticCellViewModel {
    @Published var value: String

    init(value: String = "-") {
        self.value = value
    }
}

enum StatisticTableData {
    case bestPeriod(StatisticCellViewModel)
    case idealDays(StatisticCellViewModel)
    case completedTrackers(StatisticCellViewModel)
    case averageValue(StatisticCellViewModel)

    var title: String {
        switch self {
        case .bestPeriod:
            return Strings.Localizable.Statistic.bestPeriod
        case .idealDays:
            return Strings.Localizable.Statistic.idealDays
        case .completedTrackers:
            return Strings.Localizable.Statistic.completed
        case .averageValue:
            return Strings.Localizable.Statistic.avarageValue
        }
    }
}
