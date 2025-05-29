/// My Diff-Merge logic is a last-write-wins approach-
/// with basic conflict detection and resolution.
/// Timestamp was implemented to determine which version to keep.
library;

class TextMerger {
  static TextMergeResult merge({
    required String localContent,
    required String remoteContent,
    required DateTime localLastEdit,
    required DateTime remoteLastEdit,
    String? baseContent,
  }) {
    if (localContent == remoteContent) {
      return TextMergeResult(
        content: localContent,
        hasConflict: false,
        strategy: MergeStrategy.noChange,
      );
    }

    if (localContent.isEmpty) {
      return TextMergeResult(
        content: remoteContent,
        hasConflict: false,
        strategy: MergeStrategy.acceptRemote,
      );
    }

    if (remoteContent.isEmpty) {
      return TextMergeResult(
        content: localContent,
        hasConflict: false,
        strategy: MergeStrategy.keepLocal,
      );
    }

    if (remoteLastEdit.isAfter(localLastEdit)) {
      final mergedContent = _intelligentMerge(localContent, remoteContent);
      
      return TextMergeResult(
        content: mergedContent.content,
        hasConflict: mergedContent.hasConflict,
        strategy: MergeStrategy.lastWriteWins,
        winningTimestamp: remoteLastEdit,
      );
    } else {
      return TextMergeResult(
        content: localContent,
        hasConflict: true,
        strategy: MergeStrategy.keepLocal,
        winningTimestamp: localLastEdit,
      );
    }
  }

  static _IntelligentMergeResult _intelligentMerge(String local, String remote) {
    if (remote.contains(local)) {
      return _IntelligentMergeResult(content: remote, hasConflict: false);
    }
    
    if (local.contains(remote)) {
      return _IntelligentMergeResult(content: local, hasConflict: false);
    }

    final commonPrefix = _getCommonPrefix(local, remote);
    final commonSuffix = _getCommonSuffix(local, remote);
    
    if (commonPrefix.length + commonSuffix.length >= 
        (local.length * 0.8).round()) {
      final localMiddle = local.substring(
        commonPrefix.length,
        local.length - commonSuffix.length,
      );
      final remoteMiddle = remote.substring(
        commonPrefix.length,
        remote.length - commonSuffix.length,
      );
      
      final mergedContent = commonPrefix + 
                           localMiddle + 
                           (localMiddle != remoteMiddle ? '\n$remoteMiddle' : '') + 
                           commonSuffix;
      
      return _IntelligentMergeResult(
        content: mergedContent,
        hasConflict: localMiddle != remoteMiddle,
      );
    }

    return _IntelligentMergeResult(content: remote, hasConflict: true);
  }

  static String _getCommonPrefix(String a, String b) {
    int i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    return a.substring(0, i);
  }

  static String _getCommonSuffix(String a, String b) {
    int i = 0;
    while (i < a.length && 
           i < b.length && 
           a[a.length - 1 - i] == b[b.length - 1 - i]) {
      i++;
    }
    return a.substring(a.length - i);
  }

  static double calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;
    
    if (longer.isEmpty) return 1.0;
    
    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  static int _levenshteinDistance(String a, String b) {
    final matrix = List.generate(
      a.length + 1,
      (i) => List.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }
}

class TextMergeResult {
  final String content;
  final bool hasConflict;
  final MergeStrategy strategy;
  final DateTime? winningTimestamp;

  const TextMergeResult({
    required this.content,
    required this.hasConflict,
    required this.strategy,
    this.winningTimestamp,
  });

  @override
  String toString() {
    return 'TextMergeResult(strategy: $strategy, hasConflict: $hasConflict, '
           'content: ${content.length} chars)';
  }
}

class _IntelligentMergeResult {
  final String content;
  final bool hasConflict;

  const _IntelligentMergeResult({
    required this.content,
    required this.hasConflict,
  });
}

enum MergeStrategy {
  noChange,
  acceptRemote,
  keepLocal,
  lastWriteWins,
  intelligentMerge,
}