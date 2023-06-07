import Combine

final class StatisticViewModel {
    // MARK: - Public
    var statisticData: [StatisticTableData] = []
    @Published var isAnyTrackers = false

    func statisticDataPublisher() -> AnyPublisher<[StatisticTableData], Never> {
        Just(statisticData).eraseToAnyPublisher()
    }

    func viewWillAppear() {
        let completedTrackersCount = trackerRecordStore.getNumberOfCompletedTrackers()

        isAnyTrackers = trackerStore.isAnyTrackers

        if statisticData.isEmpty {
            statisticData = [
                .bestPeriod(StatisticCellViewModel()),
                .idealDays(StatisticCellViewModel()),
                .completedTrackers(StatisticCellViewModel(value: "\(completedTrackersCount)")),
                .averageValue(StatisticCellViewModel())
            ]
        } else {
            statisticData.forEach { data in
                switch data {
                case .completedTrackers(var statisticCellViewModel):
                    statisticCellViewModel.value = "\(completedTrackersCount)"
                default: break
                }
            }
        }
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

    init(value: String = "Comming soon") {
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
            return "Лучший период"
        case .idealDays:
            return "Идеальные дни"
        case .completedTrackers:
            return "Трекеров завершено"
        case .averageValue:
            return "Среднее значение"
        }
    }
}
