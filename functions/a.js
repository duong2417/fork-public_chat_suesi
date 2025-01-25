/* eslint-disable spaced-comment */
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
// const functionConfig = {
//     temperature: 1,
//     topP: 0.95,
//     topK: 64,
//     maxOutputTokens: 8192,
//     responseMimeType: "application/json",
//     responseSchema: {
//       type: "object",
//       properties: {
//         translation: {
//           type: "string",
//           description: "English translation of the input text"
//         }
//       },
//       required: ["translation"]
//     }
// };
const functionConfig = {
    temperature: 1,
    topP: 0.95,
    topK: 64,
    maxOutputTokens: 8192,
};

const tools = [
    {
  functionDeclarations: [
    {
    name: "saveNewLanguageCode",
    description: "Save a new detected language code to the database if it doesn't exist",
    parameters: {
      type: "object",
      properties: {
        detectedLanguage: {
          type: "string",
          description: "The ISO 639-1 language code that was detected",
        pattern: "^[a-z]{2}$" // Thêm pattern để đảm bảo format ISO 639-1
        }
      },
      required: ["detectedLanguage"]
    }
  },
 {
      name: "translateText",
      description: "Translate the text to English",
      parameters: {
        type: "object",
        properties: {
          translatedText: {
            type: "string",
            description: "The translated text"
          }
        },
        required: ["translatedText"]
      }
    },
    ]
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

    // Chat session cho cả hai nhiệm vụ
    const chatSession = generativeModelPreview.startChat({
        generationConfig: functionConfig,
        tools: tools,
        toolConfig: {
            functionCallConfig: {
                mode: "ANY"
            }
        }
    });

    // Gửi một prompt duy nhất để thực hiện cả hai nhiệm vụ
    const result = await chatSession.sendMessage(
      `Please perform two tasks:
      1. Translate this text to English and return the translation in JSON format that the language code as key and the translated text as value: "${message}"
      2. detect language of the text and call saveNewLanguageCode function with the ISO 639-1 language code.
   Example response:
   {
    "en": "Hello, how are you?",
    "vi": "Xin chào, bạn thế nào?"
   }`
    );

    const response = result.response;
    console.log('Response:', JSON.stringify(response));

    // Xử lý function call nếu có
    const functionCall = response.candidates[0].content.parts.find((part) => part.functionCall);
    if (functionCall) {
        const args = functionCall.functionCall.args;
        await saveNewLanguageCode(languagesCollection, args.detectedLanguage, languages);
    }

    // Lấy bản dịch từ phản hồi JSON
    const translatedPart = response.candidates[0].content.parts.find((part) => part.text);
    let translatedText = '';
    if (translatedPart) {
        const jsonResponse = JSON.parse(translatedPart.text);
        translatedText = jsonResponse.translation;
    }

    return event.data.after.ref.set({
        'translated': {
            'original': message,
            'en': translatedText
        }
    }, {merge: true});
});
