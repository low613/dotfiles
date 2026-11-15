---
name: pre-push-review-gate
description: Automatically invoke before every Git push, pull-request creation, or update that would send commits to a remote branch, even when the user does not explicitly name this skill. Gate publication behind parallel full code-quality and security reviews, a plain-English user decision, optional agent fixes, repeated review cycles, and explicit user approval. Also invoke for pre-push reviews, code-and-security reviews, or iterative review-and-fix loops.
---

# Pre-push Review Gate

Prevent `git push`, PR creation, and any equivalent remote publication until this workflow completes and the user explicitly approves the push.

## Establish scope

1. Read repository instructions, including every applicable `AGENTS.md`.
2. Inspect worktree status, current branch, remotes, and existing PR metadata.
3. Determine the intended PR base branch from explicit user context or existing PR metadata. If neither exists, use the repository's default branch and state that assumption.
4. Fetch the relevant remote when permitted so the review compares against current remote state.
5. Define the review scope as every commit and working-tree change that the proposed push would add to the PR. Include staged, unstaged, and untracked source files. Exclude unrelated pre-existing user changes only when they can be identified reliably; otherwise flag the ambiguity before publication.
6. Record the exact diff/range and validation commands so every review agent examines the same artifact.

Do not push as part of setup. Read-only remote inspection and fetches are allowed.

## Run independent reviews in parallel

Spawn at least two fresh subagents concurrently:

- **Code reviewer:** Perform a full correctness and maintainability review. Look for functional bugs, regressions, edge cases, error handling, concurrency or state problems, incompatible interfaces, missing tests, and violations of repository instructions. Run relevant read-only checks where useful.
- **Security reviewer:** Perform a full security review appropriate to the languages and frameworks in scope. Look for authentication or authorization flaws, injection, unsafe deserialization, secret exposure, path or command manipulation, insecure defaults, data leakage, dependency risks visible in the diff, and abuse cases. Use an applicable installed security-review skill when available.

Give both agents:

- the repository path;
- the same base, head, diff/range, and uncommitted-file scope;
- applicable repository instructions;
- a requirement to inspect the actual files, not merely the diff excerpt;
- a requirement to report only actionable findings introduced or exposed by the proposed changes;
- a requirement not to edit files, commit, push, or contact the user.

Require each finding to contain severity, file path, tight line or symbol location, the concrete failure or exploit scenario, and the smallest reasonable remediation direction. Require agents to say explicitly when they find no issues. Do not leak one reviewer's conclusions to the other.

Wait for final output from both reviewers and verify that each assigned review actually ran. Keep a completion ledger containing each review role, its subagent identity, and its received final report. Check live agent status when the collaboration tools expose it. A pending, failed, interrupted, timed-out, missing, or merely claimed reviewer is not a clean review. If agent capacity delays one reviewer, wait or retry it; do not continue with only one review track. The primary agent must not substitute its own review for either required subagent.

## Synthesize through a fresh subagent

Only after the completion ledger contains two received final reports, spawn a new synthesis subagent. Give it both raw review reports, their reviewer identities, and the scoped diff metadata, but do not give it the primary agent's conclusions. Never ask the synthesizer to fill in for a missing review or to accept an unsupported assertion that a review completed. Require it to:

1. Verify findings against the code and discard duplicates, speculation, pre-existing unrelated problems, and style-only preferences unless repository rules make them mandatory.
2. Preserve disagreements or uncertainty instead of inventing certainty.
3. Order valid findings by severity and impact.
4. Produce a plain-English report suitable to present directly to the user.

Every reported issue must clearly state:

- where it is, using a repository-relative file path and line or symbol;
- what the code currently does;
- when or how it fails or can be abused;
- why that matters;
- what kind of change would address it.

Avoid reviewer jargon and unexplained security terminology. Do not expose hidden reasoning or include vague statements such as "improve validation" without naming the input, location, and failure mode.

## Ask for the user's decision

The primary agent must present the synthesized report. Subagents cannot communicate with the user directly, so the synthesis subagent prepares the prompt and the primary agent relays it faithfully.

If findings exist, ask which findings the user wants fixed, or whether they accept specific findings as-is. Never infer acceptance from silence. Do not edit code while waiting unless the user already authorized fixing all valid findings.

If no findings exist, report that both review tracks completed and ask whether the user approves the push. A clean review is not itself push approval.

## Fix and repeat

When the user authorizes fixes:

1. Spawn a fresh implementation subagent with only the selected findings, repository instructions, and current scoped code context.
2. Require it to make the smallest coherent fixes and run proportionate validation. It must not commit or push unless the user separately requested commits and repository rules permit them.
3. Have the primary agent inspect the resulting diff and validation evidence.
4. Rerun the entire parallel code-review and security-review cycle against the updated complete push scope.
5. Use another fresh synthesis subagent and ask for the user's decision again.

Repeat until the user explicitly says they are satisfied with the latest review and approves pushing. Previously cleared findings are not automatically cleared after code changes; only the latest complete review controls the gate.

## Permit or block publication

Allow the push only when all of these are true:

- the latest complete code and security reviews cover the exact current push scope;
- all requested fixes are present and validated;
- any remaining findings were explicitly accepted by the user;
- no code has changed since that review, except metadata-only actions that cannot affect the reviewed code;
- the user explicitly approves the push after seeing the latest report.

If code changes after approval but before pushing, invalidate approval and rerun the review loop. If the push fails and no code changes, diagnose and retry without repeating the review unless the outgoing content changes.

Follow any stricter repository workflow, including environment-specific branches, staging-before-production requirements, commit conventions, and PR sequencing. Never weaken those requirements.

## Report the result

After an approved push, verify the remote branch or PR state and report what was pushed, the reviewed commit or range, validation performed, remaining user-accepted findings, and the PR URL when available. Do not claim a push or PR succeeded without remote evidence.
