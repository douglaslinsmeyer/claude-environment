<!-- CLAUDE-ENV-START v2.5.0 -->

# Memory Management Instructions for Agentic AI

## Memory Initialization
- At the start of each conversation, silently retrieve all relevant information from your knowledge graph using
mcp__memory__read_graph or mcp__memory__search_nodes
- Begin responses with "Remembering..." only when explicitly recalling stored information for the user
- Internally refer to the knowledge graph as your "memory" system

## Information Categorization
During interactions, actively identify and categorize new information:
- Identity Attributes: Personal details (name, age, location, occupation, education)
- Behavioral Patterns: Habits, preferences, recurring activities, interests
- Communication Preferences: Preferred tone, language, technical level, format preferences
- Goals & Objectives: Short-term tasks, long-term aspirations, project goals, learning objectives
- Relationship Network: People, teams, organizations, and their connections (up to 3 degrees)
- Context & Projects: Current work, tools in use, environments, ongoing initiatives
- File system: Relevant files, directories, and their contents
- Temporal Context: Important dates, deadlines, milestones, and historical events
- Observations: Specific facts, preferences, or details about entities
- Source Code: Functions, classes, methods, variables, and their relationships
- System State: Current status of projects, tasks, and tools
- Techniques and reasoning patterns: Problem-solving approaches, coding styles, debugging methods

## Memory Operations

### Creating Entities
Use mcp__memory__create_entities for:
- New people, organizations, projects, or systems mentioned
- Recurring concepts or tools that are significant to the user
- Important files, directories, or resources
- Source code components (functions, classes, methods)
- Techniques or reasoning patterns that are frequently used
- Important events or milestones

### Creating Relations
Use mcp__memory__create_relations to establish connections:
- User relationships (e.g., "works_with", "manages", "collaborates_on")
- Project associations (e.g., "owns", "contributes_to", "uses")
- Temporal relations (e.g., "started_on", "completed")
- File system relations (e.g., "contains", "belongs_to")
- Source code relations (e.g., "calls", "inherits", "depends_on")
- Techniques and reasoning patterns (e.g., "applies_to", "influences")

### Adding Observations
Use mcp__memory__add_observations to record:
- Specific facts, preferences, or details about entities
- Context-specific information
- Time-sensitive data or status updates

### Memory Retrieval Strategy

- Use mcp__memory__search_nodes for broad queries about topics or concepts
- Use mcp__memory__open_nodes for detailed information about specific entities
- Cross-reference related entities to provide comprehensive context

### Memory Maintenance

- Periodically review stored information for relevance
- Update observations when information changes
- Use mcp__memory__delete_observations for outdated information
- Maintain relationship accuracy with mcp__memory__delete_relations when connections change

# Sub-Agent Delegation Guidelines
Any time a task can be done by a sub-agent, it should be delegated to that sub-agent. Tasks that are appropriate for delegation include:
- Searching for files or directories
- Reading or writing files
- Performing calculations or data processing
- Any task that can be performed by a sub-agent without requiring human-like reasoning or creativity

# Personas
When asked to adopt a persona, follow these steps:

Locating Personas
   - Check the current directory for `./.claude/personas/${ARGUMENTS}.json`
   - If not found, check `~/.claude/personas/${ARGUMENTS}.json`
   - If still not found, inform the user that no persona was found and that you will continue with the default persona.

# Templates
When asked to use or reference a template, follow these steps:

Locating Templates
- Check the current directory for `./.claude/templates/${ARGUMENTS}.json`
- If not found, check `~/.claude/templates/${ARGUMENTS}.json`
- If a specific template is found, load it and apply its structure and content to the response
- If no specific template is found, inform the user that no template was found and that you will continue without it.

<!-- CLAUDE-ENV-END -->