enum TaskPriority{
    case normal
    case important
}

enum TaskStatus: Int{
    case planned
    case completed
}

protocol TaskStorageProtocol{
    func loadTask() -> [TaskProtocol]
    func saveTask(_ tasks: [TaskProtocol])
}

protocol TaskProtocol{
    var title: String {get set}
    var type: TaskPriority {get set}
    var status: TaskStatus {get set}
}

struct Task: TaskProtocol{
    var title: String
    
    var type: TaskPriority
    
    var status: TaskStatus
    
}

class TaskStorage: TaskStorageProtocol {
    func loadTask() -> [TaskProtocol] {
        let testTasks: [TaskProtocol] = [
            Task(title: "Купить хлеб", type: .normal, status: .planned),
            Task(title: "Помыть кота", type: .important, status: .planned),
            Task(title: "Сделать упражнения", type: .important, status: .completed),
            Task(title: "Сделать упражнения с использованием техники Кегеля", type: .normal, status: .planned),
            Task(title: "Сделать упражнения с использованием техники Шварца", type: .normal, status: .planned),
            Task(title: "Сделать упражнения с использованием техники Гоголя", type: .normal, status: .planned),
            Task(title: "Сделать упражнения с использованием техники Кегельбана", type: .normal, status: .completed)
        ]
        return testTasks
    }
    
    func saveTask(_ tasks: [TaskProtocol]) {
        
    }

}
