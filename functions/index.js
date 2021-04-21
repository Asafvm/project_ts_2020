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
  const teams = admin.firestore().collection("teams");  //setting referance

  //creating a team
  var teamid = await teams.add(data["teamInfo"]); //add will give each entry a random id
  if (teamid) console.log("Team created with id:" + teamid.id + "\n");
  else {
    console.log("Faild to create team\n");
    return null;
  }
  try {
    const members = data["members"];

    const promises = [];
    for (const m in members) {
      //WHY IS m AN INDEX?!?!
      console.log("member " + members[m]);
      const p = teams
        .doc(teamid.id)
        .collection("members")
        .doc(members[m])
        .set({});

      promises.push(p);
    }
    await Promise.all(promises);
  } catch (e) {
    console.log("Error adding members ::" + e);
  }
  return teamid.id;
});

//add field to team document
exports.updateTeam = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams");
  const teamid = data["teamid"];
  const teamdata = data["data"];

  console.log(teamid + " Url=" + teamdata);
  console.log("Url2=" + teamdata["logoUrl"]);
  // eslint-disable-next-line promise/no-nesting
  teams
    .doc(teamid)
    .update(teamdata)
    .then((val) => {
      console.log("success: updated team info ");
      return true;
    })
    .catch((err) => {
      console.log("could not updated team info. error: " + err);
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
  });

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
    await instruments.update(
      {
        entries: Object.assign({}, data["entries"]),
      } //map every list item to index number
    );
  }
);

//add part to team's inventory
exports.addPart = functions.https.onCall(async (data, context) => {
  
  const teamid = data["teamID"];
  const partdata = data["part"];

  console.log('Team: '+teamid);
  console.log('Part: '+partdata);
  
  const parts = admin
    .firestore()
    .collection("teams")
    .doc(teamid)
    .collection("parts");

    await parts.add(partdata);
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

exports.addSite = functions.https.onCall((data, context) => {
  const sites = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites");
  
  return sites.add(
    data["site"]);
  
});

exports.addRoom = functions.https.onCall((data, context) => {
  const sites = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites")
    .doc(data["siteId"])
    .collection("rooms");
  
  return sites.add(
    data["room"]);
  
});

exports.linkInstruments = functions.https.onCall((data, context) => {
  const room = admin
  .firestore()
  .collection("teams")
  .doc(data["teamId"])
  .collection("sites")
  .doc(data["siteId"])
  .collection("rooms")
  .doc(data["roomId"])
  .collection("assigned");

  const promises = [];
  const instruments = data["instruments"];
  instruments.map((instrument) => { 
    const p = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("instruments")
    .doc(instrument.instrumentCode)
    .collection("instances")
    .doc(instrument.instanceSerial).update({"currentSiteId" : data["siteId"],
    "currentRoomId" : data["roomId"],});
    
    const r = room.add(instrument);
    promises.push(p);
    promises.push(r);

    return Promise.all(promises);
  });
});

//case user exited from

  exports.autoInstanceOnUpdate = functions.firestore
  .document("teams/{teamId}/instruments/{instrumentId}/instances/{instanceId}")
  
  //remove from old location on update
  .onUpdate((change,context)=>{
    var deviceBefore = change.before.data();
    var deviceAfter = change.after.data();

    console.log(deviceBefore['instrumentCode']+" : "+deviceBefore['serial']
    +" moved from "+deviceBefore['currentSiteId']+", room:"+deviceBefore['currentRoomId']
    +" to "+deviceAfter['currentSiteId']+", room:"+deviceAfter['currentRoomId']);

    var assigned = admin
    .firestore()
    .collection("teams")
    .doc(context.params.teamId)
    .collection("sites")
    .doc(deviceBefore['currentSiteId'])
    .collection("rooms")
    .doc(deviceBefore['currentRoomId'])
    .collection("assigned");
    
    var docs = assigned.get()
    .then((val)=>{
      val.docs.forEach((doc)=>{
      if(doc.data()['instanceSerial'] === deviceBefore['serial'] && doc.data()['instrumentCode'] === deviceBefore['instrumentCode'])  {
        assigned.doc(doc.id).delete();
      }
    });      
    return null;
  })
 .catch((e)=>e);
});

    


  