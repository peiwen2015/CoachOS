from __future__ import annotations

from ..models import NarrativeObject
from .. import voice


def adapt(obj: NarrativeObject) -> dict:
    return {
        "surface": "monthly",
        "verdict": voice.verdict("monthly", obj.verdict),
        "learning": voice.learning("monthly", obj.learning),
        "recommendation": voice.recommendation("monthly", obj.recommendation),
        "evidence": [item.interpretation for item in obj.evidence],
        "confidence": obj.confidence.level,
        "rule_codes": list(obj.rule_codes),
    }
