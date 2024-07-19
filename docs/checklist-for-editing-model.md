### Workflow for Editing the Data Model:

#### 1. **Setup and Access**
   - **Clone Repository**: Ensure you have the repository cloned locally. If not, clone it from GitHub.
     ```sh
     git clone https://github.com/adknowledgeportal/data-models.git
     ```
   - **Navigate to Modules**: Focus directly on the `modules/` directory where model editing will occur.

#### 2. **Branch Management**
   - **Create and Switch Branches**: Always work on a new branch for changes to avoid conflicts with the main branch.
     ```sh
     git checkout -b feature-branch-name
     ```

#### 3. **Edit Data Model**
   - **Modify CSV Files**: Make the necessary changes in the appropriate CSV files within the `modules/` directory.
   - **Validate Locally**: Use scripts or tools like Python or CSV lint tools to check the integrity and format of CSV files.

#### 4. **Commit and Push Changes**
   - **Commit Changes**:
     ```sh
     git add .
     git commit -m "Detailed description of changes"
     ```
   - **Push Changes**:
     ```sh
     git push origin feature-branch-name
     ```

#### 5. **Review and Integration**
   - **Open a Pull Request**: Use GitHub to open a pull request against the main branch and request a review from a team member.
   - **Review and Merge**: Address feedback, then merge the pull request upon approval.

#### 6. **Post-Merge Clean-up**
   - **Delete Branch** (if no longer needed):
     ```sh
     git branch -d feature-branch-name
     ```
   - **Update Documentation**: Ensure all related documentation is updated to reflect the changes made.

#### 7. **Automation**
   - **Automation Scripts**: Confirm that any associated GitHub Actions or automation scripts (e.g., `assemble_csv_data_model.py` or `schematic` conversion scripts) execute correctly after changes are pushed.
