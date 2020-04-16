const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// const spawn = require("child-process-promise").spawn;
// const path = require("path");
// const os = require("os");
// const fs = require("fs");

exports.addDevice = functions.https.onCall((data, context) => {
  const devices = admin.firestore().collection("test");

  return new Promise(async (resolve, reject) => {
    try {
      const msg = await devices.add({
        manifacturer: data["manifacturer"],
        codeName: data["codeName"],
        codeNumber: data["codeNumber"],
        model: data["model"],
        price: data["price"],
      });
      return resolve({
        success: true,
      });
    } catch (reason) {
      return reject(reason);
    }
  });
});

exports.addDeviceReport = functions.https.onCall((data, context) => {
  const devices = admin
    .firestore()
    .collection("test")
    .collection(data["device_id"])
    .collection("reports");

  return new Promise((resolve, reject) => {
    return devices
      .add({
        file_path: data["file_path"],
        fields: data["fields"],
      })
      .then((msg) => {
        return resolve({
          success: true,
        });
      })
      .catch(reject);
  });
});
