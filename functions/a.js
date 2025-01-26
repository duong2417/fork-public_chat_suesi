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

const v2 = require("firebase-functions/v2");
const vertexAIApi = require("@google-cloud/vertexai");
const admin = require("firebase-admin");

admin.initializeApp();

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
const vertexAI = new vertexAIApi.VertexAI({ project: project, location: location });

// const generativeVisionModel = vertexAI.getGenerativeModel({
//     model: visionModel,
// });

const generativeModelPreview = vertexAI.preview.getGenerativeModel({
  model: textModel,
});

// use onDocumentWritten here to prepare to "edit message" feature later
exports.onChatWritten = v2.firestore.onDocumentWritten("/public/{messageId}", async (event) => {
  // Get list of languages from Firestore
  const db = admin.firestore();
  const languagesCollection = db.collection("languages");
  const languagesSnapshot = await languagesCollection.get();
  const languages = languagesSnapshot.docs.map((e) => e.data().code);
  console.log("Current languages in database:", languages);

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
  // const tools = [
  //   {
  //     functionDeclarations: [
  //       {
  //         name: "saveNewLanguageCode",
  //         description: "Save a new detected language code to the database if it doesn't exist",
  //         parameters: {
  //           type: "object",
  //           properties: {
  //             detectedLanguage: {
  //               type: "string",
  //               description: "The ISO 639-1 language code that was detected",
  //               pattern: "^[a-z]{2}$" // Thêm pattern để đảm bảo format ISO 639-1
  //             }
  //           },
  //           required: ["detectedLanguage"]
  //         }
  //       },
  //     ]
  //   }];
  const generationConfig = {
    temperature: 1,
    topP: 0.95,
    topK: 64,
    maxOutputTokens: 8192,
    responseMimeType: "application/json",
    responseSchema: {
      type: "object",
      properties:
      {
        "detectedLanguage": {
          type: "string",
          description: "The ISO 639-1 language code that was detected",
          pattern: "^[a-z]{2}$"
        },
        "translation": languages.reduce((acc, lang) => {
          acc[lang] = { type: "string" };
          return acc;
        }, {}),
      },
      required: ["detectedLanguage", "translation"]
    },
  };
  const translateSession = generativeModelPreview.startChat({
    generateContentConfig: generationConfig,
    // tools: tools,
    // toolConfig: {
    //   functionCallingConfig:{
    //     mode: "ANY"
    //   }
    // }
  });

  const result = await translateSession.sendMessage(`
    The target languages: ${languages.join(", ")}.
    The input text: "${message}". You must do:
        1. If the target languages are not empty, translate the input text to target languages, else if the target languages are empty, return null as value of "translation" field.
        2. detect language of the input text.
        Example: Translate "Chào" to ["ja", "en"]:
        {
          "detectedLanguage": "vi",
          "translation": {"ja": "こんにちは", "en": "Hello"},
        }
        `
  );

  const response = result.response;
  console.log('Response:', JSON.stringify(response));

  const responseContent = response.candidates[0].content;
  let translationData = null;
  let detectedLanguage = null;

  if (responseContent.parts && responseContent.parts[0].text) {
    try {
      // Trích xuất JSON từ phần text (bỏ qua các ký tự markdown ```)
      const jsonText = responseContent.parts[0].text.replace(/```json\n|\n```/g, '');
      translationData = JSON.parse(jsonText);
      detectedLanguage = translationData.detectedLanguage;
      console.log('Detected language:', detectedLanguage);
      console.log('Translation data:', translationData.translation);
    } catch (error) {
      console.error('Error parsing translation response:', error);
    }
  }

  console.log('Translation data:', translationData);

  // Lưu ngôn ngữ mới nếu được phát hiện
  if (detectedLanguage) {
    await saveNewLanguageCode(languagesCollection, detectedLanguage, languages);
  }

  // Cập nhật document với bản dịch
  return event.data.after.ref.set({
    'translated': {
      'original': message,
      ...translationData.translation
    }
  }, { merge: true });
});
