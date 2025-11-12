enum ComparisonStatus { excellent, good, acceptable, poor }

class ComparisonResult {
  final double userValue;
  final double detectedValue;
  final double difference;
  final double percentageError;
  final ComparisonStatus status;

  ComparisonResult({
    required this.userValue,
    required this.detectedValue,
    required this.difference,
    required this.percentageError,
    required this.status,
  });
}
