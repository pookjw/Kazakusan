import Foundation

func fatalWhenMainThread() {
    if Thread.isMainThread {
        fatalError("Do not run at Main Thread.")
    }
}
