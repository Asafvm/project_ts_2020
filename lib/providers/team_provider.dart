import 'package:flutter/cupertino.dart';
import 'package:teamshare/models/team.dart';

class TeamProvider with ChangeNotifier {
  Team _currentTeam;
  List<Team> _teams;

  static final TeamProvider _instance = TeamProvider._internal();
  factory TeamProvider() {
    return _instance;
  }
  TeamProvider._internal();

  void addTeam(Team team) {
    if (!_teams.contains(team)) _teams.add(team);
    notifyListeners();
  }

  void setCurrentTeam(Team team) {
    _currentTeam = team;
  }

  void clearCurrentTeam() {
    _currentTeam = null;
  }

  Team get getCurrentTeam => _currentTeam;
}
