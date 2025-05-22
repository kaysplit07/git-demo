2. Adjusting maxUnavailable / minAvailable Values
Symptoms:
Allowed disruptions did not align with cluster requirements.
After editing PDBs, observed fluctuations in maxUnavailable values causing inconsistent pod disruption behavior.
Root Cause:
Misconfigured disruption tolerances in PDB specs.
Manual edits toggled values without fully understanding impact on cluster availability.
Resolution:
Evaluated actual pod counts and application availability requirements.
Set maxUnavailable or minAvailable accordingly, balancing fault tolerance and disruption tolerance.
Used consistent values across PDBs in the namespace reflecting actual deployment size.
3. Edit Command Usage and Errors
Symptoms:
Occasional command typos or misuse (e.g., kubectl describe edit ...) caused errors.
Cancelling edits sometimes left PDBs unchanged, causing confusion about applied settings.
Root Cause:
Human errors during manual edits and command execution.
Resolution:
Recommended cautious usage of kubectl edit with validation after each change.
Use of kubectl describe pdb <pdb-name> after edits to confirm changes.
Avoiding invalid commands and relying on kubectl autocompletion where possible.
Best Practices and Recommendations
Always ensure PDB selectors precisely match pod labels.
Prefer using minAvailable over maxUnavailable for clarity when specifying minimum required availability.
Verify pod labels with kubectl get pods --show-labels before creating or updating PDB selectors.
After editing a PDB, confirm changes with kubectl describe pdb <pdb-name>.
Maintain documentation of disruption tolerance values aligned with application SLAs.
Automate validation checks in CI/CD pipelines to prevent selector mismatches or invalid configurations.
Conclusion
Proper configuration of PDBs is critical for ensuring application availability during cluster maintenance or disruptions. The observed issues were mainly caused by selector label mismatches and misconfigured disruption thresholds. By carefully aligning selectors with pod labels and adjusting disruption tolerances to match operational needs, cluster stability and uptime were significantly improved.
 
