### ToDo.md for MODEL-AD Project

This document lists development ideas for the MODEL-AD project. Each idea is documented one line at a time to form the pseudocode for the project. The process is documented end to end to ensure clarity and smooth execution.

---

#### Study Configuration and Data Management
1. Generate study configuration files for all studies.
2. Capture study structure in a YAML template.
3. Use the YAML template to create study configuration files.
4. Specify the location of data with Synapse IDs in the configuration.
5. Identify the type of data associated with each Synapse ID.
6. Define study workflow tasks.

#### Documentation and Wiki
7. Add documentation to the wiki.
8. Create a function to convert DOCX files to Markdown.
9. Add URLs to the documentation for the content drivers in the portal.
10. Add acknowledgment statements to the documentation.
11. Identify where acknowledgment statements are located in Synapse.
12. Determine what other information needs updating in Synapse.

#### Portal Content and Verification
13. Describe in detail which Synapse Tables drive the content on the AD Portal.
14. Resolve the content drivers for the AD Portal to move forward.
15. Specify where the study should appear in the staging portal.
16. Verify the study's appearance in the staging portal.
17. Update the `resources.ts` file.
18. Inform the portals team about the updates.

#### Process Documentation and Automation
19. Document the entire process in pseudocode.
20. Use the pseudocode as the starting point for the project.
21. Provide a structured approach to follow.
22. Create Python scripts where applicable.
23. Create R scripts where applicable.
24. Create Bash scripts where applicable.
25. Create SQL scripts where applicable.

#### General Guidelines
26. Focus on clarity in the documentation.
27. Provide all necessary information in the project documentation.

---

### Ideas for Development

Following this organized and intuitive list will help develop the project smoothly and efficiently, ensuring each step is clear and well-documented. This structure assists new users and developers in understanding the workflow and contributing effectively.

- Review early onboarding notes to identify requirements and areas for improvement.
- Review the display of studies on the portal to identify what needs to be added or removed.
- Add notes to the DCA workflow.
- Create study folders and subfolders for each datatype listed in AMPM or ADEL tickets.
- Read in Jira tickets for AMPM and ADEL tickets.
- Extract important information from Jira tickets.
- Automate the creation of study and data folders.
- Set permissions on study, data, and staging folders.
- Add information about data releases and updating community portals and Jay Hodgson in Jira tickets.