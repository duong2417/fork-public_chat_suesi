/* eslint-disable comma-spacing */
/* eslint-disable object-curly-spacing */
/* eslint-disable require-jsdoc */
/* eslint-disable no-trailing-spaces */
/* eslint-disable comma-dangle */
/* eslint-disable key-spacing */
/* eslint-disable quotes */
/* eslint-disable indent */
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
const admin = require("firebase-admin");

admin.initializeApp();
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const project = 'flutter-dev-search';
const location = 'us-central1';
const textModel = 'gemini-1.5-flash';
// const visionModel = 'gemini-1.0-pro-vision';
async function saveNewLanguageCode(languagesCollection, detectedLanguage, languages) {
    console.log('saveNewLanguageCode', languagesCollection, detectedLanguage, languages);
    if (detectedLanguage && !languages.includes(detectedLanguage)) {
      console.log(`Adding new language code: ${detectedLanguage}`);
      try {
        await languagesCollection.add({ code: detectedLanguage });
        console.log("Successfully added new language code to database");
        return true;
      } catch (error) {
        console.error("Error adding new language code to database:", error);
        return false;
      }
    }
    return false;
  }
const vertexAI = new vertexAIApi.VertexAI({project: project, location: location});

// const generativeVisionModel = vertexAI.getGenerativeModel({
//     model: visionModel,
// });

const generativeModelPreview = vertexAI.preview.getGenerativeModel({
    model: textModel,
});

// Tách thành 2 cấu hình riêng biệt
const functionConfig = {
    temperature: 1,
    topP: 0.95,
    topK: 64,
    maxOutputTokens: 8192,
};

// const translationConfig = {
//     temperature: 1,
//     topP: 0.95,
//     topK: 64,
//     maxOutputTokens: 8192,
//     responseMimeType: "application/json",
//     responseSchema: {
//       type: "object",
//       properties: {
//         en: {
//           type: "string"
//         }
//       },
//       required: [
//         "en"
//       ]
//     }
// };

const tools = [{
  functionDeclarations: [{
    name: "saveNewLanguageCode",
    description: "Save a new detected language code to the database if it doesn't exist",
    parameters: {
      type: "object",
      properties: {
        detectedLanguage: {
          type: "string",
          description: "The ISO 639-1 language code that was detected"
        }
      },
      required: ["detectedLanguage"]
    }
  }]
}];

// use onDocumentWritten here to prepare to "edit message" feature later
exports.onChatWritten = v2.firestore.onDocumentWritten("/public/{messageId}",async (event) => {
    const document = event.data.after.data();
    const message = document["message"];
    console.log(`message: ${message}`);

    // no message? do nothing
    if (message == undefined) {
        return;
    }
    const curTranslated = document["translated"];

    // check if message is translated
    if (curTranslated != undefined) {
        // message is translated before, 
        // check the original message
        const original = curTranslated["original"];

        console.log('Original: ', original);
        // message is same as original, meaning it's already translated. Do nothing
        if (message == original) {
            return;
        }
    }
    // Get list of languages from Firestore
  const db = admin.firestore();
  const languagesCollection = db.collection("languages");
  const languagesSnapshot = await languagesCollection.get();
  const languages = languagesSnapshot.docs.map((e) => e.data().code);

  console.log("Current languages in database:", languages);

    // Get reference to languages collection
    // const languagesCollection = event.data.after.ref.parent.parent
    //   .collection("languages");
    
    // // Get existing languages
    // const languagesSnapshot = await languagesCollection.get();
    // const languages = languagesSnapshot.docs.map((doc) => doc.data().code);

    // Chat session cho function calling
    const functionSession = generativeModelPreview.startChat({
        generationConfig: functionConfig,
        tools: tools,
        toolConfig: {
            functionCallConfig: {
                mode: "ANY"
            }
        }
    });

    // First, detect the language
    const detectResult = await functionSession.sendMessage(
      `Detect the language of this text and return only the ISO 639-1 language code using the saveNewLanguageCode function: "${message}"`
    );

    // Handle function call if present
    const functionCall = detectResult.response.candidates[0].content.parts[0].functionCall;
    if (functionCall && functionCall.name === "saveNewLanguageCode") {
      const args = functionCall.args;
      await saveNewLanguageCode(languagesCollection, args.detectedLanguage, languages);
    }

    // Chat session mới cho việc dịch
    // const translationSession = generativeModelPreview.startChat({
    //     generationConfig: translationConfig
    // });

    // // Continue with translation...
    // const result = await translationSession.sendMessage(`translate this text to English: ${message}`);
    // const response = result.response;
    // console.log('Response:', JSON.stringify(response));

    // const jsonTranslated = response.candidates[0].content.parts[0].text;
    // console.log('translated json: ', jsonTranslated);
    // // parse this json to get translated text out
    // const translated = JSON.parse(jsonTranslated);
    // console.log('final result: ', translated.en);

    return event.data.after.ref.set({
        'translated': {
            'original':message,
            // 'en': translated.en
        }
    }, {merge: true});
});
