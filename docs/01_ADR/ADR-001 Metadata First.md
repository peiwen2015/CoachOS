# ADR-001 Metadata First

## Status

Accepted

## Context

The project originally evolved from FIT parsing and Excel generation. As the platform expands toward SQLite, dashboard, AI Coach, and Digital Twin Runner, implementation-first changes can create inconsistent fields, duplicated logic, and unclear ownership.

## Decision

The platform will follow a Metadata-First architecture.

Every new data element must be defined in the Metadata Repository before it is implemented in Excel, LDM, SQLite, parser output, dashboard, or AI Coach behavior.

## Consequences

- Metadata Repository becomes the first checkpoint for all data changes.
- Parser, SQLite, Excel, dashboard, and AI Coach must follow the same governed definitions.
- New features may take slightly longer to design, but long-term consistency improves.

