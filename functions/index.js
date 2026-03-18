const {setGlobalOptions} = require("firebase-functions");
const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

setGlobalOptions({maxInstances: 10});

admin.initializeApp();
const db = admin.firestore();

function hasValidBootstrapKey(request) {
	const expectedKey = process.env.BOOTSTRAP_KEY;
	const providedKey = request.get("x-bootstrap-key");
	return Boolean(expectedKey) && providedKey === expectedKey;
}

exports.bootstrapFirestoreCollections = onRequest(async (request, response) => {
	if (request.method !== "POST") {
		response.status(405).json({ok: false, error: "Use POST"});
		return;
	}

	if (!hasValidBootstrapKey(request)) {
		response.status(403).json({ok: false, error: "Invalid bootstrap key"});
		return;
	}

	try {
		const now = admin.firestore.FieldValue.serverTimestamp();
		const batch = db.batch();

		batch.set(db.collection("users").doc("__seed__"), {
			name: "Seed User",
			email: "seed@riverflow.local",
			role: "user",
			createdAt: now,
			seeded: true,
		}, {merge: true});

		batch.set(db.collection("river_data").doc("__seed__"), {
			waterLevel: 0,
			percentage: 0,
			alertLevel: "safe",
			riseRatePerHour: 0,
			sensorOnline: true,
			timestamp: now,
			seeded: true,
		}, {merge: true});

		batch.set(db.collection("messages").doc("__seed__"), {
			message: "Seed broadcast message",
			sender: "system",
			severity: "info",
			timestamp: now,
			seeded: true,
		}, {merge: true});

		batch.set(db.collection("notification_tokens").doc("__seed__"), {
			tokens: [],
			updatedAt: now,
			seeded: true,
		}, {merge: true});

		await batch.commit();

		response.status(200).json({
			ok: true,
			collections: ["users", "river_data", "messages", "notification_tokens"],
		});
	} catch (error) {
		logger.error("bootstrapFirestoreCollections failed", error);
		response.status(500).json({ok: false, error: "Bootstrap failed"});
	}
});

exports.bootstrapSetInitialAdmin = onRequest(async (request, response) => {
	if (request.method !== "POST") {
		response.status(405).json({ok: false, error: "Use POST"});
		return;
	}

	if (!hasValidBootstrapKey(request)) {
		response.status(403).json({ok: false, error: "Invalid bootstrap key"});
		return;
	}

	const uid = request.body?.uid;
	if (typeof uid !== "string" || uid.length === 0) {
		response.status(400).json({ok: false, error: "uid is required"});
		return;
	}

	try {
		const user = await admin.auth().getUser(uid);
		const claims = user.customClaims || {};
		claims.admin = true;

		await admin.auth().setCustomUserClaims(uid, claims);
		await db.collection("users").doc(uid).set({
			role: "admin",
			updatedAt: admin.firestore.FieldValue.serverTimestamp(),
		}, {merge: true});

		response.status(200).json({ok: true, uid, admin: true});
	} catch (error) {
		logger.error("bootstrapSetInitialAdmin failed", error);
		response.status(500).json({ok: false, error: "Failed to set admin claim"});
	}
});

exports.setAdminClaim = onCall(async (request) => {
	if (request.auth == null || request.auth.token.admin !== true) {
		throw new HttpsError("permission-denied", "Admin only operation");
	}

	const uid = request.data?.uid;
	const isAdmin = request.data?.isAdmin === true;

	if (typeof uid !== "string" || uid.length === 0) {
		throw new HttpsError("invalid-argument", "uid is required");
	}

	const user = await admin.auth().getUser(uid);
	const claims = user.customClaims || {};

	if (isAdmin) {
		claims.admin = true;
	} else {
		delete claims.admin;
	}

	await admin.auth().setCustomUserClaims(uid, claims);

	await db.collection("users").doc(uid).set({
		role: isAdmin ? "admin" : "user",
		updatedAt: admin.firestore.FieldValue.serverTimestamp(),
	}, {merge: true});

	return {ok: true, uid, isAdmin};
});
