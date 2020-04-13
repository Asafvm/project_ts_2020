const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.addDevice = functions.https.onCall((data, context) => {
	const devices = admin.firestore().collection("test");

	return new Promise((resolve, reject) => {
		return devices
			.add({
				manifacturer: data["manifacturer"],
				codeName: data["codeName"],
				codeNumber: data["codeNumber"],
				model: data["model"],
				price: data["price"]
			})
			.then(msg => {
				return resolve({
					success: true
				});
			})
			.catch(reject);
	});
});
