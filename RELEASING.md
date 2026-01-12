# Release Process

To create a new release for this repository:

1. Prepare the `CHANGES.md` file for release:

   - Move the relevant changes to a new section at the top of the file, using the version and the release date (e.g., `## 1.0.0-alpha.1 (2026-06-30)`).
   - Ensure the section header matches the version and date you intend to release.
   - Commit and push the updated `CHANGES.md` to the repository. Validate that the changes are correct and CI passes.

2. Use the local helper script `create-release-tag.sh` to generate the appropriate annotated tag for your release type (alpha, beta, rc, or stable):

   ```sh
   Usage: ./create-release-tag.sh <release-type> <version>
    <release-type>: alpha | beta | rc | stable
    <version>: version number, e.g. 1.0.0 or 1.0.0.1
   ```

   The script will suggest the next tag and prompt for confirmation before creating it. It will also verify that the computed tag matches the top section of `CHANGES.md` before proceeding.

   Review carefully that the suggested tag matches your expectations and the `CHANGES.md` file.

3. Push the new tag to the repository:

   ```sh
   git push origin refs/tags/<tag_name>
   ```

This will trigger the automated release workflow, which will publish the release on GitHub with the appropriate changelog entry.
