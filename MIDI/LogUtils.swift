//
//  LogUtils.swift
//  MIDI
//


func ENTRY_LOG(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) -> Void {
    if FUNCTION_LOGGING {
        log.debug("ENTRY", functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
}

func EXIT_LOG(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) -> Void {
    if FUNCTION_LOGGING {
        log.debug("EXIT", functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
}