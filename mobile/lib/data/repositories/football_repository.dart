import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/match.dart';
import '../sources/local_catalog.dart';

class FootballRepository {
  FootballRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<FootballMatch>> fetchMatches() async {
    final List<FootballMatch> remote = await _tryRemoteMatches();
    if (remote.isNotEmpty) {
      return _mergeUnique(remote, LocalCatalog.matches());
    }
    return LocalCatalog.matches();
  }

  Future<List<FootballMatch>> fetchLive() async {
    final List<FootballMatch> all = await fetchMatches();
    final List<FootballMatch> live = all.where((FootballMatch m) => m.isLive).toList();
    if (live.isNotEmpty) {
      return live;
    }
    return all.take(3).toList();
  }

  Future<FootballMatch> fetchMatch(String id) async {
    try {
      final dynamic json = await _client.getJson(_client.join(AppEnv.apiBaseUrl, 'matches/$id.json'));
      if (json is Map<String, dynamic>) {
        return FootballMatch.fromJson(json);
      }
    } on ApiException {
      // continue
    }
    final FootballMatch? local = LocalCatalog.matchById(id);
    if (local != null) {
      return local;
    }
    final List<FootballMatch> all = await fetchMatches();
    return all.firstWhere(
      (FootballMatch m) => m.id == id,
      orElse: () => throw const ApiException('بازی پیدا نشد'),
    );
  }

  Future<List<FootballMatch>> _tryRemoteMatches() async {
    final List<FootballMatch> collected = <FootballMatch>[];

    try {
      final dynamic json = await _client.getJson(_client.join(AppEnv.apiBaseUrl, 'matches.json'));
      collected.addAll(_parse(json));
    } on ApiException {
      // ignore
    }

    try {
      final String today = DateTime.now().toIso8601String().split('T').first;
      final dynamic json = await _client.getJson(
        '${AppEnv.footballApiBaseUrl}/eventsday.php?d=$today&s=Soccer',
      );
      collected.addAll(_parseSportsDb(json));
    } on ApiException {
      // Football API key/network missing — caller falls back.
    }

    return collected;
  }

  List<FootballMatch> _parse(dynamic json) {
    if (json is List) {
      return json
          .whereType<Map>()
          .map((Map item) => FootballMatch.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (json is Map && json['items'] is List) {
      return (json['items'] as List<dynamic>)
          .whereType<Map>()
          .map((Map item) => FootballMatch.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (json is Map && json['matches'] is List) {
      return (json['matches'] as List<dynamic>)
          .whereType<Map>()
          .map((Map item) => FootballMatch.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return <FootballMatch>[];
  }

  List<FootballMatch> _parseSportsDb(dynamic json) {
    if (json is! Map || json['events'] is! List) {
      return <FootballMatch>[];
    }
    return (json['events'] as List<dynamic>)
        .whereType<Map>()
        .map((Map item) => FootballMatch.fromJson(Map<String, dynamic>.from(item)))
        .take(20)
        .toList();
  }

  List<FootballMatch> _mergeUnique(List<FootballMatch> primary, List<FootballMatch> extra) {
    final Map<String, FootballMatch> map = <String, FootballMatch>{};
    for (final FootballMatch match in extra) {
      map[match.id] = match;
    }
    for (final FootballMatch match in primary) {
      map[match.id] = match;
    }
    final List<FootballMatch> result = map.values.toList()
      ..sort((FootballMatch a, FootballMatch b) => a.kickoff.compareTo(b.kickoff));
    return result;
  }
}
