import 'dart:collection';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, _OperationMetrics> _metrics = {};
  final Queue<_PerformanceLog> _logs = Queue<_PerformanceLog>();
  static const int _maxLogs = 1000;

  void startOperation(String operationName) {
    final startTime = DateTime.now();
    _metrics[operationName] = _OperationMetrics(
      operationName: operationName,
      startTime: startTime,
      callCount: (_metrics[operationName]?.callCount ?? 0) + 1,
    );
  }

  void endOperation(String operationName, {String? details}) {
    final endTime = DateTime.now();
    final metrics = _metrics[operationName];

    if (metrics != null) {
      final duration = endTime.difference(metrics.startTime);
      metrics.totalDuration += duration;
      metrics.lastDuration = duration;

      // Add to logs
      _addLog(_PerformanceLog(
        operationName: operationName,
        startTime: metrics.startTime,
        endTime: endTime,
        duration: duration,
        details: details,
      ));

      // Average duration is calculated via getter
    }
  }

  void recordMetric(String metricName, num value, {String? unit}) {
    final log = _PerformanceLog(
      operationName: metricName,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      duration: Duration.zero,
      details: 'Value: $value ${unit ?? ""}',
      isMetric: true,
    );
    _addLog(log);
  }

  void _addLog(_PerformanceLog log) {
    _logs.addLast(log);
    if (_logs.length > _maxLogs) {
      _logs.removeFirst();
    }
  }

  Map<String, dynamic> getMetrics() {
    final result = <String, dynamic>{};

    for (final entry in _metrics.entries) {
      result[entry.key] = {
        'callCount': entry.value.callCount,
        'totalDuration': entry.value.totalDuration.inMilliseconds,
        'averageDuration': entry.value.averageDuration.inMilliseconds,
        'lastDuration': entry.value.lastDuration?.inMilliseconds,
      };
    }

    return result;
  }

  List<Map<String, dynamic>> getRecentLogs({int limit = 50}) {
    return _logs.toList().reversed.take(limit).map((log) => {
      'operation': log.operationName,
      'startTime': log.startTime.toIso8601String(),
      'duration': log.duration.inMilliseconds,
      'details': log.details,
      'isMetric': log.isMetric,
    }).toList();
  }

  void clearMetrics() {
    _metrics.clear();
    _logs.clear();
  }

  void printSummary() {
    print('\n=== Performance Monitor Summary ===');
    for (final entry in _metrics.entries) {
      final metrics = entry.value;
      print('${entry.key}:');
      print('  Calls: ${metrics.callCount}');
      print('  Total: ${metrics.totalDuration.inMilliseconds}ms');
      print('  Average: ${metrics.averageDuration.inMilliseconds}ms');
      print('  Last: ${metrics.lastDuration?.inMilliseconds ?? 0}ms');
    }
    print('===================================\n');
  }
}

class _OperationMetrics {
  final String operationName;
  final DateTime startTime;
  int callCount;
  Duration totalDuration = Duration.zero;
  Duration? lastDuration;
  Duration get averageDuration => callCount > 0 ? totalDuration ~/ callCount : Duration.zero;

  _OperationMetrics({
    required this.operationName,
    required this.startTime,
    required this.callCount,
  });
}

class _PerformanceLog {
  final String operationName;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String? details;
  final bool isMetric;

  _PerformanceLog({
    required this.operationName,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.details,
    this.isMetric = false,
  });
}

// Convenience functions for easy use
void startPerf(String operation) => PerformanceMonitor().startOperation(operation);
void endPerf(String operation, {String? details}) => PerformanceMonitor().endOperation(operation, details: details);
void recordPerf(String metric, num value, {String? unit}) => PerformanceMonitor().recordMetric(metric, value, unit: unit);
