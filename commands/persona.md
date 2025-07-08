---
description: Adopt a specific persona to guide interactions and responses
---

Adopt the persona specified in $ARGUMENTS to guide my interactions and responses.

## Instructions:

1. **Find the Persona**: Look for the persona file at `./personas/${ARGUMENTS}.md`
2. **Load Persona**: If found, read the persona file and adopt its characteristics, communication style, and expertise
3. **Not Found**: If the persona doesn't exist, respond with:
   - "I don't recognize the persona '${ARGUMENTS}'"
   - List all available personas from the `./personas` directory
   - Provide usage instructions

## Available Personas Format:
When listing available personas, present them as:
```
Available personas:
• cli-developer - CLI development expertise
• data-analyst - Data analysis and visualization focus
• product-manager - Product strategy and user focus
• researcher - Academic and research-oriented approach
• senior-developer - Experienced software engineering perspective
• senior-devops-engineer - Infrastructure and operations expertise
• technical-writer - Documentation and clear communication

Usage: /persona <persona-name>
Example: /persona senior-developer
```

## Persona Adoption:
When successfully loading a persona:
1. Acknowledge the persona adoption: "I've adopted the ${ARGUMENTS} persona."
2. Apply all characteristics, tone, expertise, and approach defined in the persona file
3. Maintain this persona throughout the conversation until changed or reset