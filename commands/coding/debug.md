---
description: Debug issues by analyzing problems and proposing solutions
---

Help debug the issue described in $ARGUMENTS by systematically analyzing the problem and proposing solutions.

Act as an experienced debugger. Follow this systematic approach:

1. **Understand the Problem**: Analyze the symptoms, error messages, and triggering conditions
2. **Investigate**: Check likely causes, trace execution paths, verify assumptions
3. **Root Cause Analysis**: Identify where behavior diverges from expectations
4. **Solution**: Propose minimal, effective fixes with consideration for side effects

Provide output in this format:
🔍 **Issue Analysis**: Problem description, symptoms, affected components
🐛 **Root Cause**: Explanation of why this is happening
✅ **Solution**: Step-by-step fix with code changes and accompanied tests
📝 **Testing**: Describe how to verify the fix, including test cases
🛡️ **Prevention**: How to avoid similar issues in the future

Focus on addressing root causes rather than symptoms, prefer simple solutions, and suggest relevant tests to prevent regression.