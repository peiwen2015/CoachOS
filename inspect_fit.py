#!/usr/bin/env python3
from __future__ import annotations

import argparse
import collections
import datetime as dt
import json
import struct
from pathlib import Path


BASE_TYPES = {
    0x00: ("enum", 1, False),
    0x01: ("sint8", 1, True),
    0x02: ("uint8", 1, False),
    0x83: ("sint16", 2, True),
    0x84: ("uint16", 2, False),
    0x85: ("sint32", 4, True),
    0x86: ("uint32", 4, False),
    0x07: ("string", 1, None),
    0x88: ("float32", 4, None),
    0x89: ("float64", 8, None),
    0x0A: ("uint8z", 1, False),
    0x8B: ("uint16z", 2, False),
    0x8C: ("uint32z", 4, False),
    0x0D: ("byte", 1, None),
    0x8E: ("sint64", 8, True),
    0x8F: ("uint64", 8, False),
    0x90: ("uint64z", 8, False),
}

MESG_NAMES = {
    0: "file_id",
    18: "session",
    19: "lap",
    20: "record",
    21: "event",
    23: "device_info",
    34: "activity",
    49: "file_creator",
    72: "training_file",
    78: "hrv",
    79: "length",
    101: "length",
    104: "activity_goals",
    105: "software",
    113: "monitoring",
    127: "connectivity",
    140: "accelerometer_data",
    141: "magnetometer_data",
    142: "barometer_data",
    145: "set",
    147: "field_description",
    148: "developer_data_id",
    162: "timestamp_correlation",
    206: "field_description",
    207: "developer_data_id",
    208: "magnetometer_data",
    209: "barometer_data",
    216: "time_in_zone",
    229: "split",
    258: "segment_lap",
    312: "dive_summary",
}


def read_int(raw: bytes, signed: bool, endian: str) -> int:
    fmts = {
        (1, False): "B",
        (1, True): "b",
        (2, False): "H",
        (2, True): "h",
        (4, False): "I",
        (4, True): "i",
        (8, False): "Q",
        (8, True): "q",
    }
    return struct.unpack(endian + fmts[(len(raw), signed)], raw)[0]


def decode_value(raw: bytes, base_type: int, endian: str):
    base_type &= 0x1F | 0x80
    name, unit_size, signed = BASE_TYPES.get(base_type, ("unknown", 1, None))
    if name == "string":
        return raw.split(b"\x00", 1)[0].decode("utf-8", "replace")
    if name == "byte" or name == "unknown":
        return raw.hex()
    if len(raw) == unit_size:
        if name.startswith("float"):
            return struct.unpack(endian + ("f" if unit_size == 4 else "d"), raw)[0]
        return read_int(raw, bool(signed), endian)
    values = []
    for i in range(0, len(raw), unit_size):
        chunk = raw[i : i + unit_size]
        if len(chunk) == unit_size:
            if name.startswith("float"):
                values.append(struct.unpack(endian + ("f" if unit_size == 4 else "d"), chunk)[0])
            else:
                values.append(read_int(chunk, bool(signed), endian))
    return values


def parse_fit(path: Path):
    data = path.read_bytes()
    header_size = data[0]
    data_size = struct.unpack_from("<I", data, 4)[0]
    pos = header_size
    end = header_size + data_size
    defs = {}
    counts = collections.Counter()
    field_defs_by_mesg = collections.defaultdict(collections.Counter)
    dev_field_usage = collections.Counter()
    developer_ids = {}
    field_descriptions = {}
    sample_values = collections.defaultdict(list)
    unknown_mesgs = collections.Counter()
    errors = []

    while pos < end:
        rec_header = data[pos]
        pos += 1
        if rec_header & 0x80:
            local_num = (rec_header >> 5) & 0x03
            is_definition = False
            has_dev_fields = False
        else:
            local_num = rec_header & 0x0F
            is_definition = bool(rec_header & 0x40)
            has_dev_fields = bool(rec_header & 0x20)

        if is_definition:
            reserved = data[pos]
            arch = data[pos + 1]
            endian = ">" if arch else "<"
            global_num = struct.unpack_from(endian + "H", data, pos + 2)[0]
            n_fields = data[pos + 4]
            pos += 5
            fields = []
            for _ in range(n_fields):
                field_num, size, base_type = data[pos], data[pos + 1], data[pos + 2]
                fields.append((field_num, size, base_type))
                pos += 3
            dev_fields = []
            if has_dev_fields:
                n_dev_fields = data[pos]
                pos += 1
                for _ in range(n_dev_fields):
                    field_num, size, dev_index = data[pos], data[pos + 1], data[pos + 2]
                    dev_fields.append((field_num, size, dev_index))
                    pos += 3
            defs[local_num] = {
                "global_num": global_num,
                "endian": endian,
                "fields": fields,
                "dev_fields": dev_fields,
            }
            continue

        definition = defs.get(local_num)
        if not definition:
            errors.append(f"Missing definition for local message {local_num} at byte {pos - 1}")
            break

        global_num = definition["global_num"]
        endian = definition["endian"]
        mesg_name = MESG_NAMES.get(global_num, f"mesg_{global_num}")
        counts[(global_num, mesg_name)] += 1
        if global_num not in MESG_NAMES:
            unknown_mesgs[global_num] += 1

        message = {}
        for field_num, size, base_type in definition["fields"]:
            raw = data[pos : pos + size]
            pos += size
            field_defs_by_mesg[(global_num, mesg_name)][field_num] += 1
            message[field_num] = decode_value(raw, base_type, endian)

        dev_values = []
        for field_num, size, dev_index in definition["dev_fields"]:
            raw = data[pos : pos + size]
            pos += size
            key = (dev_index, field_num)
            dev_field_usage[key] += 1
            dev_values.append((key, raw.hex()))
            if len(sample_values[key]) < 5:
                sample_values[key].append(raw.hex())

        if global_num == 207:
            idx = message.get(3)
            developer_ids[idx] = {
                "developer_id": message.get(0),
                "application_id": message.get(1),
                "manufacturer_id": message.get(2),
                "application_version": message.get(4),
            }
        elif global_num == 206:
            idx = message.get(0)
            field_num = message.get(1)
            if idx is not None and field_num is not None:
                field_descriptions[(idx, field_num)] = {
                    "developer_data_index": idx,
                    "field_definition_number": field_num,
                    "fit_base_type_id": message.get(2),
                    "field_name": message.get(3),
                    "array": message.get(4),
                    "scale": message.get(6),
                    "offset": message.get(7),
                    "units": message.get(8),
                    "native_mesg_num": message.get(14),
                    "native_field_num": message.get(15),
                }

    return {
        "path": str(path),
        "size": len(data),
        "header_size": header_size,
        "data_size": data_size,
        "message_counts": [
            {"global_num": n, "name": name, "count": count}
            for (n, name), count in counts.most_common()
        ],
        "unknown_message_counts": dict(unknown_mesgs),
        "standard_field_numbers": {
            f"{n}:{name}": sorted(counter)
            for (n, name), counter in field_defs_by_mesg.items()
        },
        "developer_ids": developer_ids,
        "developer_fields": [
            {
                **field_descriptions.get(key, {
                    "developer_data_index": key[0],
                    "field_definition_number": key[1],
                    "field_name": None,
                }),
                "count": count,
                "sample_raw_hex": sample_values[key],
            }
            for key, count in dev_field_usage.most_common()
        ],
        "errors": errors,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("fit_file", type=Path)
    parser.add_argument("--json", type=Path)
    args = parser.parse_args()
    result = parse_fit(args.fit_file)
    text = json.dumps(result, indent=2, ensure_ascii=False, default=str)
    if args.json:
        args.json.write_text(text + "\n")
    print(text)


if __name__ == "__main__":
    main()
