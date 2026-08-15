class FootballMatch {
  const FootballMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.kickoff,
    this.homeScore,
    this.awayScore,
    this.status = 'scheduled',
    this.minute,
    this.venue,
    this.homeLogo,
    this.awayLogo,
    this.leagueId,
  });

  final String id;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final DateTime kickoff;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final String? minute;
  final String? venue;
  final String? homeLogo;
  final String? awayLogo;
  final String? leagueId;

  bool get isLive => status == 'live' || status == 'inplay';
  bool get isFinished => status == 'finished' || status == 'ft' || status == 'match finished';

  String get scoreLabel {
    if (homeScore == null || awayScore == null) {
      return '-';
    }
    return '$homeScore - $awayScore';
  }

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    DateTime kickoff = DateTime.now();
    final String date = (json['date'] ?? json['dateEvent'] ?? '').toString();
    final String time = (json['time'] ?? json['strTime'] ?? '00:00:00').toString();
    if (date.isNotEmpty) {
      kickoff = DateTime.tryParse('${date}T$time') ?? DateTime.tryParse(date) ?? DateTime.now();
    } else if (json['kickoff'] != null) {
      kickoff = DateTime.tryParse(json['kickoff'].toString()) ?? DateTime.now();
    }

    int? parseScore(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return null;
      }
      return int.tryParse(value.toString());
    }

    String status = (json['status'] ?? json['strStatus'] ?? 'scheduled').toString().toLowerCase();
    if (status.contains('live') || status.contains('in play') || status.contains('1h') || status.contains('2h')) {
      status = 'live';
    } else if (status.contains('finish') || status == 'ft' || status == 'match finished') {
      status = 'finished';
    }

    return FootballMatch(
      id: '${json['id'] ?? json['idEvent'] ?? ''}',
      homeTeam: (json['home_team'] ?? json['strHomeTeam'] ?? '').toString(),
      awayTeam: (json['away_team'] ?? json['strAwayTeam'] ?? '').toString(),
      league: (json['league'] ?? json['strLeague'] ?? 'فوتبال').toString(),
      kickoff: kickoff,
      homeScore: parseScore(json['home_score'] ?? json['intHomeScore']),
      awayScore: parseScore(json['away_score'] ?? json['intAwayScore']),
      status: status,
      minute: json['minute']?.toString() ?? json['strProgress']?.toString(),
      venue: (json['venue'] ?? json['strVenue'])?.toString(),
      homeLogo: (json['home_logo'] ?? json['strHomeTeamBadge'])?.toString(),
      awayLogo: (json['away_logo'] ?? json['strAwayTeamBadge'])?.toString(),
      leagueId: (json['league_id'] ?? json['idLeague'])?.toString(),
    );
  }
}
