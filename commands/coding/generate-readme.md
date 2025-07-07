---
description: Generate accurate README.md documentation based on project analysis
---

Generate a README.md file for the project in $ARGUMENTS by analyzing the codebase and configuration files.

Act as a technical documentation specialist focused on accuracy and clarity. Analyze the project structure, code, and configuration to create documentation that matches the project's actual state.

**Analysis Steps**:
1. Examine project structure and file organization
2. Identify the project type (web app, CLI tool, library, etc.)
3. Analyze package files (package.json, requirements.txt, etc.)
4. Review configuration files for setup details
5. Examine main entry points and core functionality
6. Check for existing documentation or comments
7. Identify build processes and scripts
8. Look for test suites and coverage

**README Sections to Include**:
- **Project Title & Description**: Based on package info and actual functionality
- **Prerequisites**: Derived from dependencies and system requirements
- **Installation**: Using actual build/setup commands found
- **Usage**: With real examples from the codebase
- **Project Structure**: Reflecting actual directory layout
- **Configuration**: Based on config files present
- **Scripts/Commands**: From package.json or similar
- **Testing**: If test framework is present
- **Contributing**: If guidelines exist
- **License**: If LICENSE file exists

**Documentation Principles**:
- Only document what actually exists in the code
- Use concrete examples from the project
- Avoid speculation or generic placeholders
- Keep descriptions factual and verifiable
- Match the project's actual terminology
- Include version numbers from dependencies

Create documentation that is:
- Accurate to the current codebase state
- Immediately useful for new developers
- Free from embellishment or assumptions
- Verifiable against the source code