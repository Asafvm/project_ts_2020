//init functions
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
//for storage
const spawn = require("child-process-promise").spawn;
const path = require("path");
const os = require("os");
const fs = require("fs");
const { exception, info } = require("console");
const { firebaseConfig } = require("firebase-functions");

//create new team
exports.addTeam = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams");
  var teamid = await teams.add(data["teamInfo"]); //add will give each entry a random id
  console.log("Team id:" + teamid.id + "\n");

  // eslint-disable-next-line promise/no-nesting
  try {
    const members = data["members"];

    const promises = [];
    for (const m in members){ //WHY IS m AN INDEX?!?!
      console.log("member "+ members[m]);
      const p = teams
      .doc(teamid.id)
      .collection("members").doc(members[m]).set({})
 
      promises.push(p);
    }
    await Promise.all(promises);
    
    
  } catch (e) {
    console.log('Error adding members ::' + e);
  }
  return teamid.id;
});


//add field to team document
exports.updateTeam = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams");
  // eslint-disable-next-line promise/no-nesting
  await teams
    .doc(data['teamid'])
0    .update(data['data'])
    .then((val) => {
      console.log("success: updated team info ");
      return true;
    })
    .catch((err) => {
      console.log("could updated team info. error: " + err);
      return false;
    });
});

//register team at user profile automatically
exports.autoAddUser = functions.firestore
  .document("teams/{teamId}/members/{userId}")
  .onWrite((change, context) => {
    return admin
      .firestore()
      .collection("users")
      .doc(context.params.userId)
      .collection("teams")
      .doc(context.params.teamId)
      .create({
        name: context.params.teamId,
      });
  });

//case user was removed from team or team was deleted
exports.autoTeamManagement = functions.firestore
  .document("teams/{teamId}/members/{userId}")
  .onDelete((snap, context) => {
    return admin
      .firestore()
      .collection("users")
      .doc(context.params.userId)
      .collection("teams")
      .doc(context.params.teamId)
      .delete();
  }
  );

//case user exited from
exports.autoUserManagement = functions.firestore
  .document("users/{userId}/teams/{teamId}")
  .onDelete((snap, context) => {
    return admin
      .firestore()
      .collection("teams")
      .doc(context.params.teamId)
      .collection("members")
      .doc(context.params.userId)
      .delete();
  });

//add instrument to team's inventory
exports.addInstrument = functions.https.onCall(async (data, context) => {
  const instruments = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("instruments");

  var snapshot = await instruments.get();
  snapshot.forEach((doc) => {
    //check for duplicates
    if (doc.id === data["instrument"]["codeName"])
      //throw error message if found
      throw new functions.https.HttpsError(
        "already-exists",
        "Instrument already exists",
        "Duplicate code name"
      );
  });
  //upload new instrument
  await instruments.doc(data["instrument"]["codeName"]).set(data["instrument"]);
});

//add instrument instance to team's inventory
exports.addInstrumentInstance = functions.https.onCall(
  async (data, context) => {
    const instruments = admin
      .firestore()
      .collection("teams")
      .doc(data["teamID"])
      .collection("instruments")
      .doc(data["instrumentID"])
      .collection("instances")
      .doc(data["instrument"]["serial"]);

    // const snapshot = await instruments.get();
    // if (snapshot.exists)
    //   //throw error message if found
    //   throw new functions.https.HttpsError('already-exists', 'Instrument already exists', 'Duplicate serial');

    await instruments.create(data["instrument"]);
    await instruments.update({
      "entries":
        Object.assign({}, data["entries"])
    } //map every list item to index number
    );
  }
);

//add part to team's inventory
exports.addPart = functions.https.onCall(async (data, context) => {
  const parts = admin
    .firestore()
    .collection("teams")
    .doc(data["teamID"])
    .collection("parts");

  //var snapshot = await parts.get();
  // snapshot.forEach(doc => {
  //   //check for duplicates
  //   if (doc.data()["reference"] === data["part"]["reference"])
  //     //throw error message if found
  //     throw new functions.https.HttpsError('already-exists' ,'Part already exists', 'Duplicate reference code');
  // });
  //upload new instrument
  await parts.create(data["part"]);
});

//add report's fields to instrument ducoment
exports.addInstrumentReport = functions.https.onCall((data, context) => {

  const instrumentreports = admin
    .firestore()
    .collection("teams")
    .doc(data["team_id"])
    .collection("instruments")
    .doc(data["instrument_id"])
    .collection("reports")
    .doc(data["file"]);


  return instrumentreports.set(
    Object.assign({}, data["fields"]) //map every list item to index number
  );


});
