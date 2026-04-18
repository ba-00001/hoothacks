# Agent Connectors

This folder is the handoff point for real AI agent providers.

## Current Setup

- The active connector seam lives in `backend_springboot/src/main/java/com/homepilotai/agents/`
- Local deterministic providers are in `backend_springboot/src/main/java/com/homepilotai/agents/local/`
- REST endpoints still call the same Spring services, but those services now delegate into agent connectors

## Intended Future Connectors

- `gemini/` for Gemini or Vertex AI calls
- `openai/` for GPT or tool-calling based affordability agents
- `hybrid/` for fallback chains and provider routing

## Suggested Contract

Mirror the Java interfaces below when adding a provider:

- `AffordabilityAgentConnector`
- `GrantMatchingAgentConnector`
- `RecommendationAgentConnector`
- `MortgageAgentConnector`

That way the controller and service layer can stay stable while the backing AI provider changes.
