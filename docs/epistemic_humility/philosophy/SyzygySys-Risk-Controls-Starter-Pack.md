# SyzygySys Risk‑Controls Starter Pack (v0.1)

This pack is drop‑in scaffolding for **LAP::CORE** and human‑only ops:

* **Certainty weights** & **OPA policy gates**
* **JIT‑QVS** (Just‑In‑Time Quiescence & Validation of State) script (Ubuntu)
* **High‑risk runbook checklist**
* **Intent allow‑list** example
* **Calibration dashboard stub (Loki/Grafana)**
* **Certainty header JSON schema** (for completeness)

> Directory map (suggested):

```
syzygysys/
├─ policy/
│  └─ certainty/
│     ├─ weights.json
│     └─ policy.rego
├─ scripts/
│  └─ jitqvs.sh
├─ runbooks/
│  └─ high_risk_change_checklist.md
├─ config/
│  └─ intent_allowlist.example.yaml
├─ dashboards/
│  └─ certainty_calibration.loki.json
└─ schemas/
   └─ certainty_header.schema.json
```

---

## policy/certainty/weights.json

```json
{
  "profiles": {
    "default": {
      "source_reliability": 0.14,
      "analysis_depth": 0.10,
      "history_consistency": 0.08,
      "domain_stability": 0.08,
      "cross_model_consensus": 0.12,
      "external_corroboration": 0.12,
      "logical_integrity": 0.10,
      "linguistic_markers": 0.04,
      "human_alignment": 0.08,
      "time_entropy": 0.06,
      "token_uncertainty": 0.04,
      "tool_use_success": 0.04
    },
    "compliance": {
      "source_reliability": 0.20,
      "analysis_depth": 0.10,
      "history_consistency": 0.08,
      "domain_stability": 0.10,
      "cross_model_consensus": 0.10,
      "external_corroboration": 0.16,
      "logical_integrity": 0.10,
      "linguistic_markers": 0.04,
      "human_alignment": 0.07,
      "time_entropy": 0.03,
      "token_uncertainty": 0.01,
      "tool_use_success": 0.01
    },
    "medical": {
      "source_reliability": 0.22,
      "analysis_depth": 0.10,
      "history_consistency": 0.07,
      "domain_stability": 0.10,
      "cross_model_consensus": 0.10,
      "external_corroboration": 0.18,
      "logical_integrity": 0.10,
      "linguistic_markers": 0.03,
      "human_alignment": 0.07,
      "time_entropy": 0.02,
      "token_uncertainty": 0.00,
      "tool_use_success": 0.01
    },
    "finance": {
      "source_reliability": 0.18,
      "analysis_depth": 0.12,
      "history_consistency": 0.10,
      "domain_stability": 0.08,
      "cross_model_consensus": 0.12,
      "external_corroboration": 0.14,
      "logical_integrity": 0.10,
      "linguistic_markers": 0.04,
      "human_alignment": 0.07,
      "time_entropy": 0.03,
      "token_uncertainty": 0.01,
      "tool_use_success": 0.01
    }
  }
}
```

---

## policy/certainty/policy.rego

```rego
package syzygy.certainty

# Tier mapping thresholds (align with whitepaper)
thresholds := {
  "Unknown": 0.10,
  "Speculative": 0.30,
  "Plausible": 0.55,
  "Probable": 0.75,
  "HighConfidence": 0.90,
  "Verified": 1.01
}

# Compute tier label from score
get_tier(score) = tier {
  score < thresholds["Unknown"]; tier := "Unknown"
} else = tier {
  score < thresholds["Speculative"]; tier := "Speculative"
} else = tier {
  score < thresholds["Plausible"]; tier := "Plausible"
} else = tier {
  score < thresholds["Probable"]; tier := "Probable"
} else = tier {
  score < thresholds["HighConfidence"]; tier := "HighConfidence"
} else = tier {
  tier := "Verified"
}

# Action gating policy
# Input example:
# {
#   "risk_class": "low|medium|high|destructive",
#   "certainty": {"score": 0.82},
#   "break_glass": false
# }

default allow := false
require_hitl := false
must_abstain := false

allow {
  not must_abstain
  gate_passed
}

# Abstain on high/destructive if score below strong thresholds
must_abstain {
  rc := input.risk_class
  rc == "high"; input.certainty.score < 0.55  # below Probable
} else {
  rc := input.risk_class
  rc == "destructive"; input.certainty.score < 0.75  # below HighConfidence
}

# HITL: enforce review on high/destructive unless Verified or break-glass
require_hitl {
  rc := input.risk_class
  rc == "high"; input.certainty.score < 0.90
} else {
  rc := input.risk_class
  rc == "destructive"; input.certainty.score < 0.90
}

# Gate passing logic
gate_passed {
  rc := input.risk_class
  s := input.certainty.score
  rc == "low"; s >= 0.30  # Plausible+
} else {
  rc := input.risk_class
  s := input.certainty.score
  rc == "medium"; s >= 0.55 # Probable+
} else {
  rc := input.risk_class
  s := input.certainty.score
  rc == "high"; s >= 0.75   # HighConfidence+
} else {
  rc := input.risk_class
  s := input.certainty.score
  rc == "destructive"; s >= 0.90 # Verified/near‑Verified
} or {
  input.break_glass == true
}
```

---

## scripts/jitqvs.sh (Ubuntu, safe skeleton)

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

log(){ printf "[JIT-QVS] %s\n" "$*"; }
err(){ printf "[JIT-QVS][ERR] %s\n" "$*" 1>&2; }
need(){ command -v "$1" >/dev/null || { err "missing: $1"; exit 1; }; }

trap 'err "failure at line $LINENO"; thaw_all || true; resume_services || true; restore_firewall || true' ERR

TS=$(date -u +%Y%m%dT%H%M%SZ)
ART=/var/lib/jitqvs/$TS; mkdir -p "$ART"

preflight(){
  need systemctl; need awk; need sha256sum; need findmnt
  systemctl --failed --no-legend | tee "$ART/systemd_failed.txt"; [[ ! -s "$ART/systemd_failed.txt" ]]
  journalctl -p err -S -5m -n 200 >"$ART/journal_err.txt" || true
  df -PTh >"$ART/df.txt"
  dpkg --audit >"$ART/dpkg_audit.txt" || true
  log "preflight ok"
}

stop_timers(){
  for t in apt-daily.timer apt-daily-upgrade.timer; do systemctl stop "$t" 2>/dev/null || true; done
}

snapshot_fw(){
  if command -v nft >/dev/null; then nft list ruleset >"$ART/nft.before" || true; fi
}

maintenance_fw(){ :; } # hook: apply restricted rules if desired
restore_firewall(){ if [[ -f "$ART/nft.before" ]]; then nft -f "$ART/nft.before" || true; fi }

quiesce_services(){
  ss -lntup >"$ART/listeners.before" || true
  # Stop risky units except ssh
  mapfile -t UNITS < <(systemctl list-units --type=service --state=running --no-legend | awk '{print $1}' | grep -Ev '^ssh|systemd|dbus')
  for u in "${UNITS[@]}"; do systemctl stop "$u" 2>/dev/null || true; done
  log "services quiesced"
}

MOUNTS=()
freeze_fs(){
  while read -r tgt type; do
    [[ "$type" =~ ^(tmpfs|proc|sysfs|cgroup|overlay|devpts|debugfs|tracefs)$ ]] && continue
    MOUNTS+=("$tgt")
  done < <(findmnt -rn -o TARGET,TYPE)
  need fsfreeze || { log "fsfreeze not available; skipping fs freeze"; return 0; }
  for m in "${MOUNTS[@]}"; do fsfreeze -f "$m" || true; done
  log "filesystems frozen: ${#MOUNTS[@]}"
}

thaw_all(){
  if [[ ${#MOUNTS[@]} -gt 0 ]]; then for m in "${MOUNTS[@]}"; do fsfreeze -u "$m" || true; done; fi
}

make_snapshot(){
  SNAP_META="$ART/snapshot.meta"
  if command -v lvs >/dev/null; then
    VG=$(vgs --noheadings -o vg_name 2>/dev/null | head -n1 | xargs || true)
    LV=$(lvs --noheadings -o lv_name 2>/dev/null | grep -E '^root$' | head -n1 | xargs || true)
    if [[ -n "$VG" && -n "$LV" ]]; then
      lvcreate -s -n root.jitqvs.$TS -L 2G "/dev/$VG/$LV" | tee -a "$SNAP_META"
    fi
  elif command -v zfs >/dev/null; then
    POOL=$(zpool list -H -o name | head -n1)
    zfs snapshot "$POOL"@jitqvs-$TS | tee -a "$SNAP_META"
  else
    log "no LVM/ZFS; rely on fsfreeze + hypervisor snapshot (QGA hook)"
  fi
}

hash_critical(){
  CRIT=(/etc/ssh/sshd_config /etc/fstab /etc/sudoers /etc/passwd /etc/group /etc/hosts /etc/hostname /etc/resolv.conf /etc/netplan)
  for p in "${CRIT[@]}"; do [[ -e "$p" ]] && find "$p" -type f -maxdepth 1 -print0 | xargs -0 sha256sum; done >"$ART/checksums.sha256" || true
}

validate_state(){
  sshd -t 2>>"$ART/validation.log" || return 1
  systemd-analyze verify /etc/systemd/system/*.service 2>>"$ART/validation.log" || true
  netplan generate 2>>"$ART/validation.log" || true
  dpkg -V 2>>"$ART/validation.log" || true
  log "state validation completed"
}

attest(){
  jq -n --arg ts "$TS" '{ts:$ts, machine:env.MACHINE_ID, artifacts:env.ART}' >"$ART/attestation.json" 2>/dev/null || echo "{\"ts\":\"$TS\"}" >"$ART/attestation.json"
}

resume_services(){
  for u in "${UNITS[@]-}"; do systemctl start "$u" 2>/dev/null || true; done
  ss -lntup >"$ART/listeners.after" || true
}

main(){
  preflight; stop_timers; snapshot_fw; maintenance_fw; quiesce_services; freeze_fs; make_snapshot; hash_critical; validate_state; attest; thaw_all; resume_services; restore_firewall; log "JIT-QVS complete: $ART"
}

main "$@"
```

> **Note:** Dangerous operations are intentionally absent. This script prepares and attests state; actual change scripts should run **after** a green JIT‑QVS pass.

---

## runbooks/high\_risk\_change\_checklist.md

```md
# High‑Risk Change Checklist (Human‑Only or Agent+HITL)

- [ ] Impact assessed; runbook drafted; rollback plan documented.
- [ ] Risk class: High / Destructive. Window approved.
- [ ] Canary validated; Blue/Green candidate healthy.
- [ ] Intent‑diff reviewed (allow‑list only): files, commands, services.
- [ ] 2× HITL reviewers assigned (names/time).
- [ ] **JIT‑QVS**: preflight → quiesce → freeze → snapshot → validate → attest (GREEN).
- [ ] Execute change (canary/green), monitor SLOs.
- [ ] Promote only after tests pass; otherwise rollback snapshot.
- [ ] Post‑change validation + logs attached; attestation archived.
```

---

## config/intent\_allowlist.example.yaml

```yaml
# Only these paths and commands may be touched by the change bundle
paths:
  - /etc/ssh/sshd_config
  - /etc/ssh/ssh_config
  - /etc/systemd/system/*.service
commands:
  - path: /usr/bin/systemctl
    args:
      - restart
      - ssh
  - path: /usr/sbin/sshd
    args:
      - -t
policy:
  deny_outside_targets: true
```

---

## dashboards/certainty\_calibration.loki.json (stub)

```json
{
  "title": "SyzygySys Certainty Calibration",
  "panels": [
    {"type":"timeseries","title":"Certainty Score (p50/p90)","targets":[{"expr":"avg_over_time(certainty_score[1h])"}]},
    {"type":"bargauge","title":"Tier Distribution","targets":[{"expr":"sum by (tier) (count_over_time(certainty_tier[24h]))"}]},
    {"type":"stat","title":"ECE (Est.)","targets":[{"expr":"avg_over_time(certainty_ece[24h])"}]},
    {"type":"stat","title":"Brier Score","targets":[{"expr":"avg_over_time(certainty_brier[24h])"}]}
  ]
}
```

---

## schemas/certainty\_header.schema.json

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CertaintyHeader",
  "type": "object",
  "properties": {
    "certainty": {
      "type": "object",
      "properties": {
        "score": {"type": "number", "minimum": 0, "maximum": 1},
        "tier": {"type": "string", "enum": ["Unknown","Speculative","Plausible","Probable","HighConfidence","Verified"]},
        "grounded": {"type": "boolean"},
        "gates": {
          "type": "object",
          "properties": {
            "abstain": {"type": "boolean"},
            "should_verify": {"type": "boolean"}
          },
          "required": ["abstain","should_verify"]
        },
        "method": {"type": "string"},
        "critical_flags": {"type": "array", "items": {"type": "string"}},
        "notes": {"type": "string"}
      },
      "required": ["score","tier","gates","method"]
    }
  },
  "required": ["certainty"]
}hell yes.

I’ve dropped a ready-to-wire Risk-Controls Starter Pack onto the canvas:

weights.json (profiles), policy.rego (OPA gates),

jitqvs.sh (Ubuntu JIT-quiescence/validation),

high-risk runbook checklist,

intent allow-list example,

Loki/Grafana dashboard stub,

certainty header schema.

Next 3 moves (do now)

Wire into LAP::CORE

Load weights.json; compute score → tier; emit the header.

Call OPA with policy.rego for gate decisions.

Gate destructive ops

Require green JIT-QVS + 2× HITL for risk_class ∈ {high, destructive}.

Enforce intent-diff allow-list before any file write or command exec.

Observability

Log certainty dims + gates to Loki; import the dashboard stub and watch tier drift.

If you want, I can generate a tiny Python adaptor for LAP that:

reads weights, computes penalized HM,

attaches the certainty header,

calls OPA, and

shells out to jitqvs.sh when needed.

Say the word and I’ll drop it in.policy/certainty/weights.json, policy.rego

scripts/jitqvs.sh (JIT-Quiescence & Validation of State)

runbooks/high_risk_change_checklist.md

config/intent_allowlist.example.yaml

dashboards/certainty_calibration.loki.json

schemas/certainty_header.schema.json

README.md with quick-start wiring steps
```
