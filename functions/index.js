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

exports.addDevice = functions.https.onCall(async (data, context) => {
  const devices = admin
    .firestore()
    .collection("username")
    .doc("company")
    .collection("devices");

    var snapshot = await devices.get();
    snapshot.forEach(doc => {
      //check for duplicates
      if (doc.data()["codeName"] === data["device"]["codeName"])
        //throw error message if found
        throw new functions.https.HttpsError('already-exists' ,'Device already exists', 'Duplicate code name');
    });
    //upload new device
    await devices.add(data["device"]);
  });

exports.addDeviceInstance = functions.https.onCall(async (data, context) => {
  const devices = admin
    .firestore()
    .collection("username")
    .doc("company")
    .collection("devices")
    .doc(data["device_id"])
    .collection("instances")
    .doc(data["device"]["serial"]);
  
  const snapshot = await devices.get();
  if (snapshot.exists)
    //throw error message if found
    throw new functions.https.HttpsError('already-exists', 'Device already exists', 'Duplicate serial');
    
  await devices.set(data["device"]);
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
