# Upstream v0.9.0 — historical batch 32: repository-independent Issue operation research

**Date:** 2026-11-15. **Owner:** [Upstream #56](https://github.com/opensiro/upstream/issues/56). **Protocol:** [v0.9.0 capability-first](https://github.com/opensiro/upstream/blob/main/docs/CAPABILITY_FIRST_RESEARCH.md). **Original first-party request:** [yottadynamics/yottacode #291](https://github.com/yottadynamics/yottacode/issues/291). **Classification of this extension:** `OPPORTUNITY_RESEARCH_PENDING`, not an accepted source-native feature or an assessment-derived discovery.

## Chronology and boundaries

Canonical bootstrap: [START_HERE](https://github.com/opensiro/vsm-oss-organization/blob/main/START_HERE.md) → [ECOSYSTEM](https://github.com/opensiro/vsm-oss-organization/blob/main/docs/ECOSYSTEM.md) → `opensiro/upstream@main` → existing #56, frozen [batch 32](https://github.com/opensiro/upstream/blob/main/data/assessment-candidate-batches/2026-11-12-32.json). The historical batch, original Index pin `85ae995fc2551ac0a076609bce0300d075cac2d5`, original preregistered hypotheses and frozen assessments remain unchanged. No new batch or issue is created.

The prior [source-first issue mutation report](2026-11-15-upgrade-v090-historical-b32-issue291-full-native.md) and [14-file base prototype](repro/2026-11-15-b32-yottacode-issue-291-complete-native-prototype.patch) cover the first-party #291 request: `issue_update` and `issue_add_comment`. Those two operations are technically proven in a local native fixture; they were **not shipped to yottacode**. Their original request is about avoiding the GitHub web UI and separately authenticated `gh` CLI, **not** about arbitrary repository selection.

A subsequent **operator UX question** was whether a person can handle Issues without even opening a local repository. That is a new, adjacent product scenario, **not a request made by original yottacode #291** and **not** a retrospectively VSM/Index-derived prediction. The original source `yottadynamics/yottacode@3f388ee03db7fbf0ec44c368a59bfd32822d1730` already exposes `Owner`/`Repo` in the lower-level typed GitHub API and `resolveOwnerRepo` allows explicit identity; the user-facing agent tools lacked a `repo` field.

## New task: act from a non-checkout working directory

| Native user action | Before this incremental change | Additive prototype |
| --- | --- | --- |
| `issue_list` | Read Issues belonging to the inferred cwd repository | Optional `repo: "owner/name"` and existing filters |
| `issue_read` | Read `number` in the inferred cwd repository | Optional explicit `repo` with `number` |
| `issue_update` | Change title/body of an Issue in inferred cwd repo | Explicit `repo` + number, exact partial field update |
| `issue_add_comment` | Add a top-level Issue comment in inferred cwd repo | Explicit `repo` + number + body |

The explicit target does not require entering a local Git checkout. If omitted, the old cwd inference remains intact. A malformed target returns validation failure before any write; write previews display the selected target; `RequiresApproval` remains true and the existing `Github(update_issue)` / `Github(add_issue_comment)` permissions remain in force. This is a **local research extension**, not a production or deployment claim.

## Native counterfactual and actual tests

A matched, offline native test used a real `github.TypedClient` configured with a **non-Git temporary directory**, an inert fake HTTP transport and the same mocked token. **Without explicit `repo`**, the legacy agent `issue_update(number,title)` returned `updated=false` with zero HTTP requests. **With `repo:"other/project"`**, the same client/tool reached `GET /repos/other/project/issues/7` then `PATCH /repos/other/project/issues/7`, returning `updated=true`; the companion comment made `GET` then `POST /repos/other/project/issues/7/comments`, returning `posted=true`. **No public GitHub mutations occurred.** This demonstrates an actual newly completed scripted API workflow, not user time saved.

Additional native tool tests observed all four tools forwarding explicit `Owner`/`Repo` with no `CwdRef`, the correct repository in both write previews, compatibility when `repo` is omitted, rejection of 10 invalid repository identities before any write, and rejection by read/list before an adapter call.

**Executed native quality gates on the augmented, isolated original-source checkout** (Go 1.27.4):

| Gate | Observed result |
| --- | --- |
| Focused `TestCrossRepo*` tool and full-agent fake HTTP tests | **PASS** |
| `go build ./...` | **PASS** (empty output SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`) |
| `go test ./... -count=1 -timeout=180s` | **PASS** (log SHA-256 `d0623a2e8b16b9f21b584f8fefb046a569607e66b290bc47dcc180cc47fdc830`; 54 lines, no failing package) |
| `go vet ./...` | **PASS** (empty output SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`) |
| `git diff --check` | **PASS** |
| Exact patch replay on a second clean source worktree | **PASS**, six resulting files identical byte-for-byte |

**Reproduction:** At exact original source `3f388ee03db7fbf0ec44c368a59bfd32822d1730`, first apply the already published [base 14-file prototype](repro/2026-11-15-b32-yottacode-issue-291-complete-native-prototype.patch) (SHA-256 `20440b2d34673f6498b0239e4b18bec2228e0ff44521f7ee7e4b7de6490273df`), then apply this [six-file incremental research patch](repro/2026-11-15-b32-yottacode-no-checkout-additive.patch) (19,892 bytes; SHA-256 `552bf3ea13b3281fbb9648ed6b6e6ddf47c779b219741a0dbbcf1cc9687a88ec`). Both `git apply` operations were executed successfully in a fresh detached worktree, and all six incremental result files matched the tested worktree byte-for-byte. This is a prototype preserved in Upstream `reports/repro/`, not a third-party fork write.

## Material safety, acceptance and adoption limits

1. **Repository-level authority is not complete.** The existing permission descriptors are action-oriented (`Github(update_issue)`, `Github(add_issue_comment)`). Adding an explicit remote repo broadens the possible write *target*, including under configurations where `--yolo` can bypass the usual approval modal (existing explicit `deny` rules still apply). The prototype validates destination syntax and shows it in previews but **does not enforce a per-repository allowlist or an independent mandatory cross-repo decision gate**. Production admission must resolve exact target-bound authority and no-surprise-write behavior in yottacode's native permission/approval model; the source permission envelope must not be widened by merely adding an argument.
2. **Product need is not accepted by original maintainers.** yottacode #291 substantiates the two typed mutation operations but does *not* specify remote-repository UX. This extra capability requires explicit source-native contract/maintainer direction and a nonduplication/relevance check before third-party implementation/publication.
3. **No real-user efficiency proof.** The observable proxy is a newly completed no-checkout API task in deterministic fixtures. Time, cognitive switching, errors in real conversations, live API auth scopes, UI initialization outside Git, source CI, human review, maintainer acceptance and deployment were **not** measured.
4. **No external publication permission inferred.** The earlier [batch 32 external-gate report](2026-11-15-upgrade-v090-historical-b32-issue291-full-native.md) records the missing actor-bound selection/reviewed direct fork and `BLOCKED_EVIDENCE` status. A local PASS does not create `AWAITING_EXTERNAL`, waive legal/source gates or establish a direct `opensiro-contributions` fork. No external PR was created.

## Decision

**Engineering counterfactual: PASS** for the narrow new scripted ability to operate on Issues in explicitly selected repositories without a local checkout. **Research/product admission: PENDING**, specifically (a) first-party need/UX acceptance, (b) target-bound permission and unattended-mode guard, (c) end-to-end real CLI ergonomics and user trials. No new VSM grade, strict `ASSESSMENT_DERIVED` attribution, source delivery, external PR, adoption or operator-time saving is claimed. Keep this extension as a distinct additive research artifact of the **same historical batch 32 and issue #56**.