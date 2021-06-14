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
  const teams = admin.firestore().collection("teams"); //setting referance

  //creating a team
  var teamid = await teams.add(data["teamInfo"]); //add will give each entry a random id
  if (teamid) console.log("Team created with id:" + teamid.id + "\n");
  else {
    console.log("Faild to create team\n");
    return null;
  }
  try {
    const members = data["members"];
    if (members !== null) {
      const promises = [];
      for (const [key, value] of Object.entries(members)) {
        const p = teams
          .doc(teamid.id)
          .collection("members")
          .doc(key)
          .set({ admin: value });
        promises.push(p);
      }
      await Promise.all(promises);
    }
  } catch (e) {
    console.log("Error adding members ::" + e);
    return { status: "failed", messege: e.toString() };
  }

  return { status: "success", teamId: teamid.id };
});

//add team member
//TODO: split to add and remove functions
exports.addTeamMember = functions.https.onCall(async (data, context) => {
  const teams = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("members"); //setting referance
  const members = data["members"];

  try {
    const promises = [];
    //add all members
    for (const [key, value] of Object.entries(members)) {
      const p = teams.doc(key).set({ admin: value });
      promises.push(p);
    }

    await Promise.all(promises);
  } catch (e) {
    console.log("Error adding members ::" + e);
    return { status: "failed", messege: e.toString() };
  }
  return { status: "success" };
});

exports.removeTeamMember = functions.https.onCall(async (data, context) => {
  const teams = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("members"); //setting referance
  const members = data["members"];
  //remove members

  try {
    const promises = [];
    //add all members
    members.forEach((member) => {
      const p = teams.doc(member).delete();
      promises.push(p);
    });

    await Promise.all(promises);
  } catch (e) {
    console.log("Error adding members ::" + e);
    return { status: "failed", messege: e.toString() };
  }
  return { status: "success" };
});

//add field to team document
exports.updateTeam = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams");
  const teamid = data["teamid"];
  const teamdata = data["data"];

  // eslint-disable-next-line promise/no-nesting
  try {
    await teams.doc(teamid).update(teamdata);
    console.log("success: updated team info ");
    return { status: "success" };
  } catch (e) {
    console.log("could not updated team info. error: " + e);
    return { status: "failed", messege: e.toString() };
  }
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

  try {
    switch (data["operation"]) {
      case 0: //create
        console.log(data["Creating instrument"]);

        var snapshot = await instruments.get();
        snapshot.forEach((doc) => {
          //check for duplicates
          if (doc.data()["reference"] === data["instrument"]["reference"])
            //throw error message if found
            throw new functions.https.HttpsError(
              "already-exists",
              "Instrument already exists",
              "Referance code already in use"
            );
        });
        console.log(data["No duplicate found"]);

        await instruments.add(data["instrument"]);

        break;

      case 1: //update
        console.log(data["Updating instrument"]);
        if (data["instrumentId"] !== null)
          await instruments
            .doc(data["instrumentId"])
            .update(data["instrument"]);
        break;

      case 2: //delete
        break;
    }
  } catch (e) {
    console.log("Error Adding instrument :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

exports.autoEntryCollector = functions.firestore
  .document("teams/{teamId}/instances/{instanceId}/entries/{entryId}")
  .onWrite(async (change, context) => {
    const entries = admin
      .firestore()
      .collection("teams")
      .doc(context.params.teamId)
      .collection("entries");

    entries.doc(context.params.entryId).create(change.after.data());

    var log = await entries.listDocuments();
    if (log.length > 10) entries.doc(log[0].id).delete();
  });

//add instrument instance to team's inventory
exports.addInstrumentInstance = functions.https.onCall(
  async (data, context) => {
    const instruments = admin
      .firestore()
      .collection("teams")
      .doc(data["teamId"])
      .collection("instances");
    try {
      switch (data["operation"]) {
        case 0: //create
          var snapshot = await instruments.get();
          snapshot.forEach((doc) => {
            //check for duplicates
            if (
              doc.data()["serial"] === data["instrument"]["serial"] &&
              doc.data()["instrumentId"] === data["instrument"]["instrumentId"]
            )
              //throw error message if found
              throw new functions.https.HttpsError(
                "already-exists",
                "Instrument already exists",
                "Serial code already in use"
              );
          });
          var doc = await instruments.add(data["instrument"]);
          await instruments
            .doc(doc.id)
            .collection("entries")
            .add({
              type: 0,
              timestamp: Date.now(),
              details: {
                title: "Instrument Created",
                instrumentId: data["instrumentId"],
                instanceId: doc.id,
              },
            });
          break;

        case 1: //update
          await instruments.update(data["instrument"]);

          break;

        case 2: //delete
          break;
      }
    } catch (e) {
      console.log("Error Adding instrument :: " + e);
      return { status: "failed", messege: e };
    }
    return { status: "success" };
  }
);

//add part to team's inventory
exports.addPart = functions.https.onCall(async (data, context) => {
  const teamId = data["teamId"];
  const partdata = data["part"];

  const parts = admin
    .firestore()
    .collection("teams")
    .doc(teamId)
    .collection("parts");
  try {
    switch (data["operation"]) {
      case 0: //create
        var snapshot = await parts.get();
        snapshot.forEach((doc) => {
          //check for duplicates
          if (doc.data()["reference"] === data["part"]["reference"])
            //throw error message if found
            throw new functions.https.HttpsError(
              "already-exists",
              "Part already exists",
              "Referance already in use"
            );
        });

        await parts.add(partdata);
        break;

      case 1: //update
        if (data["partId"] !== null)
          await parts.doc(data["partId"]).update(partdata);
        break;

      case 2: //delete
        break;
    }

    //else
  } catch (e) {
    console.log("Error Adding Part :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

exports.transferParts = functions.https.onCall(async (data, context) => {
  const teamId = data["teamId"];
  const originId = data["origin"];
  const destinationId = data["destination"];
  const partId = data["partId"];
  const amount = data["amount"];

  const destinationParts = admin
    .firestore()
    .collection("teams")
    .doc(teamId)
    .collection("members")
    .doc(destinationId)
    .collection("inventory")
    .doc(partId);

  try {
    if (originId === null && destinationId === "storage") {
      //set storage amount (stocktaking mode)

      console.log("Setting " + amount + " unit\\s to " + destinationId);
      await destinationParts.set({
        count: amount,
      });
    } else {
      //move between inventories

      const originParts = admin
        .firestore()
        .collection("teams")
        .doc(teamId)
        .collection("members")
        .doc(originId)
        .collection("inventory")
        .doc(partId);

      originPartData = (await originParts.get()).get("count");
      destPartData = (await destinationParts.get()).exists
        ? (await destinationParts.get()).get("count")
        : 0;
      console.log(
        "moving " +
          amount +
          " unit\\s from " +
          originId +
          " (" +
          originPartData +
          ") to " +
          destinationId +
          " (" +
          destPartData +
          ")"
      );
      if (originPartData >= amount) {
        await originParts.set({ count: originPartData - amount });
        await destinationParts.set({
          count: destPartData === 0 ? amount : destPartData + amount,
        });
      } else
        throw new functions.https.HttpsError(
          "not-enough",
          "Quantity too small",
          "Not enough quantity to complete transfer"
        );
    }
  } catch (e) {
    console.log("Error Adding Part :: " + e.toString());
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

exports.addPartSerial = functions.https.onCall(async (data, context) => {
  const teamid = data["teamId"];
  const partId = data["partId"];
  const partSerial = data["partId"];

  const part = admin
    .firestore()
    .collection("teams")
    .doc(teamid)
    .collection("parts")
    .doc(partId)
    .collection("serial");
  try {
    await part.add(partSerial);
  } catch (e) {
    console.log("Error Adding Part Serial :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

//add template report fields to instrument document
exports.addInstrumentReport = functions.https.onCall(async (data, context) => {
  const instrumentreports = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("instruments")
    .doc(data["instrumentId"])
    .collection("report_templates");

  try {
    if (data["reportId"] === null)
      await instrumentreports.add({
        name: data["file"],
        fields: Object.assign({}, data["fields"]),
      });
    else
      await instrumentreports.doc(data["reportId"]).update({
        name: data["file"],
        fields: Object.assign({}, data["fields"]),
      });
  } catch (e) {
    console.log("Error Creating Report :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

exports.reserveReportId = functions.https.onCall(async (data, context) => {
  const teamRef = admin.firestore().collection("teams").doc(data["teamId"]);

  try {
    var currentIndex = (await teamRef.get()).data()["reportIndex"] + 1;
    var index = currentIndex.toString();
    while (index.length < 6) index = "0" + index; //6-digit report id
    console.log("id=" + index);
    var report = await teamRef.collection("reports").add({
      timestampOpen: data["timestampOpen"],
      name: data["name"],
      index: index,
      creatorId: data["creatorId"],
      instrumentId: data["instrumentId"],
      instanceId: data["instanceId"],
      siteId: data["siteId"],
      fields:data["fields"],
      status: "Open",
    });
  } catch (e) {
    console.log("Error Creating Report :: " + e);
    return { status: "failed", messege: e.toString() };
  }
  teamRef.update({ reportIndex: currentIndex }); //update the global index

  return { status: "success", reportId: report.id, index: index.toString() };
});

exports.addInstanceReport = functions.https.onCall(async (data, context) => {
  const reportData = data["reportData"];
  const report = reportData["report"];
  const teamRef = admin.firestore().collection("teams").doc(data["teamId"]);
  const instanceRef = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("instances")
    .doc(report["instanceId"]);

  const promises = [];
  try {
    const fields = teamRef
      .collection("reports")
      .doc(reportData["reportId"])
      .update(reportData["report"]);
    //set next maintenance date
    var oneYearFromNow = new Date();
    oneYearFromNow.setFullYear(oneYearFromNow.getFullYear() + 1);

    await instanceRef.update({ nextMaintenance: oneYearFromNow.getTime() });

    const log = instanceRef.collection("entries").add({
      type: 2,
      timestamp: Date.now(),
      details: {
        title: "Report Created " + report["index"],
        name: report["name"],
        reportid: reportData["reportId"],
        instrumentId: report["instrumentId"],
        instanceId: report["instanceId"],
        status: report["status"],
        link: reportData["reportFilePath"],
      },
    });
    promises.push(fields);

    promises.push(log);

    await Promise.all(promises);
  } catch (e) {
    console.log("Error Creating Report :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success", reportId: data["reportId"] };
});

exports.addSite = functions.https.onCall(async (data, context) => {
  const sites = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites");
  try {
    switch (data["operation"]) {
      case 0: //create
        await sites.add(data["site"]);
        break;

      case 1: //update
        if (data["siteId"] !== null)
          sites.doc(data["siteId"]).update(data["site"]);
        break;

      case 2: //delete
        break;
    }
    //
    //await sites.update(data["site"]);
  } catch (e) {
    return { status: "failed", messege: e.toString() };
  }
  return { status: "success" };
});

exports.addRoom = functions.https.onCall((data, context) => {
  const sites = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites")
    .doc(data["siteId"])
    .collection("rooms");

  return sites.add(data["room"]);
});

exports.linkInstruments = functions.https.onCall(async (data, context) => {
  const room = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites")
    .doc(data["siteId"])
    .collection("rooms")
    .doc(data["roomId"])
    .collection("assigned");

  try {
    const promises = [];
    const instruments = data["instruments"];

    instruments.forEach((instrument) => {
      console.log(instrument);
      const instanceRef = admin
        .firestore()
        .collection("teams")
        .doc(data["teamId"])
        .collection("instances")
        .doc(instrument["instanceId"]);

      const update = instanceRef.update({
        currentSiteId: data["siteId"],
        currentRoomId: data["roomId"],
      });
      const insert = room.add(instrument);

      const log = instanceRef.collection("entries").add({
        type: 1,
        timestamp: Date.now(),
        details: {
          title: "Intrument Moved",
          instrumentId: instrument.instrumentId,
          instanceId: instrument.instanceId,
        },
      });
      promises.push(update);
      promises.push(insert);
      promises.push(log);
    });
    await Promise.all(promises);
  } catch (e) {
    console.log("Error relocating instrument :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

//case user exited from

exports.autoInstanceOnUpdate = functions.firestore
  .document("teams/{teamId}/instruments/{instrumentId}/instances/{instanceId}")
  //remove from old location on update
  .onUpdate((change, context) => {
    var deviceBefore = change.before.data();
    var deviceAfter = change.after.data();

    if (deviceBefore["currentSiteId"] === "Main") return null;

    console.log(
      deviceBefore["instrumentCode"] +
        " : " +
        deviceBefore["serial"] +
        " moved from " +
        deviceBefore["currentSiteId"] +
        ", room:" +
        deviceBefore["currentRoomId"] +
        " to " +
        deviceAfter["currentSiteId"] +
        ", room:" +
        deviceAfter["currentRoomId"]
    );

    var assigned = admin
      .firestore()
      .collection("teams")
      .doc(context.params.teamId)
      .collection("sites")
      .doc(deviceBefore["currentSiteId"])
      .collection("rooms")
      .doc(deviceBefore["currentRoomId"])
      .collection("assigned");

    var docs = assigned.get().then((val) => {
      val.docs.forEach((doc) => {
        if (
          doc.data()["instanceSerial"] === deviceBefore["serial"] &&
          doc.data()["instrumentCode"] === deviceBefore["instrumentCode"]
        ) {
          assigned.doc(doc.id).delete();
        }
      });
      return { status: "success" };
    });
    return { status: "success" };
  });

exports.addContact = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams").doc(data["teamId"]); //setting referance

  try {
    var contact = await teams.collection("contacts").add(data["contact"]);
    console.log("New Contact ID : " + contact.id);

    var siteId = data["siteId"];
    if (siteId !== null) {
      teams
        .collection("sites")
        .doc(data["siteId"])
        .collection("contact")
        .doc(contact.id)
        .set({});
    }
  } catch (e) {
    console.log("Error adding contact :: " + e);
    return { status: "failed", messege: e.toString() };
  }
  return { status: "success" };
});

exports.updateContact = functions.https.onCall(async (data, context) => {
  const teams = admin.firestore().collection("teams").doc(data["teamId"]); //setting referance
  try {
    await teams.collection("contacts").update(data["contact"]);
  } catch (e) {
    return { status: "failed", messege: e.toString() };
  }

  return { status: "success" };
});

exports.linkContacts = functions.https.onCall(async (data, context) => {
  const contactRef = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites")
    .doc(data["siteId"])
    .collection("rooms")
    .doc(data["roomId"])
    .collection("contacts");

  try {
    const promises = [];
    const contacts = data["contacts"];
    contacts.forEach((contact) => {
      const p = contactRef.doc(contact.contactId).set({});
      promises.push(p);
    });
    await Promise.all(promises);
  } catch (e) {
    console.log("Error assigning contact :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

exports.unlinkContacts = functions.https.onCall(async (data, context) => {
  const contactRef = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("sites")
    .doc(data["siteId"])
    .collection("rooms")
    .doc(data["roomId"])
    .collection("contacts");

  try {
    const promises = [];
    const contacts = data["contacts"];

    contacts.forEach((contact) => {
      const p = contactRef.doc(contact.contactId).delete();
      promises.push(p);
    });

    await Promise.all(promises);
  } catch (e) {
    console.log("Error assigning contact :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});
