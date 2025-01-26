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
    
const generationConfig = {
  temperature: 1,
  topP: 0.95,
  topK: 64,
  maxOutputTokens: 8192,
  // responseSchema: {
  //   type: "object",
  //   properties: languages.reduce((acc, lang) => {
  //     acc[lang] = { type: "string" };
  //     return acc;
  //   }, {}),
  //   required: languages
  // },
};
  // const translateConfig = {
  //   name: "translate",
  //   description: "Translate the message to target languages",
  //   parameters: {
  //     type: "object",
  //     properties: languages.reduce((acc, lang) => {
  //       acc[lang] = { type: "string" };
  //       return acc;
  //     }, {}),
  //     required: languages
  //   }
  // };
  const tools = [
    {
      functionDeclarations: [
        // translateConfig,
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
      ]
    }];

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

  const chatSession = generativeModelPreview.startChat({
    generationConfig: generationConfig,
    tools: tools,
    toolConfig: {
      functionCallConfig: {
        mode: "ANY"
      }
    }
  });

  // Sửa đổi prompt để yêu cầu phản hồi rõ ràng hơn
  const result = await chatSession.sendMessage(`
    Analyze this message: "${message}"
    
    Please respond in this format:
    1. Explanation of the detected language
    2. English translation
    3. Call saveNewLanguageCode function if needed
    
    Example response:
    "I detected that this message is in Vietnamese.
    English translation: Hello, how are you?
    [Then make function call if needed]"
    `);

  const response = result.response;
  console.log('Response:', JSON.stringify(response));

  // Xử lý phản hồi
  const responseContent = response.candidates[0].content;
  let detectedLanguage = null;

  // Xử lý text từ phản hồi
  if (responseContent.parts) {
    for (const part of responseContent.parts) {
      if (part.text) {
        console.log('Explanation and translation:', part.text);
      }
      if (part.functionCall) {
        const { name, args } = part.functionCall;
        if (name === 'saveNewLanguageCode') {
          detectedLanguage = args.detectedLanguage;
          console.log('Detected language:', detectedLanguage);
        }
      }
    }
  }

  // Lưu ngôn ngữ mới nếu được phát hiện
  if (detectedLanguage) {
    await saveNewLanguageCode(languagesCollection, detectedLanguage, languages);
  }

  // Cập nhật document với bản dịch
  const translationMatch = responseContent.parts.find(part => part.text)?.text.match(/English translation:(.*?)($|\[)/s);
  const englishTranslation = translationMatch ? translationMatch[1].trim() : message;

  return event.data.after.ref.set({
    'translated': {
      'original': message,
      'en': englishTranslation
    }
  }, { merge: true });
});
