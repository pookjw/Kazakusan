import Foundation

extension AsyncThrowingStream.Continuation: Equatable {
    public static func ==(lhs: AsyncThrowingStream.Continuation, rhs: AsyncThrowingStream.Continuation) -> Bool {
        let lhsPointer: UnsafePointer<AsyncThrowingStream<Element, Failure>.Continuation> = withUnsafePointer(to: lhs, { UnsafePointer($0) })
        let rhsPointer: UnsafePointer<AsyncThrowingStream<Element, Failure>.Continuation> = withUnsafePointer(to: rhs, { UnsafePointer($0) })
        
        return lhsPointer == rhsPointer
    }
}
