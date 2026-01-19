import 'package:cloud_firestore/cloud_firestore.dart';

enum GameStatus {
  lobby,
  counting_down, // 3-2-1
  in_progress,
  finished
}

class GameModel {
  final String id;
  final String pin;
  final String hostId;
  final GameStatus status;
  final DateTime createdAt;
  final List<String> selectedCategories;
  final List<GameRound> rounds;
  final int currentRoundIndex;
  final List<GamePlayer> players;
  final Map<String, int> scores; // Total scores: userId -> score

  GameModel({
    required this.id,
    required this.pin,
    required this.hostId,
    required this.status,
    required this.createdAt,
    required this.selectedCategories,
    required this.rounds,
    required this.currentRoundIndex,
    required this.players,
    required this.scores,
  });

  factory GameModel.fromJson(Map<String, dynamic> json, String id) {
    return GameModel(
      id: id,
      pin: json['pin'] as String,
      hostId: json['host_id'] as String,
      status: GameStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameStatus.lobby,
      ),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      selectedCategories: List<String>.from(json['selected_categories'] ?? []),
      rounds: (json['rounds'] as List<dynamic>?)
              ?.map((e) => GameRound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentRoundIndex: json['current_round_index'] as int? ?? 0,
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => GamePlayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      scores: Map<String, int>.from(json['scores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pin': pin,
      'host_id': hostId,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
      'selected_categories': selectedCategories,
      'rounds': rounds.map((e) => e.toJson()).toList(),
      'current_round_index': currentRoundIndex,
      'players': players.map((e) => e.toJson()).toList(),
      'scores': scores,
    };
  }
}

class GameRound {
  final String text;
  final String category;
  final int roundNumber;
  final DateTime? startTime; // Null if not started
  final List<String> finishedPlayerIds; // Track who finished in order
  final Map<String, int> playerWpms; // Store WPM per player: userId -> wpm

  GameRound({
    required this.text,
    required this.category,
    required this.roundNumber,
    this.startTime,
    this.finishedPlayerIds = const [],
    this.playerWpms = const {},
  });

  factory GameRound.fromJson(Map<String, dynamic> json) {
    return GameRound(
      text: json['text'] as String,
      category: json['category'] as String,
      roundNumber: json['round_number'] as int,
      startTime: json['start_time'] != null
          ? (json['start_time'] as Timestamp).toDate()
          : null,
      finishedPlayerIds:
          List<String>.from(json['finished_player_ids'] ?? []),
      playerWpms: Map<String, int>.from(json['player_wpms'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'category': category,
      'round_number': roundNumber,
      'start_time': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'finished_player_ids': finishedPlayerIds,
      'player_wpms': playerWpms,
    };
  }
}

class GamePlayer {
  final String id;
  final String displayName;
  final String? photoUrl;
  final bool isReady;
  final double currentProgress; // 0.0 to 1.0, for showing cars moving

  GamePlayer({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.isReady = false,
    this.currentProgress = 0.0,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> json) {
    return GamePlayer(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      isReady: json['is_ready'] as bool? ?? false,
      currentProgress: (json['current_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'photo_url': photoUrl,
      'is_ready': isReady,
      'current_progress': currentProgress,
    };
  }
  
  GamePlayer copyWith({
    String? id,
    String? displayName,
    String? photoUrl,
    bool? isReady,
    double? currentProgress,
  }) {
    return GamePlayer(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isReady: isReady ?? this.isReady,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}
