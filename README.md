<p align="center">
  <img src="assets/logo.png" alt="Siraj Logo" width="150"/>
</p>

<h1 align="center">Siraj – Your Arabic AI Learning Companion</h1>

---

## 🚀 About Siraj

**Siraj** is an Arabic AI-powered educational assistant designed to answer user queries in natural Arabic, leveraging speech and visual input. The app helps users practice language, ask questions, and engage in spoken conversations powered by Large Language Models (LLMs), with support for audio responses, lip-sync, and emotion-aware 3D avatar feedback.

The app was conceptualized and prototyped during the **QCRI Intern Hackathon** in **July 2025** by a team of interns at **Qatar Computing Research Institute (QCRI), HBKU**, as part of a research initiative to make Arabic LLMs more accessible and educationally impactful.

Siraj is built with modularity in mind — from backend APIs integrating Gemini and emotion detection, to a 3D web frontend with avatar animation and voice synthesis.

---

## 💡 Key Features

- 🔊 **Voice-based interaction** in Arabic with transcription and text-to-speech
- 🧠 **LLM integration** using Google's Gemini API for Arabic Q&A and chat
- 🎭 **Emotion detection** to personalize avatar reactions
- 👄 **Lip-sync** with audio using Rhubarb Lip Sync
- 🧍‍♂️ **3D Avatar** rendered with Three.js and iframe in Flutter Web
- 📷 **Visual QA (planned)** – ask questions about images (e.g., "What is in this photo?")
- 📚 Designed to support **Arabic education and accessibility use cases**

---

## 🧑‍💻 Tech Stack

| Layer           | Technologies Used |
|----------------|-------------------|
| **Frontend**   | Flutter Web, iframe + HtmlElementView (for 3D avatar) |
| **Avatar UI**  | Three.js, WebGL, GLB model, Rhubarb lip sync JSON |
| **Backend**    | Node.js, Express, Python (emotion detection), gTTS |
| **APIs Used**  | Google Generative AI (Gemini), Fanar Arabic ASR API |
| **TTS**        | gTTS (Google Text-to-Speech) |
| **Lip-Sync**   | Rhubarb Lip Sync |
| **Emotion Detection** | Python (facial emotion classifier) |

---

## 🛠 Project Structure

siraj/
├── assets/
│ └── logo.png
├── backend/
│ ├── app.js (Node/Express server)
│ ├── emotion_detector.py
│ └── routes/chat.js
├── frontend/
│ ├── lib/
│ │ └── views/ask_siraj_view.dart
│ └── web/
│ └── avatar.html (3D avatar scene)
├── models/
│ └── modelguy.glb
└── README.md


---

## 🧪 Development History

- 💡 **July 2025**: Idea formed and prototype developed during **QCRI Intern Hackathon**
- 🤝 Built by a team of QCRI interns during the summer internship program
- 📈 Focused on **Arabic education**, **spoken QA**, and **emotion-aware avatar interaction**

---

## 🗂 Related Work

Even though the formal internship was not continued, contributions to **data annotation tasks** for QCRI projects are **ongoing**, including:

- **Spoken QA Dataset Collection**: Recording various Arabic question types (MCQ, open-ended, true/false) to train speech-based LLMs.
- **Image QA Auditing**: Verifying model-generated answers, rationales, and image relevance under expert supervision.

---

## 🤝 Acknowledgements

- **Qatar Computing Research Institute (QCRI)** for mentorship and infrastructure.
- **Fanar Arabic API** for speech transcription.
- All fellow QCRI interns who contributed to brainstorming, testing, and building the early prototype of Siraj.

---

## 📸 Screenshots

> Add screenshots or GIFs here to demonstrate the app in action.

---

## 📜 License

MIT License – see [`LICENSE`](LICENSE) file for details.

---

