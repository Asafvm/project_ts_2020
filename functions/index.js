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

  return new Promise(async (resolve, reject) => {
    await teams
      .add(data) //add will give each entry a random id
      .then(async (value) => {

        await teams
          .doc(value.id)
          .collection("members")
          .doc(data["creatorEmail"])
          .create({
            name: data["creatorName"],
          });
                
        await admin
          .firestore()
          .collection("users")
          .doc(data["creatorEmail"])
          .collection("teams")
          .doc(value.id)
          .set({});
          
        return resolve(value.id);

      }).catch(reason)
      return reject(reason);
    
  }
  );
});

exports.addDevice = functions.https.onCall(async (data, context) => {
  const devices = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("devices");

  var snapshot = await devices.get();
  snapshot.forEach((doc) => {
    //check for duplicates
    if (doc.id === data["device"]["codeName"])
      //throw error message if found
      throw new functions.https.HttpsError(
        "already-exists",
        "Device already exists",
        "Duplicate code name"
      );
  });
  //upload new device
  await devices.doc(data["device"]["codeName"]).set(data["device"]);
});

exports.addDeviceInstance = functions.https.onCall(async (data, context) => {
  const devices = admin
    .firestore()
    .collection("teams")
    .doc(data["teamID"])
    .collection("devices")
    .doc(data["deviceID"])
    .collection("instances")
    .doc(data["device"]["serial"]);

  // const snapshot = await devices.get();
  // if (snapshot.exists)
  //   //throw error message if found
  //   throw new functions.https.HttpsError('already-exists', 'Device already exists', 'Duplicate serial');

  await devices.create(data["device"]);
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
  //upload new device
  await parts.create(data["part"]);
});

exports.addDeviceReport = functions.https.onCall((data, context) => {
  const devicereports = admin
    .firestore()
    .collection("username")
    .doc("company")
    .collection("devices")
    .doc(data["device_id"])
    .collection("reports")
    .doc(data["file_name"]);

  return new Promise(async (resolve, reject) => {
    try {
      await devicereports.set(
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
