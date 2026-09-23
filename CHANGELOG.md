## 0.2.5

### Improved
- Use a super parameter for `selfname` to satisfy pub.dev static analysis; no functional changes.

## 0.2.4

### Added
- **Documentation**: Added an advanced README section on capturing named third-party `Logger` instances from `package:logging`.
  - Clarified that all OutputLogger-based sinks (`OutputLogger`, `DevOutputLogger`, `FileOutputLogger`) support named-logger capture.
  - Added observability-focused guidance for common third-party integrations (HTTP SDKs, Database SDKs, Message Queue SDKs, and other infrastructure clients).
  - Included a practical example using a named logger (`GoogleAI.HTTP`) and sample output.

## 0.2.3

### Added
- **Documentation**: Added an "Advanced Usage" section to the README.
  - Provided a level mapping reference between Dart `logging` and other common languages.
  - Demonstrated how to access the native `Logger` instance for full API flexibility.
  - Included examples for integrating Flutter's global error handlers (`FlutterError.onError`, `PlatformDispatcher`) with `BasicLogger`.

### Improved
- Clarified the relationship between `BasicLogger` and the standard `package:logging` ecosystem.

## 0.2.2
- perf: use conditional constructor termination to share a unified data type while bypassing redundant base-class logic during inheritance.

## 0.2.1
- docs: add multi-sink and log routing patterns to README.
- fix: detachLogger, concurrent modification during iteration.

## 0.2.0
- BREAKING: DevOutputLogger, uses positional arguments, passing `parentName` in the same way as its parent.
- fix:  If `selfonly` is false, all logs with a `parentName` match are output.

## 0.1.1
- The logger name is set to selfname.
- selfonly, when true, filter by selfname. Otherwise, output all.

## 0.1.0
- Refactored with Template Method pattern,
- allowing customization of record and format methods.

## 0.0.3

- supports all six platforms, with file logging separated for non-web platforms.

## 0.0.2

- new, logrec, log message at the specified level.

## 0.0.1

- Initial version.
