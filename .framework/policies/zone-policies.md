# Zone Policies

**Version:** 1.0
**Status:** Active
**Principles implemented:** P1, P3, P4, P5, P8, P9, P10, P12
**Dependencies:**
  Agent Design Standards v1.0
  Tool Grammar v0.3
  Audit Log Schema v1.0
  Naming Conventions v0.1
**Last Updated:** 2026-03-04

---

## Purpose

This document defines the zones through which all work moves in this
framework. Each zone has a defined:

- Purpose and scope
- Entry conditions (what must be true before work enters)
- Authority model (who owns decisions in this zone)
- Agent activation pattern (which agents operate here)
- Exit conditions and gate (what triggers the transition to the next zone)
- Failure handling (what happens when work cannot proceed)

Zones are not optional stages. They are the framework's primary
mechanism for separating concerns, enforcing authority boundaries,
and ensuring that work does not advance until it is genuinely ready.

**An important constraint: agents do not know what zone they are in.**
Zone membership is a governance concept for humans and the Policy Engine.
Agents receive task-specific context cards and task-scoped tools. The
zone policy governs which cards and tools they receive — but the agent
itself is never told "you are in Zone 4." This is by design: agents
that know their zone can route around zone gates.
