import Foundation

final class TasksBag<Success, Failure> where Success : Sendable, Failure : Error {
    private lazy var tasks: [Task<Success, Failure>] = []
    
    func store(task: Task<Success, Failure>) {
        tasks.append(task)
    }
    
    func cancelAll() {
        tasks.forEach { $0.cancel() }
    }
    
    deinit {
        cancelAll()
    }
}
