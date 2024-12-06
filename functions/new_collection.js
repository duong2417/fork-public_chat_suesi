/* eslint-disable max-len */
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const v2 = require("firebase-functions/v2");
const vertexAIApi = require("@google-cloud/vertexai");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const project = "flutter-dev-search";
const location = "us-central1";
const textModel = "gemini-1.5-flash";
// const visionModel = "gemini-1.0-pro-vision";
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();
const vertexAI = new vertexAIApi.VertexAI({project: project, location: location});

// const generativeVisionModel = vertexAI.getGenerativeModel({
//   model: visionModel,
// });

const generativeModelPreview = vertexAI.preview.getGenerativeModel({
  model: textModel,
});

const generationConfig = {
  temperature: 1,
  topP: 0.95,
  topK: 64,
  maxOutputTokens: 8192,
  responseMimeType: "text/plain",
};

// use onDocumentWritten here to prepare to "edit message" feature later
exports.onChatWritten = v2.firestore.onDocumentWritten("/public/{messageId}", async (event) => {
  const document = event.data.after.data();
  let message = document["message"];
  const role = document["role"];
  const time = document["new_time"];
  console.log(`time: ${time}`);
  console.log(`message: ${message}`);

  // no message? do nothing
  if (message == undefined) {
    return;
  }
  if (role == "user" && message.includes("@bot")) {
    message = message.replace("@bot", "");
    const chatSession = generativeModelPreview.startChat({
      generationConfig: generationConfig,
    });
    const result = await chatSession.sendMessageStream(message);
    // Process streaming response and write each chunk to Firestore
    let chunkIndex = 0;
    // let textTotal = "";
    for await (const chunk of result.stream) {
      const text = chunk.candidates[0].content.parts[0].text;
      //   textTotal += text;
      ++chunkIndex;
      const chunkData = {
        "index": chunkIndex,
        "text": text,
      };
      await db.collection("new").doc(`chunk_${chunkIndex}`).set(chunkData);
      console.log(`${chunkIndex}:`, text);
    }
    // newMessage.set({"message": textTotal}, {merge: true});
  }
  // write to message
  // const data = event.data.after.data();
  // return event.data.after.ref.set({
  //     'translated': {
  //         'original':message,
  //         'en': translated.en
  //     }
  // }, {merge: true});
});
