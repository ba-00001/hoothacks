# Campus AI Assistant

A full-stack web application chatbot for FAU students. Answers 15+ common questions across Academics, Campus Life, and Deadlines categories.

## Features
- Demo authentication (username/password + mock Google login)
- Interactive chat UI
- AI agents for intent detection, FAQ matching, category routing, response generation
- Node.js/Express backend

## Setup
1. `cd CampusAIAssistant`
2. `npm install`
3. `npm start`
4. Open http://localhost:3000

Demo login: username `student`, password `fau123`

## Project Structure
```
CampusAIAssistant/
├── frontend/     # HTML/CSS/JS
├── backend/      # Express server
├── ai-agents/    # Chat logic agents
├── package.json
├── README.md
└── TODO.md
```

## Testing the Chatbot
Categories & Sample Questions:
- **Academics**: \"How do I register for classes?\", \"What is the grading scale?\"
- **Campus Life**: \"Where is the bookstore?\", \"What events are happening?\"
- **Deadlines**: \"When is add/drop period?\", \"Finals schedule?\"

Built by BLACKBOXAI for hoothack-track-1.
