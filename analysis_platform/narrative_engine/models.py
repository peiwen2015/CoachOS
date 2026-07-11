from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any


@dataclass(frozen=True)
class EvidenceItem:
    signal: str
    value: Any
    interpretation: str


@dataclass(frozen=True)
class Confidence:
    level: str
    score: float
    reason: str


@dataclass(frozen=True)
class NarrativeObject:
    theme: str
    verdict: str
    learning: str
    recommendation: str
    evidence: tuple[EvidenceItem, ...]
    confidence: Confidence
    rule_codes: tuple[str, ...]
    period_type: str
    period_start: str
    period_end: str

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        data["evidence"] = [asdict(item) for item in self.evidence]
        data["confidence"] = asdict(self.confidence)
        data["rule_codes"] = list(self.rule_codes)
        return data
