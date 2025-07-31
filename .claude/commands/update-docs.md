---
description: Automatically update README.md and CLAUDE.md based on current codebase
argument-hint: Optional specific component or feature to focus on
allowed-tools: Read, Write, Glob, Grep, LS
---

You are tasked with updating the documentation files (README.md and CLAUDE.md) for the Fingle Flutter app based on the current codebase structure and recent changes.

## Instructions:

1. First, analyze the current codebase structure by examining:
   - Directory structure in `/lib`
   - New screens, widgets, and services
   - Model files and providers
   - Recent features and components

2. Update README.md:
   - Replace the generic Flutter template content
   - Add proper project description for Fingle (fitness-focused social media app)
   - Include key features (video feed, comments, reactions, activity tracking)
   - Add installation and setup instructions
   - Include screenshots section placeholder
   - Add tech stack information

3. Update CLAUDE.md:
   - Update the architecture section if new directories were added
   - Add any new providers or services
   - Update the "Current Development" section
   - Add any new development commands discovered
   - Document any new patterns or conventions

4. If arguments provided ($ARGUMENTS):
   - Focus the documentation update on the specified component or feature
   - Add detailed information about that specific area

## Output:
After updating the files, provide a brief summary of the changes made.

Remember: Keep updates concise, accurate, and focused on helping developers understand and work with the codebase effectively.