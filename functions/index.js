const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const openaiApiKey = defineSecret("OPENAI");
const OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";

exports.generateSampleText = onCall(
  { secrets: [openaiApiKey] },
  async (request) => {
    // request.data contains the parameters
    const category = request.data.category;
    let length = parseInt(request.data.length) || 75;

    if (!category) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with argument 'category'."
      );
    }

    // Override length for Carnage category
    if (category === 'Carnage') {
      length = 30;
    }

    const prompt = `Generate a sample text of approximately ${length} words for the category: "${category}". 
The text should only contain alphanumeric characters and simple punctuation. 
Do NOT use emdashes (—), use hyphens (-) instead if needed.
Do not include any other text or explanation, just the sample text.`;

    try {
      const response = await fetch(OPENAI_API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${openaiApiKey.value()}`,
        },
        body: JSON.stringify({
          model: "gpt-4o",
          messages: [
            {
              role: "system",
              content: "You are a helpful assistant that generates sample text for typing games.",
            },
            { role: "user", content: prompt },
          ],
          max_tokens: Math.max(400, Math.ceil(length * 2)), 
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error("OpenAI API error:", errorText);
        throw new Error(`OpenAI API error: ${response.statusText}`);
      }

      const data = await response.json();
      const generatedText = data.choices[0].message.content.trim();

      return { text: generatedText };
    } catch (error) {
      console.error("Error generating text:", error);
      throw new HttpsError("internal", "Failed to generate text.");
    }
  }
);
