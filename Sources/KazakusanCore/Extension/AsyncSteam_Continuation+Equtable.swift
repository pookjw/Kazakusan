import Foundation

extension AsyncStream.Continuation: Equatable {
    public static func ==(lhs: AsyncStream.Continuation, rhs: AsyncStream.Continuation) -> Bool {
        let lhsPointer: UnsafePointer<AsyncStream<Element>.Continuation> = withUnsafePointer(to: lhs, { UnsafePointer($0) })
        let rhsPointer: UnsafePointer<AsyncStream<Element>.Continuation> = withUnsafePointer(to: rhs, { UnsafePointer($0) })
        
        return lhsPointer == rhsPointer
    }
}
