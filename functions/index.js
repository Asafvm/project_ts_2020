const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const spawn = require("child-process-promise").spawn;
const path = require("path");
const os = require("os");
const fs = require("fs");

//const gcs = require("@google-cloud/storage")();
//admin.initializeApp(functions.config().firebase);

const fileBucket = object.bucket; // The Storage bucket that contains the file.
const filePath = object.name; // File path in the bucket.
const contentType = object.contentType; // File content type.
const metageneration = object.metageneration; // Number of times metadata has been generated. New objects have a value of 1.

exports.uploadFile = functions.storage.object().onFinalize(async (object) => {
  // [END generateThumbnailTrigger]
  // [START eventAttributes]
  const fileBucket = object.bucket; // The Storage bucket that contains the file.
  const filePath = object.name; // File path in the bucket.
  const contentType = object.contentType; // File content type.
  const metageneration = object.metageneration; // Number of times metadata has been generated. New objects have a value of 1.
  // [END eventAttributes]

  // [START stopConditions]
  // Exit if this is triggered on a file that is not an image.
  if (!contentType.startsWith("image/")) {
    return console.log("This is not an image.");
  }

  // Get the file name.
  const fileName = path.basename(filePath);
  // Exit if the image is already a thumbnail.
  if (fileName.startsWith("thumb_")) {
    return console.log("Already a Thumbnail.");
  }
  // [END stopConditions]

  // [START thumbnailGeneration]
  // Download file from bucket.
  const bucket = admin.storage().bucket(fileBucket);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const metadata = {
    contentType: contentType,
  };

  // We add a 'thumb_' prefix to thumbnails file name. That's where we'll upload the thumbnail.
  const thumbFileName = `thumb_${fileName}`;
  const thumbFilePath = path.join(path.dirname(filePath), thumbFileName);
  // Uploading the thumbnail.
  await bucket.upload(tempFilePath, {
    destination: thumbFilePath,
    metadata: metadata,
  });

  // [END thumbnailGeneration]
});
// [END uploadFile]

exports.downloadFile = functions.storage.object().onFinalize(async (object) => {
  // [END generateThumbnailTrigger]
  // [START eventAttributes]
  const fileBucket = object.bucket; // The Storage bucket that contains the file.
  const filePath = object.name; // File path in the bucket.
  const contentType = object.contentType; // File content type.
  const metageneration = object.metageneration; // Number of times metadata has been generated. New objects have a value of 1.
  // [END eventAttributes]

  // [START stopConditions]
  // Exit if this is triggered on a file that is not an image.
  if (!contentType.startsWith("image/")) {
    return console.log("This is not an image.");
  }

  // Get the file name.
  const fileName = path.basename(filePath);
  // Exit if the image is already a thumbnail.
  if (fileName.startsWith("thumb_")) {
    return console.log("Already a Thumbnail.");
  }
  // [END stopConditions]

  // [START thumbnailGeneration]
  // Download file from bucket.
  const bucket = admin.storage().bucket(fileBucket);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const metadata = {
    contentType: contentType,
  };
  await bucket.file(filePath).download({ destination: tempFilePath });
  console.log("Image downloaded locally to", tempFilePath);
  // Generate a thumbnail using ImageMagick.
  await spawn("convert", [
    tempFilePath,
    "-thumbnail",
    "200x200>",
    tempFilePath,
  ]);
  console.log("Thumbnail created at", tempFilePath);
});
// [END downloadFile]
exports.addDevice = functions.https.onCall((data, context) => {
  const devices = admin.firestore().collection("test");

  return new Promise((resolve, reject) => {
    return devices
      .add({
        manifacturer: data["manifacturer"],
        codeName: data["codeName"],
        codeNumber: data["codeNumber"],
        model: data["model"],
        price: data["price"],
      })
      .then((msg) => {
        return resolve({
          success: true,
        });
      })
      .catch(reject);
  });
});
