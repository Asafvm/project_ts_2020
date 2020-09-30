//init functions
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
//for storage
const spawn = require("child-process-promise").spawn;
const path = require("path");
const os = require("os");
const fs = require("fs");
const { exception } = require("console");

exports.addTeam = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams");

  return await teams
    .add(data) //add will give each entry a random id
    .then(async (value) => {
      // eslint-disable-next-line promise/no-nesting
      await teams
        .doc(value.id)
        .collection("members")
        .doc(data["creatorEmail"])
        .set({})
        .then((val) => console.log("success: added member "))
        .catch((err) => console.log("could not add member. error: " + err));
      return value.id;
    })
    .then((val) => {
      console.log("success! new team created: " + val);
      return val.id;
    })
    .catch((reason) => {
      console.log("error creating team: " + reason); return reason
    })
  
}
);

exports.autoAddUser = functions.firestore
  .document('teams/{teamId}/members/{userId}')
  .onWrite((change, context) => {
    return admin.firestore()
      .collection("users")
      .doc(context.params.userId)
      .collection("teams")
      .doc(context.params.teamId)
      .create({
        "name": context.params.teamId,
      });
  });

  //case user was removed from team
  exports.autoTeamManagement = functions.firestore
  .document('teams/{teamId}/members/{userId}')
  .onDelete((snap, context) => {
    return admin.firestore()
      .collection("users")
      .doc(context.params.userId)
      .collection("teams")
      .doc(context.params.teamId).delete()
      
  });
  //case user exited from
  exports.autoUserManagement = functions.firestore
  .document('users/{userId}/teams/{teamId}')
  .onDelete((snap, context) => {
    return admin.firestore()
      .collection("teams")
      .doc(context.params.teamId)
      .collection("members")
      .doc(context.params.userId).delete()
      
  });
  

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

exports.addInstrumentInstance = functions.https.onCall(async (data, context) => {
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
});

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

exports.addInstrumentReport = functions.https.onCall((data, context) => {
  const instrumentreports = admin
    .firestore()
    .collection("username")
    .doc("company")
    .collection("instruments")
    .doc(data["instrument_id"])
    .collection("reports")
    .doc(data["file_name"]);

  return new Promise(async (resolve, reject) => {
    try {
      await instrumentreports.set(
        Object.assign({}, data["fields"]) //map every list item to index number
      );
      return resolve({
        success: true,
      });
    } catch (reason) {
      return reject(reason);
    }
  });
});
