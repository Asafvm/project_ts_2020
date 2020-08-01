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
  const teams = admin
    .firestore()
    .collection("teams");

  return new Promise(async (resolve, reject) => {
    try {
      await teams.add(data) //add will give each entry a random id
        .then(async value => {
          await teams.doc(value.id)
            .collection("users")
            .doc(data["creatorEmail"])
            .create({
              "name": data["creatorName"],
            });
          
          await admin.firestore().collection("userEmail").doc(data["creatorEmail"]).create({"teamId" : value.id});
        return resolve(value.id)
      });
      return reject(reason);

    } catch (reason) {
      return reject(reason);
    }
  });
  
});

exports.findTeam = functions.https.onCall(async (data, context) => {
  const teams = await admin
    .firestore()
    .collectionGroup("users").where('name','==',data['user']).get();

  return new Promise(async (resolve, reject) => {
    try {
      var teamList = [];
      console.log(teams);
      
      // await teams.where(documentId(),'==',data["user"]).get() //get documents
      //   .then(value => {
      //     value.forEach((val) => console.log(val.data()))
          //["name"] === data["user"] ? teamList.push(value) : "")
          
          //.forEach((user) => if(user===data["userEmail"] teamList.push(team))))
      return resolve(teamList);

      //  }
       // );
        
        
      
      //return reject(reason);

    }
    catch (reason) {
      return reject(reason);
    
    }
  }
  );
});
  



exports.addDevice = functions.https.onCall(async (data, context) => {
  const devices = admin
    .firestore()
    .collection("username")
    .doc("company")
    .collection("devices");

    var snapshot = await devices.get();
    snapshot.forEach(doc => {
      //check for duplicates
      if (doc.id === data["device"]["codeName"])
        //throw error message if found
        throw new functions.https.HttpsError('already-exists' ,'Device already exists', 'Duplicate code name');
    });
    //upload new device
    await devices.doc(data["device"]["codeName"]).set(data["device"]);
});
  
exports.addPart = functions.https.onCall(async (data, context) => {
  const parts = admin
    .firestore()
    .collection("username")
    .doc("company")
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

exports.addDeviceInstance = functions.https.onCall(async (data, context) => {
  const devices = admin
    .firestore()
    .collection("username")
    .doc("company")
    .collection("devices")
    .doc(data["device_id"])
    .collection("instances")
    .doc(data["device"]["serial"]);
  
  // const snapshot = await devices.get();
  // if (snapshot.exists)
  //   //throw error message if found
  //   throw new functions.https.HttpsError('already-exists', 'Device already exists', 'Duplicate serial');
    
  await devices.create(data["device"]);
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
