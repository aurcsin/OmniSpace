// File: lib/models/analysis_result.dart

/// Stores the output of AI text analysis.
class AnalysisResult {
  final String? summary;
  final String? mood;
  final List<String> insights;

  AnalysisResult({
    this.summary,
    this.mood,
    List<String>? insights,
  }) : insights = insights ?? [];

  /// Convert this result to JSON.
  Map<String, dynamic> toJson() => {
        'summary': summary,
        'mood': mood,
        'insights': insights,
      };

  /// Create an AnalysisResult from JSON.
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      summary: json['summary'] as String?,
      mood: json['mood'] as String?,
      insights:
          (json['insights'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  }
}
