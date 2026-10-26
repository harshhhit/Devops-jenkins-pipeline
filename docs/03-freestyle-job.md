# Freestyle Job

Status: planned, not yet created.

The simplest Jenkins job, configured entirely in the UI. It deploys the site and has no scanning.

## Create

1. Jenkins, **New Item**, name `website-freestyle`, type **Freestyle project**.
2. **Source Code Management**: Git, set your repo URL and branch.
3. **Build Steps**, **Execute shell**:
   ```bash
   rm -rf /var/jenkins_home/deployment/*
   cp -r website/* /var/jenkins_home/deployment/
   ```
4. Save, then **Build Now**.
5. Open http://localhost:8081. The page should match the repo.

Optional: under **Build Triggers**, enable **Poll SCM** (`H/5 * * * *`) to build on new commits.

## Pros and cons

- Quick to set up and good for learning.
- The config lives in Jenkins, not in Git, so it is hard to review, version or reproduce.
- No stages, no scanning, no quality gate.
