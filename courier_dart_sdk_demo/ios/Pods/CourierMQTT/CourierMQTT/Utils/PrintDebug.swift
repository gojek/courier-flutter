import Foundation

func printDebug(_ text: String) {
    #if ALPHA || DEBUG || INTEGRATION
    NSLog(text, [])
    #endif
}
