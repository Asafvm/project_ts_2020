class TeamProvider {
  String _currentTeam;
  List<String> _teams;

  void addTeam(String team) {
    if (!_teams.contains(team)) _teams.add(team);
  }

  void setCurrentTeam(String team) {
    addTeam(team);
    _currentTeam = team;
  }

  String get getCurrentTeam => _currentTeam;
}
