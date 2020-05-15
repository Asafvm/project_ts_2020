//init functions
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
//for storage
const spawn = require("child-process-promise").spawn;
const path = require("path");
const os = require("os");
const fs = require("fs");

exports.addDevice = functions.https.onCall((data, context) => {
  const devices = admin.firestore().collection("test");

  return new Promise(async (resolve, reject) => {
    try {
      await devices.add(data["device"]);
      return resolve({
        success: true,
      });
    } catch (reason) {
      return reject(reason);
    }
  });
});

exports.addDeviceReport = functions.https.onCall((data, context) => {
  const devicereports = admin
    .firestore()
    .collection("test")
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
