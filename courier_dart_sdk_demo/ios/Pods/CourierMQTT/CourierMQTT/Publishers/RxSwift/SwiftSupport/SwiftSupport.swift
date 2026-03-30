import Foundation

typealias IntMax = Int64
typealias RxAbstractInteger = FixedWidthInteger

extension SignedInteger {
    func toIntMax() -> IntMax {
        IntMax(self)
    }
}
