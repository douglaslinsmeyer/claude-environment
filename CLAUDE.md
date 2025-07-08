## Development Guidelines

- Any time we add or change functionality we MUST update the change log; and update the version file.
- Regression is to be avoided, run the test suite with every change to source code.
- Before push changes, run tests to confirm our work hasn't caused regression.
- When we have completed a change, record our work in the change log.
- Before pushing, check that our versioning is accurate across CHANGELOG.md, VERSION, and manifest.json
- When we change/add logic/functionality we must update tests to mitigate the risk of regression.
- We need to remember to support upgrades of previous versions.

## Committing and Pushing Changes
- Regenerate the manifest.json file using `npm run generate-manifest` before committing.