import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/team_provider.dart';

//TODO: fix firebase links

class FirebaseFirestoreProvider {
  Future<void> uploadFields(List<Map<String, dynamic>> fields, String fileName,
      String instrumentId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrumentReport")
        .call(<String, dynamic>{
      "Instrument_id": instrumentId,
      "file_name": fileName,
      "fields": fields,
    }).then((_) async => {
              print('fields uploaded'),
            });
  }

  Future<void> uploadInstrument(Instrument _newInstrument) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrument")
        .call(<String, dynamic>{
          "instrument": _newInstrument.toJson(),
          "teamId": TeamProvider().getCurrentTeam.getTeamId
        })
        .then((value) => print("Upload Finished: ${value.data}"))
        .catchError((e) => throw new Exception("${e.details["message"]}"));
  }

  Future<void> uploadInstrumentInstance(
      InstrumentInstance _newInstrument, String instrumentId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrumentInstance")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "instrumentID": instrumentId,
      "instrument": _newInstrument.toJson()
    });
  }

  Future<void> uploadPart(Part _newPart) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addPart")
        .call(<String, dynamic>{"part": _newPart.toJson()});
  }
}
