from __future__ import annotations


VOICE = {
    "weekly": {
        "CONSISTENCY_IS_BUILDING": "穩定本身，就是訓練能力的一部分。",
        "RECOVERY_IS_TRAINING": "先吸收，才有下一次能真正留下來的刺激。",
        "CAPACITY_IS_EXPANDING": "這不是單次撐出來的量，而是承載能力正在慢慢長出來。",
        "STIMULUS_IS_RETURNING": "刺激正在回來，但真正重要的是把恢復留在它旁邊。",
        "CONTEXT_IS_STILL_FORMING": "先把節奏站穩，這週最重要的是讓基準開始成形。",
        "RHYTHM_IS_SLIPPING": "這週最值得留意的，不是單次表現，而是節奏開始有點鬆掉了。",
        "RECOVERY_MARGIN_IS_THIN": "這週的提醒很簡單：刺激上來了，恢復空間也要一起長出來。",
    },
    "monthly": {
        "CONSISTENCY_IS_BUILDING": "這個月最有價值的，不是某一次特別亮眼，而是整體節奏仍然穩穩往前。",
        "RECOVERY_IS_TRAINING": "這個月最大的價值，不是跑得更多，而是把恢復重新放回訓練的一部分。",
        "CAPACITY_IS_EXPANDING": "這個月不是單純加量，而是在證明你可以承接更高一級的訓練壓力。",
        "STIMULUS_IS_RETURNING": "這個月開始把刺激慢慢帶回來，重點不是一次補滿，而是回得剛剛好。",
        "CONTEXT_IS_STILL_FORMING": "這個月先不用急著下重結論，先讓它把自己的節奏說清楚。",
        "RHYTHM_IS_SLIPPING": "這個月值得留意的，不只是負荷下降，而是整體訓練節奏開始一起往下掉。",
        "RECOVERY_MARGIN_IS_THIN": "這個月真正要小心的，不是你做不到，而是恢復是否已經落後於刺激。",
    },
    "journey": {
        "CONSISTENCY_IS_BUILDING": "這一章真正留下來的，不是單一數字，而是穩定正在慢慢變成你的能力。",
        "RECOVERY_IS_TRAINING": "這一章開始理解，恢復不是停下來，而是為了走得更遠。",
        "CAPACITY_IS_EXPANDING": "這一章最重要的，不是更累，而是你開始有能力承接更大的訓練量。",
        "STIMULUS_IS_RETURNING": "這一章不再只是吸收，而是重新把刺激帶回旅程裡。",
        "CONTEXT_IS_STILL_FORMING": "這一章還在長出自己的輪廓，先不要急著替它下最後定義。",
        "RHYTHM_IS_SLIPPING": "這一章提醒你的，不是退步，而是節奏需要被重新找回來。",
        "RECOVERY_MARGIN_IS_THIN": "這一章真正需要被記住的，是刺激上來後，恢復也得一起被照顧。",
    },
}


VERDICTS = {
    "weekly": {
        "ON_TRACK": "節奏穩住了",
        "INTENTIONAL_RECOVERY": "吸收週",
        "CONTROLLED_BUILD": "負荷正在拉高",
        "QUALITY_RETURNING": "刺激慢慢回來了",
        "DETRAINING_RISK": "節奏開始鬆了",
        "OVERLOAD_RISK": "刺激偏高",
        "INSUFFICIENT_CONTEXT": "先穩住節奏",
    },
    "monthly": {
        "ON_TRACK": "正常",
        "INTENTIONAL_RECOVERY": "吸收月",
        "CONTROLLED_BUILD": "負荷建構",
        "QUALITY_RETURNING": "這個月在把刺激帶回來",
        "DETRAINING_RISK": "這個月值得留意",
        "OVERLOAD_RISK": "這個月壓力偏高",
        "INSUFFICIENT_CONTEXT": "這個月先觀察",
    },
    "journey": {
        "ON_TRACK": "穩定累積",
        "INTENTIONAL_RECOVERY": "吸收調整",
        "CONTROLLED_BUILD": "負荷建構",
        "QUALITY_RETURNING": "重新加入刺激",
        "DETRAINING_RISK": "需要重新找回節奏",
        "OVERLOAD_RISK": "恢復要跟上",
        "INSUFFICIENT_CONTEXT": "章節輪廓仍在形成",
    },
}


RECOMMENDATIONS = {
    "weekly": {
        "MAINTAIN_CURRENT_RHYTHM": "下週，只做一件事：先把現在的節奏留下來，不急著加碼。",
        "REINTRODUCE_QUALITY_GRADUALLY": "下週，只做一件事：把一點清楚的刺激慢慢拉回來，不需要一次補滿。",
        "HOLD_BEFORE_NEXT_INCREASE": "下週，只做一件事：先把這一波建構吃下來，再決定要不要往上推。",
        "KEEP_RECOVERY_AROUND_QUALITY": "下週，只做一件事：品質課旁邊一定要留恢復，不要只記得刺激。",
        "PROTECT_RECOVERY": "下週，只做一件事：先把恢復擺前面，讓這週的刺激真正被吸收。",
        "RESTORE_TRAINING_RHYTHM": "下週，只做一件事：先把規律找回來，比追數字更重要。",
        "GATHER_MORE_CONTEXT": "下週，只做一件事：把訓練節奏站穩，讓更多判斷有基礎可依。",
    },
    "monthly": {
        "MAINTAIN_CURRENT_RHYTHM": "下個月，我希望你把現在這個節奏穩穩延續下去。",
        "REINTRODUCE_QUALITY_GRADUALLY": "下個月，我希望你慢慢把品質刺激帶回來，不必一次補足。",
        "HOLD_BEFORE_NEXT_INCREASE": "下個月，我希望你先守住這次建構，再決定是否進一步加碼。",
        "KEEP_RECOVERY_AROUND_QUALITY": "下個月，我希望你把恢復排在品質課旁邊，而不是排在它後面。",
        "PROTECT_RECOVERY": "下個月，我希望你先把恢復留出來，再談下一次推進。",
        "RESTORE_TRAINING_RHYTHM": "下個月，我希望你先把穩定訓練的節奏找回來。",
        "GATHER_MORE_CONTEXT": "下個月，我希望你先累積更穩定的節奏，再替這個階段下判斷。",
    },
    "journey": {
        "MAINTAIN_CURRENT_RHYTHM": "下一章，先把現在的穩定累積留下來。",
        "REINTRODUCE_QUALITY_GRADUALLY": "下一章，可以慢慢把刺激帶回來。",
        "HOLD_BEFORE_NEXT_INCREASE": "下一章，先把這次建構沉澱下來。",
        "KEEP_RECOVERY_AROUND_QUALITY": "下一章，讓刺激和恢復一起前進。",
        "PROTECT_RECOVERY": "下一章，先把恢復空間留出來。",
        "RESTORE_TRAINING_RHYTHM": "下一章，先重新找回節奏。",
        "GATHER_MORE_CONTEXT": "下一章，先讓它長出更多輪廓。",
    },
}


def verdict(surface: str, code: str) -> str:
    return VERDICTS[surface][code]


def learning(surface: str, code: str) -> str:
    return VOICE[surface][code]


def recommendation(surface: str, code: str) -> str:
    return RECOMMENDATIONS[surface][code]
