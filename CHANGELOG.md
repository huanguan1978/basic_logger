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
