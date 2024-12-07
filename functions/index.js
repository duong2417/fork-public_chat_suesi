/* eslint-disable max-len */
const v2 = require("firebase-functions/v2");
const vertexAIApi = require("@google-cloud/vertexai");

const project = "flutter-dev-search";
const location = "us-central1";
const textModel = "gemini-1.5-flash";
const admin = require("firebase-admin");

admin.initializeApp();

const vertexAI = new vertexAIApi.VertexAI({project: project, location: location});
const generativeModelPreview = vertexAI.preview.getGenerativeModel({
  model: textModel,
});

const generationConfig = {
  temperature: 1,
  topP: 0.95,
  topK: 64,
  maxOutputTokens: 8192,
  responseMimeType: "application/json",
  responseSchema: {
    type: "object",
    properties: {
      codes: {
        type: "array",
        items: {
          type: "string",
        },
      },
      explain: {
        type: "string",
      },
    },
    required: [
      "codes",
      "explain",
    ],
  },
};

// use onDocumentWritten here to prepare to "edit message" feature later
exports.onChatWithGemini = v2.firestore.onDocumentWritten(
    "/conversation/{messageId}",
    async (event) => {
      const document = event.data.after.data();
      const message = document["message"];
      // no message? do nothing
      if (message == undefined || document["role"] != "user") {
        return;
      }

      const chatSession = generativeModelPreview.startChat({
        generationConfig: generationConfig,
      });
      // const codebaseId = event.params.messageId.slice(0, -6);
      // console.log(`Processing message: ${codebaseId}, content: ${message}`);
      const codebaseCollection = admin.firestore().collection("codebase");
      const codebaseDoc = await codebaseCollection.doc("PublicChatScreen").get();
      const oriCode = codebaseDoc.data()["code"];
      console.log("oriCode: ", oriCode);
      const result = await chatSession.sendMessage(
          `${message}, code của tôi là: ${oriCode}.
          ví dụ: đổi nền thành màu xanh. code của tôi là:
          import 'package:flutter/material.dart'; class BaseScreen extends StatelessWidget {   const BaseScreen(this.widget);   final Widget widget;   @override   Widget build(BuildContext context) {     return Scaffold(       body: widget,     );   } },
          bạn phản hồi như sau:
          {
            "codes": [
              "import 'package:flutter/material.dart'; class BaseScreen extends StatelessWidget {   const BaseScreen(this.widget);   final Widget widget;   @override   Widget build(BuildContext context) {     return Scaffold(       body: Container(         color: Colors.blue,         child: widget,       ),     );   } }",
              "import 'package:flutter/material.dart'; class BaseScreen extends StatelessWidget {   const BaseScreen(this.widget);   final Widget widget;   @override   Widget build(BuildContext context) {     return Scaffold(       body: Container(         color: Colors.green,         child: widget,       ),     );   } }"
            ],
            "explain": "Tôi đã đổi nền thành màu xanh bằng cách..."
          } 
          `);
      const response = result.response;
      console.log("Response:", JSON.stringify(response));

      const jsonCodes = response.candidates[0].content.parts[0].text;
      console.log("codes json: ", jsonCodes);
      // parse this json to get translated text out
      const codes = JSON.parse(jsonCodes);
      codebaseCollection.doc("PublicChatScreen").set({
        "code": codes["codes"][0],
        "new_codes": codes["codes"],
        "ori_code": oriCode,
      }, {merge: false});
      // const data = event.data.after.data();
      const conversationCollection = admin.firestore().collection("conversation");
      conversationCollection.doc(`bot${event.params.messageId}`).set({
        "message": codes["explain"],
        "role": "bot",
        "time": document["new_time"],
      });
    });
