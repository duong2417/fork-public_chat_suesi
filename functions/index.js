/* eslint-disable comma-spacing */
/* eslint-disable require-jsdoc */
/* eslint-disable spaced-comment */
/* eslint-disable eol-last */
/* eslint-disable operator-linebreak */
/* eslint-disable key-spacing */
/* eslint-disable quotes */
/* eslint-disable no-trailing-spaces */
/* eslint-disable comma-dangle */
/* eslint-disable object-curly-spacing */
/* eslint-disable indent */
/* eslint-disable max-len */
const v2 = require("firebase-functions/v2");
const vertexAIApi = require("@google-cloud/vertexai");
const admin = require("firebase-admin");

admin.initializeApp();

const project = "flutter-dev-search";
const location = "us-central1";
const textModel = "gemini-1.5-flash";
// const visionModel = "gemini-1.0-pro-vision";

const vertexAI = new vertexAIApi.VertexAI({ project: project, location: location });

// Định nghĩa function declaration cho language detection
const languageDetectionFunction = {
  name: "save_new_language",
  description: "Save language code to Firestore if it does not exist in the list of languages",
  parameters: {
    type: "object",
    properties: {
      detectedLanguage: {
        type: "string",
        description: "the language code of the message that Gemini detected",
        pattern: "^[a-z]{2}$" // Thêm pattern để đảm bảo format ISO 639-1
      }
    },
    required: ["detectedLanguage"]
  }
};

// const translationFunction = {
//   name: "process_translations",
//   description: "Process translations of the message to all target languages",
//   parameters: {
//     type: "object",
//     properties: {
//       translations: {
//         type: "array",
//         description: "Translations of the message to all existing languages",
//         items: {
//           type: "object",
//           properties: {
//             translation: { type: "string" },
//             code: { type: "string" }
//           }
//         }
//       }
//     },
//     required: ["translations"]
//   }
// };
// const generationConfig = {
//   temperature: 1,
//   topP: 0.95,
//   topK: 64,
//   maxOutputTokens: 8192,
//   responseMimeType: "application/json",
//   responseSchema: {
//     type: "array",
//     items: {
//       type: "object",
//       properties: {
//         translation: {
//           type: "string",
//         },
//         code: {
//           type: "string",
//         },
//       },
//       required: ["translation", "code"],
//     },
//   },
// };

const generativeModelPreview = vertexAI.preview.getGenerativeModel({
  model: textModel,
});

// Chuyển hàm saveNewLanguageCode thành async function để xử lý function calling
async function saveNewLanguageCode(languagesCollection, detectedLanguage, languages) {
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

// trigger when the chat data on public collection change to translate the message
exports.onChatWritten = v2.firestore.onDocumentWritten("/public/{messageId}", async (event) => {
  const document = event.data.after.data();
  const message = document["message"];
  const original = document["original"];
  const translations = document["translations"];

  console.log(`Processing message: ${message}`);
  console.log(`Original: ${original}`);
  console.log(`Has translations: ${translations != null}`);

  // 1. Check conditions to skip
  if (!message || message.trim() === '') {
    console.log("Message is empty, skipping");
    return;
  }

  // 2. Skip if this message is the original
  if (message === original) {
    console.log("This is an original message that was already processed, skipping");
    return;
  }

  // Get list of languages from Firestore
  const db = admin.firestore();
  const languagesCollection = db.collection("languages");
  const languagesSnapshot = await languagesCollection.get();
  const languages = languagesSnapshot.docs.map((e) => e.data().code);

  console.log("Current languages in database:", languages);

  // const chatSession = generativeModelPreview.startChat({
  //   //use toolConfig instead of generationConfig to use function calling
  //   toolConfig: {
  //     functionDeclarations: [{
  //       name: "processMessage",
  //       description: "Process message language and translations",
  //       parameters: {
  //         type: "object",
  //         properties: {
  //           detectedLanguage: {
  //             type: "string",
  //             description: "ISO 639-1 language code of the detected language",
  //             pattern: "^[a-z]{2}$"
  //           },
  //           translations: {
  //             type: "array",
  //             description: "Translations of the message to all existing languages",
  //             items: {
  //               type: "object",
  //               properties: {
  //                 translation: { type: "string" },
  //                 code: { type: "string" }
  //               }
  //             }
  //           }
  //         },
  //         required: ["detectedLanguage", "translations"]
  //       }
  //     }],
  //     functionCallMode: "REQUIRED"// để cho phép model tự do gọi function
  //   }
  // });

  let translated = [];
  try {
    const chatSession = generativeModelPreview.startChat({
      toolConfig: {
        functionDeclarations: [languageDetectionFunction],
        functionCallMode: "REQUIRED" // Thay đổi từ ANY thành REQUIRED
      }
    });
    
    const result = await chatSession.sendMessage(`
      Target languages: [${languages.join(',')}]
      The message: ${message}
      You have 2 tasks:
      1. If the target languages not empty, translate the message to the target languages.
      2. Detect the language of the message and return the functionCall that I configured for you.      `);
    
    // Log toàn bộ cấu trúc response để debug
    const fullResponse = JSON.stringify(result.response, null, 2);
    console.log("Full response structure:", fullResponse);

    // Parse response
    const responseText = result.response.candidates[0].content.parts[0].text;
    console.log("Raw response text:", responseText);
    
    try {
      // Tìm và trích xuất phần JSON từ responseText
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error("Không tìm thấy JSON trong phản hồi");
      }
      
      const parsedResponse = JSON.parse(jsonMatch[0]);
      console.log("Parsed response:", parsedResponse);

      // Xử lý dữ liệu đã parse
      const detectedLanguage = parsedResponse.language_detection.detected_language;
      translated = parsedResponse.translation || [];
      
      console.log(`Translations:`, translated);
      console.log(`Detected language: ${detectedLanguage}`);

      // Xử lý function calls từ Gemini nếu có
      if (detectedLanguage) {
        await saveNewLanguageCode(
          languagesCollection,
          detectedLanguage,
          languages
        );
      }
    } catch (error) {
      console.error("Error parsing response:", error);
    }
  } catch (error) {
    console.error("Processing error:", error);
  }

  // Finally, save results with original and translations
  try {
    await event.data.after.ref.set({
      "original": message,
      "translations": translated,
    }, { merge: true });
    console.log("Successfully saved translations");
  } catch (error) {
    console.error("Error saving translations:", error);
  }
});