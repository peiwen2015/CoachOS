from __future__ import annotations

from ..models import NarrativeObject
from .. import voice


def adapt(obj: NarrativeObject) -> dict:
    return {
        "surface": "weekly",
        "verdict": voice.verdict("weekly", obj.verdict),
        "learning": voice.learning("weekly", obj.learning),
        "recommendation": voice.recommendation("weekly", obj.recommendation),
        "evidence": [item.interpretation for item in obj.evidence],
        "confidence": obj.confidence.level,
        "rule_codes": list(obj.rule_codes),
    }
