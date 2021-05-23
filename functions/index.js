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

    const promises = [];
    members.forEach((member) => {
      const p = teams.doc(teamid.id).collection("members").doc(member).set({});

      promises.push(p);
    });
    await Promise.all(promises);
  } catch (e) {
    console.log("Error adding members ::" + e);
    return { status: "failed", messege: e.toString() };
  }

  return { status: "success", teamId: teamid.id };
});

//add team member
exports.addTeamMember = functions.https.onCall(async (data, context) => {
  const teams = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("members"); //setting referance

  try {
    const members = data["members"];

    const promises = [];
    members.forEach((member) => {
      const p = teams.doc(member).set({});

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
          if (doc.id === data["instrument"]["codeName"])
            //throw error message if found
            throw new functions.https.HttpsError(
              "already-exists",
              "Instrument already exists",
              "Referance code already in use"
            );
        });
        console.log(data["No duplicate found"]);

        await instruments
          .doc(data["instrument"]["codeName"])
          .set(data["instrument"]);

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
  .document(
    "teams/{teamId}/instruments/{instrumentId}/instances/{instanceId}/entries/{entryId}"
  )
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
      .collection("instruments")
      .doc(data["instrumentId"])
      .collection("instances")
      .doc(data["instrument"]["serial"]);

    try {
      switch (data["operation"]) {
        case 0: //create
          await instruments.create(data["instrument"]);
          await instruments.collection("entries").add({
            type: 0,
            timestamp: Date.now(),
            details: {
              title: "Instrument Created",
              instrumentId: data["instrumentId"],
              instanceId: data["instrument"]["serial"],
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

  const originParts = admin
    .firestore()
    .collection("teams")
    .doc(teamId)
    .collection("members")
    .doc(originId)
    .collection("inventory")
    .doc(partId);

  const destinationParts = admin
    .firestore()
    .collection("teams")
    .doc(teamId)
    .collection("members")
    .doc(destinationId)
    .collection("inventory")
    .doc(partId);

  try {
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
      //var destCount =
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
    .collection("reports")
    .doc(data["file"]);
  try {
    await instrumentreports.set(Object.assign({}, data["fields"]));
  } catch (e) {
    console.log("Error Creating Report :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success" };
});

exports.addInstanceReport = functions.https.onCall(async (data, context) => {
  const instanceRef = admin
    .firestore()
    .collection("teams")
    .doc(data["teamId"])
    .collection("instruments")
    .doc(data["instrumentId"])
    .collection("instances")
    .doc(data["instanceId"]);

  const promises = [];
  try {
    var reportid = (
      (await instanceRef.collection("reports").get()).docs.length + 1
    ).toString();
    while (reportid.length < 6) reportid = "0" + reportid; //6-digit report id
    console.log("id=" + reportid);
    const fields = instanceRef
      .collection("reports")
      .add({
        timestamp: Date.now(),
        reportName: data["reportName"],
        reportid: reportid,
        fields: Object.assign({}, data["fields"]),
      });

    const log = instanceRef.collection("entries").add({
      type: 2,
      timestamp: Date.now(),
      details: {
        title: "Report Created",
        reportName: data["reportName"],
        reportid: reportid,
        instrumentId: data["instrumentId"],
        instanceId: data["instanceId"],
      },
    });

    promises.push(fields);
    promises.push(log);

    await Promise.all(promises);
  } catch (e) {
    console.log("Error Creating Report :: " + e);
    return { status: "failed", messege: e };
  }
  return { status: "success", reportId: reportid };

  // return instrumentreports.set(
  //   Object.assign({}, data["fields"]) //map every list item to index number
  // );
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
      const instanceRef = admin
        .firestore()
        .collection("teams")
        .doc(data["teamId"])
        .collection("instruments")
        .doc(instrument.instrumentCode)
        .collection("instances")
        .doc(instrument.instanceSerial);

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
          instrumentId: data["instrumentId"],
          instanceId: data["instanceId"],
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
