from __future__ import annotations

from ..models import NarrativeObject
from .. import voice


def adapt(obj: NarrativeObject) -> dict:
    return {
        "surface": "journey",
        "theme": voice.verdict("journey", obj.verdict),
        "learning": voice.learning("journey", obj.learning),
        "next_chapter": voice.recommendation("journey", obj.recommendation),
        "evidence": [item.interpretation for item in obj.evidence],
        "confidence": obj.confidence.level,
        "rule_codes": list(obj.rule_codes),
    }
