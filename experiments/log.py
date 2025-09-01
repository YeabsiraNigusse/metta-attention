from path import Path
from datetime import datetime
import csv
import json
import os
import re

# -----------------------
# State (replaces class attrs)
# -----------------------
def init_logger_state():
    return {
        "start_logger": False,
        "logging_directory": None,  # Path
        "setting_path": None,       # Path
        "csv_path": None,           # Path
        "directory_arg": "",        # str passed into start_logger
    }

# LOGGER_STATE = init_logger_state()

# -----------------------
# parse_path  (your Final Improved Version)
# -----------------------
def parse_path(file_path: str) -> Path:
    """
    Validates and resolves the given file path into a Path object.
    """

    # file_path = file_path[1:-1]

    if not isinstance(file_path, str):
        raise TypeError(f"parse_path accepts only str instance {type(file_path)}")

    base_path = Path(__file__).parent.parent
    path_str = base_path / file_path[1:-1]

    if not path_str.exists() or not path_str.is_dir() or not os.access(path_str, os.R_OK):
        raise ValueError(f"{path_str} can not be resolved")

    return path_str

# -----------------------
# create_file_path  (your Final Improved Version)
# -----------------------
def create_file_path(file_path: str) -> dict:
    """
    Creates output directory inside the given path and returns file paths.
    """
    logging_directory = parse_path(file_path)
    if not isinstance(logging_directory, Path):
        raise TypeError("Invalid type for logging directory")

    log_dir = logging_directory / "output"

    if not log_dir.exists():
        log_dir.mkdir()

    return {
        "setting_path": log_dir / "settings.json",
        "csv_path": log_dir / "output.csv"
    }

# -----------------------
# start_logger  (your Step 3 version, with directory_arg added to state)
# -----------------------
def start_logger(directory: str):
    """
    Initializes logger state, prepares file paths, clears old logs/settings.
    Returns a new logger state dict.
    """
    # Resolve directory
    logging_directory = parse_path(str(directory))

    # Create output directory & paths
    log_dir = logging_directory / "output"
    if not log_dir.exists():
        log_dir.mkdir()

    setting_path = log_dir / "settings.json"
    csv_path = log_dir / "output.csv"

    # --- Clear or initialize CSV file ---
    # Always rewrite the header, so old content is discarded.
    with open(csv_path, "w", encoding="utf-8") as f:
        f.write("timestamp,pattern,sti,lti\n")

    # --- Clear settings.json if it exists (optional, safe reset) ---
    if setting_path.exists():
        setting_path.write_text("")

    # Return logger state explicitly (instead of mutating a class)
    global LOGGER_STATE
    LOGGER_STATE = {
        "start_logger": True,
        "logging_directory": logging_directory,
        "setting_path": setting_path,
        "csv_path": csv_path,
        "directory_arg": str(directory),  # keep the original arg for write_to_csv(...)
    }
    return '()'



# -----------------------
# save_params  (your Step 3 version)
# -----------------------
def save_params(params):
    """
    Saves parameters into settings.json.
    Requires an active logger state (from start_logger).
    Returns updated state.
    """
    global LOGGER_STATE
    state = LOGGER_STATE

    if not state.get("start_logger", False):
        return   # do nothing if logger not started

    params = str(params)
    settings = parse_setting(params)

    if len(settings.keys()) == 0: return

    csv_path = state['setting_path']

    with csv_path.open("w") as f:
        json.dump(settings, f, indent=4)

def parse_setting(s):
    """
    Convert a string like:
        ((AF_SIZE 0.2) (MIN_AF_SIZE 500) ... (SPREADING_FILTER (MemberLink (Type "MemberLink"))))
    into a dict mapping predicate -> value (as strings).

    Handles:
      - Arbitrary whitespace/newlines
      - Nested values like (MemberLink (Type "MemberLink"))
      - Scientific notation, floats, ints, quoted strings
     """

    if not s or not s.strip():
         return {}

    s = s.strip()
    if not (s.startswith("(") and s.endswith(")")):
         raise ValueError("Input must be a single parenthesized S-expression.")

     # Strip the single outermost pair of parentheses
    content = s[1:-1].strip()

     # Collect top-level items: (PRED VALUE...)
    pairs = []
    depth = 0
    start = None
    for i, ch in enumerate(content):
         if ch == "(":
             if depth == 0:
                 start = i
             depth += 1
         elif ch == ")":
             depth -= 1
             if depth == 0 and start is not None:
                 pairs.append(content[start:i+1])
                 start = None

    if depth != 0:
         raise ValueError("Unbalanced parentheses in input.")

    result: dict[str, str] = {}
    for item in pairs:
         # Remove item's outer parens: (PRED <value...>) -> "PRED <value...>"
         body = item[1:-1].strip()
         if not body:
             continue
         # Split only on the first run of whitespace to separate predicate and value
         parts = re.split(r"\s+", body, maxsplit=1)
         pred = parts[0]
         val = parts[1].strip() if len(parts) > 1 else ""
         result[pred] = val

    return result

def write_to_csv(snapshot):
    """
    Writes simulation snapshot data to CSV in the format:
    timestamp,pattern,sti,lti

    snapshot: can be:
        - a list/tuple of dicts or 3-element tuples/lists
        - a string like '((Ants (AV 7007.007007007007 7007.007007007007 0)))'
    """
    global LOGGER_STATE
    state = LOGGER_STATE

    if not state.get("start_logger", False):
        return  # Logger not started

    csv_path = state.get("csv_path")
    if csv_path is None:
        raise ValueError("Logger state is missing csv_path.")

    # If snapshot is a string, parse it into list of entries
    if isinstance(snapshot, str):
        snapshot = snapshot.strip()
        if not (snapshot.startswith("(") and snapshot.endswith(")")):
            raise ValueError("Invalid snapshot string format")
        snapshot = snapshot[1:-1].strip()  # Remove outer parentheses

        # Collect top-level entries
        entries = []
        depth = 0
        start = None
        for i, ch in enumerate(snapshot):
            if ch == "(":
                if depth == 0:
                    start = i
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0 and start is not None:
                    entries.append(snapshot[start:i+1])
                    start = None
        if depth != 0:
            raise ValueError("Unbalanced parentheses in snapshot string")

        # Parse entries into dicts
        parsed_snapshot = []
        for item in entries:
            # item looks like: (Ants (AV 7007.007007007007 7007.007007007007 0))
            body = item[1:-1].strip()
            parts = re.split(r"\s+", body, maxsplit=1)
            entity = parts[0]
            value1, value2 = 0, 0
            if len(parts) > 1:
                # parts[1] looks like: (AV 7007.007007007007 7007.007007007007 0)
                inner = parts[1].strip()
                inner = inner[1:-1].strip()  # remove parentheses
                inner_parts = inner.split()[1:]  # skip "AV"
                if len(inner_parts) >= 2:
                    value1 = float(inner_parts[0])
                    value2 = float(inner_parts[1])
            parsed_snapshot.append({"entity": entity, "value1": value1, "value2": value2})
        snapshot = parsed_snapshot

    # Ensure snapshot is a list/tuple now
    if not isinstance(snapshot, (list, tuple)):
        raise TypeError(f"snapshot must be a list/tuple or parsable string, got {type(snapshot)}")

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")

    # Check if the file exists or is empty to write header
    write_header = not csv_path.exists() or csv_path.stat().st_size == 0

    with csv_path.open("a", newline="") as f:
        writer = csv.writer(f, delimiter=",")
        if write_header:
            writer.writerow(["timestamp", "pattern", "sti", "lti"])
        for entry in snapshot:
            if isinstance(entry, dict):
                entity = entry.get("entity", "")
                value1 = entry.get("value1", 0)
                value2 = entry.get("value2", 0)
            elif isinstance(entry, (list, tuple)) and len(entry) == 3:
                entity, value1, value2 = entry
            else:
                raise ValueError(f"Invalid snapshot entry format: {entry}")

            writer.writerow([timestamp, entity, value1, value2])

    print(f"Wrote {len(snapshot)} rows to {csv_path}")
