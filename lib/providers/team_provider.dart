import 'package:flutter/cupertino.dart';
import 'package:teamshare/models/team.dart';

class TeamProvider with ChangeNotifier {
  static Team _currentTeam;
  static Set<Team> _teams = new Set<Team>();

  static final TeamProvider _instance = TeamProvider._internal();
  factory TeamProvider() {
    return _instance;
  }
  TeamProvider._internal();

  void addTeam(Team team) {
    _teams.add(team);
    notifyListeners();
  }

  void setCurrentTeam(Team team) {
    _currentTeam = team;
  }

  void clearCurrentTeam() {
    _currentTeam = null;
  }

  Team get getCurrentTeam => _currentTeam;

  List<Team> getTeams() {
    return _teams == null ? [] : _teams;
  }

  static Stream<Set<Team>> getTeamStream() {
    return Stream.value(_teams);
  }
}
