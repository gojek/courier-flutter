enum SchedulePeriodicRecursiveCommand {
    case tick
    case dispatchStart
}

final class SchedulePeriodicRecursive<State> {
    typealias RecursiveAction = (State) -> State
    typealias RecursiveScheduler = AnyRecursiveScheduler<SchedulePeriodicRecursiveCommand>

    private let scheduler: SchedulerType
    private let startAfter: RxTimeInterval
    private let period: RxTimeInterval
    private let action: RecursiveAction

    private var state: State
    private let pendingTickCount = AtomicInt(0)

    init(scheduler: SchedulerType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping RecursiveAction, state: State) {
        self.scheduler = scheduler
        self.startAfter = startAfter
        self.period = period
        self.action = action
        self.state = state
    }

    func start() -> Disposable {
        scheduler.scheduleRecursive(SchedulePeriodicRecursiveCommand.tick, dueTime: startAfter, action: tick)
    }

    func tick(_ command: SchedulePeriodicRecursiveCommand, scheduler: RecursiveScheduler) {

        switch command {
        case .tick:
            scheduler.schedule(.tick, dueTime: period)

            if increment(pendingTickCount) == 0 {
                tick(.dispatchStart, scheduler: scheduler)
            }

        case .dispatchStart:
            state = action(state)

            if decrement(pendingTickCount) > 1 {

                scheduler.schedule(SchedulePeriodicRecursiveCommand.dispatchStart)
            }
        }
    }
}
