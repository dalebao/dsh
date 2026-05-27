# Harness measurement framework

layers:
  local:
    - name: hook_interceptions
      description: "Hook blocks by L0/L1/L2 category"
      type: counter
    - name: agent_self_heal_rate
      description: "Fraction of hook blocks resolved without human"
      type: ratio
    - name: fix_loop_count
      description: "Submit-attempt cycles per task"
      type: distribution

  ci:
    - name: first_pass_green_rate
      description: "CI runs that pass on first attempt"
      type: ratio
    - name: preventable_failure_rate
      description: "CI failures catchable by harness"
      type: ratio

  efficiency:
    - name: parallel_task_capacity
      description: "Tasks a single human can supervise concurrently"
      type: gauge

composite:
  - name: aci
    full_name: "AI Collaboration Index"
    description: "Composite maturity score: layers in use × codebase coverage × active sessions"
    dimensions:
      - name: depth
        description: "Harness layers in use (0-3)"
      - name: coverage
        description: "Fraction of codebase under harness"
      - name: scale
        description: "Active agent sessions / automated tasks"
    levels: [basic, effective, deep, comprehensive]
