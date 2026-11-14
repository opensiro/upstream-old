# Upstream batch 40 — Akmatori #48 integrated VictoriaLogs capability and official-provider falsifier (v0.9.0)

**Dated:** 2026-11-15 (user-local; execution around 2026-11-14 22:00 UTC) · **Existing owner:** [Upstream issue #56](https://github.com/opensiro/upstream/issues/56), [research PR #303](https://github.com/opensiro/upstream/pull/303) · **First-party operator request:** [akmatori/akmatori#48](https://github.com/akmatori/akmatori/issues/48).

**Do not rewrite history:** this is a **prospective v0.9.0 capability-first continuation of the same explicit batch 40 revisit of batch 39's frozen ten source repositories**, not a new batch, issue or iteration. Earlier original batch-40 v0.8.0 and batch-39 source evidence stay frozen. `SOURCE_FIRST / ASSESSMENT_INFORMED` at most, **never retroactively `ASSESSMENT_DERIVED`**. This report extends the previous [native mock LogsQL capability comparison](2026-11-14-upgrade40-v090-akmatori48-victorialogs-capability.md) with a *fully source-integrated, disposable, independent 13-file patch and a version-pinned real VictoriaLogs binary*.

## 1. New user task — actionable compared to the source baseline

**Who:** Akmatori SRE operators who have VictoriaMetrics metrics plus VictoriaLogs journald/nginx logs; [first-party #48](https://github.com/akmatori/akmatori/issues/48) reports an investigation where original host journal rotation hid a crash-loop cause and a metrics-only agent concluded incorrectly.

**Trigger → user action → output:** during an incident, choose a configured `victoria_logs` tool, run an **authorized, read-only, bounded LogsQL investigation** over an explicit time window, and return log records, hit counts over time, field names/values, or aggregation results for diagnosis. This is not a fix to existing VictoriaMetrics behavior. The native source `victoria_metrics.instant_query` works for Prometheus/MetricsQL metrics, but its `api_request` deliberately rejects the distinct `/select/logsql/query` endpoint. The novel benefit is the newly accessible **log evidence**, not a repaired SDK exception.

**VSM relevance:** extra verifiable **S1 operational feedback/evidence** supports better S3*/S3 oversight of investigation decisions and may inform S4 diagnosis; **no causal VSM-derived discovery, autonomy-loop closure, Index A/C/P regrade, production service quality or human accuracy claim** is established. The underlying request was source-first.

## 2. Exact versions and reviewable source patch

- **Frozen original cohort Akmatori SHA (unchanged):** `be62d926fe6d92dceb5cf12e9a95cb587433cdf1`.
- **Separately observed Akmatori main for integrated prototype:** `b2aae68949ae888a90a7436610d74b7b93507e7a`. This **does not** become a new cohort pin.
- **Upstream contribution protocol:** prospective `v0.9.0`. The owning research PR #303 still preserves its historical v0.8.0 base.
- **Original source license:** Apache-2.0 ([Akmatori license](https://github.com/akmatori/akmatori/blob/main/LICENSE)); [Akmatori contributing policy](https://github.com/akmatori/akmatori/blob/main/docs/CONTRIBUTING.md) requests an issue / #dev design discussion for a new provider. Issue #48 is open; its presence is **not** acceptance of this exact implementation.

**Artifacts:**

1. [Complete integrated 13-file patch](repro/2026-11-15-upgrade40-akmatori48-integrated-source.patch), SHA-256 **`12a51a94898b73f175d2ce41f71e943fa009504a6003afad002340dc62380354`**, 47,972 bytes. Applying it via `git apply` to a clean, detached exact-pin Akmatori source checkout succeeds; `git diff --check` PASS. It has native Go implementation and tests, **not merely a mocked SDK shim**.
2. [Pinned official-provider reproduction runner](repro/2026-11-15-upgrade40-akmatori48-victorialogs-official-v154.sh), SHA-256 **`944dd94854e2e82096d27268a4079b93c393826dd223d9c507a40f006531ff2f`**. Run with `bash` and `AKMATORI_VL_BINARY` / `AKMATORI_PATCHED_REPO` set to exact local paths; no Docker required. It provisions an ephemeral loopback-only VictoriaLogs server, injects **three synthetic** journald lines, runs the source-native Go integration test, shuts down the server and removes its scratch data.
3. [Machine-readable hashes, results and negative controls](evidence/2026-11-15-upgrade40-akmatori48-integrated-native.json), with independent patch replay, binary and runner hashes, detailed native outcome provenance, and the timing-sensitive upstream test failure noted below.

### What the patch actually integrates

| Source-owned integration boundary | Newly implemented in disposable Akmatori source |
| --- | --- |
| MCP Go package | New `internal/tools/victorialogs` source with distinct LogsQL POST + bounded NDJSON/JSON parsing, no Prometheus wire-format alias |
| Built-in MCP registry | Five named tools: `victoria_logs.query`, `hits`, `field_names`, `field_values`, `stats_query`, each with required schema; existing five `victoria_metrics.*` tools preserved |
| Credential/permission boundary | Original `database.ResolveToolCredentials` selects **enabled** `victoria_logs` instance and optional `logical_name`; original `mcp.Server` per-incident allowlist rejects unauthorized JSON-RPC tool call **before** any provider HTTP request |
| Source discovery | New built-in tool type seed, connector catalog entry, prompt and examples for all five read-only functions; built-in namespace reserved against custom HTTP/MCP server impersonation |
| Settings UI | First-party `GetToolSchemas` serves `vl_url`, bearer/basic/custom-header modes, secret field flags, TLS verification setting and timeout to the original operator form; no bespoke React component added |
| Operational controls | POST only to explicitly selected LogsQL read-only endpoints, bounded RFC3339 positive window ≤6h, max 200 records, max 256KiB provider response, fixed HTTP deadline, credential requirements, no redirects, no arbitrary API path. Limits are **research implementation choices**, not source-maintainer-approved policy |
| Native tests | Five requested operations, invalid timestamp/limit/URL, malformed provider responses, auth variants and redaction, original source DB resolver, registry schema parity and original gateway authorization negative control, app seeding and agent prompt, plus opt-in official-server test |

### Negative/compatibility controls

The **first-party JSON-RPC authorization** test sends a call with a **nonpermissive empty allowlist**: **zero** requests reach the fake VictoriaLogs backend. When a matching `victoria_logs` instance is allowed, **one** LogsQL query reaches the backend, with the actual DB-configured bearer token, and returns the crash-loop log. Original VictoriaMetrics registration, schemas and Prometheus behavior remain intact. Disabled/wrong `logical_name` does not retrieve credentials. The adapter rejects unsupported operations, unexpected URL path/query/userinfo, invalid/inverted/too-wide time ranges, missing auth, too many result lines, malformed NDJSON, oversized response, HTTP error bodies containing secrets, and redirect responses. These bounded tests **do not prove production SSRF, networking policy, or overall security signoff**.

## 3. Official VictoriaLogs v1.54.0 — real native endpoint check

The official Linux binary from [VictoriaMetrics/VictoriaLogs release v1.54.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.54.0) was obtained separately (no Docker daemon available):

- Archive SHA-256 (matched official release `checksums.txt`): **`739e78c82294520b6079bc8a6ae32a1f9fb95a543092929a53a2fe9ab7383016`**.
- Binary SHA-256 (matched official release manifest): **`46aaf57c79c30c81dd047f150fcedff065f182369fb9e65a0de4032f91d40005`**.
- Embedded reported version: `victoria-logs-20261113-102731-tags-v1.54.0-0-g6433dae586`.

An ephemeral server was bound to **127.0.0.1:19428**, injected with **three explicitly synthetic** service logs (node-a: crash loop + restart; node-b: healthy). The original Go test client from the **independently applied patch** invoked all five real endpoints, **PASS**:

- `query`: three NDJSON log records, including the exact test "crash loop exit 1".
- `hits`: total **3** over the chosen time bucket.
- `field_names`: includes the real `host` field.
- `field_values`: **node-a=2 / node-b=1**.
- `stats_query`: real JSON/Prometheus-compatible response, **node-a=2 / node-b=1**.

The server was stopped and temporary storage cleaned after the test. **These are genuine provider HTTP results over a deliberately seeded synthetic log dataset**, not real production incidents, user sessions, or a human triage-quality measurement. Official API contract: [VictoriaLogs querying](https://docs.victoriametrics.com/victorialogs/querying/).

## 4. Independent verification and observed test flake

**Independent source replay:** the patch applied to an entirely fresh `git worktree add --detach … b2aae689…`; the original frozen `be62d926…` checkout remained clean. Both Akmatori Go modules were tested from the replay, not just the worktree where the code was authored.

| Check | Exact result |
| --- | --- |
| `git apply --check` / `git diff --check` | **PASS**, exact `b2aae689…` pin |
| Main application `go test ./... -count=1` | **PASS**, full module |
| Gateway `go test -p 1 ./... -count=1` | **PASS**, full module |
| Main and gateway `go vet ./...` | **PASS**, both complete modules |
| Gateway `go test -race` for VictoriaLogs + registry, `-count=3` | **PASS**, exact independently replayed patch |
| Main `go test -race` for VictoriaLogs integration, `-count=2` | **PASS**, exact independently replayed patch |
| Official VictoriaLogs v1.54.0 native five-endpoint integration | **PASS**, exact independently replayed patch and verified real binary |

**Non-hidden failure:** one earlier gateway `go test ./... -count=1` **failed** while running concurrently with main Go tests: the **original**, unrelated `internal/ratelimit/TestLimiter_WaitContextTimeout` expected a 100-ms deadline but measured about **132.56 ms**. That is a timing sensitivity observed under concurrent test load, **not evidence of a newly introduced VictoriaLogs defect** and not proof of an existing production bug. The exact original timeout test subsequently **passed 100 repeats**; the entire gateway then **passed** `go test -p 1 ./... -count=1`. The initial failure and follow-up are preserved in the evidence receipt. Do not claim every initial test invocation was green.

**Not executed:** an end-to-end operator web build + actual human UI interaction (Node/npm unavailable in this VM), live LLM worker/agent session, remote production VictoriaLogs deployment, production secret management, source maintainer acceptance, or live diagnosis accuracy test. Under the upstream #56 protocol live LLM/user trials are **not required** to substantiate the bounded native capability, and must not be invented.

## 5. Fit gates and next decision

| Admission gate | Status |
| --- | --- |
| `need` | **PASS** — explicit first-party Akmatori #48 request for separate LogsQL provider and concrete crash-loop journal task |
| `mechanism` | **PASS** — new source-integrated gateway tool, DB settings and permission path, discoverable UI schema, operator prompt and independent source-native test |
| `counterfactual` | **PASS for bounded scripted user capability**, now including a *real pinned provider implementation* with controlled synthetic logs; **PENDING** real production utility/human effectiveness |
| `scope` | **PENDING** — upstream Akmatori maintainer design acceptance, production egress/security review, full operator UI/worker CI checks and any deployment-specific API/credential constraints |
| **Overall** | **`OPPORTUNITY_RESEARCH_PENDING / NO_ADMITTED_PATCH` for external contribution**. The 13-file source implementation is an **experimental, reviewable, independently tested patch in OpenSiro research**, not an external Akmatori PR or deployed feature |

**Next exact source-owner decision:** ask the Akmatori #48 maintainer whether this standalone `victoria_logs` tool type, five read-only endpoint contracts, `vl_*` credential fields, limits and security boundaries match the intended native integration. Validate full original CI (worker/web as appropriate) and security before a third-party PR. There is currently no verified `opensiro-contributions/akmatori` fork available for external publication. **Do not open a new upstream batch, silently rewrite historical pins, or report this as an Index-derived / VSM-autonomous product improvement.**
