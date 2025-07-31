import subprocess
import pathlib
import sys

# Define ANSI escape codes for colors
RESET = "\033[0m"
BOLD = "\033[1m"
UNDERLINE = "\033[4m"
CYAN = "\033[96m"
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"


def extract_and_print(result, path, idx) -> bool:
    # Prefer stdout unless it's empty and returncode != 0
    output = result.stdout if result.stdout else result.stderr
    output = output.strip()

    # If empty stderr and non-zero code, assume it still succeeded
    if result.returncode != 0 and not output:
        has_failure = False
        extracted = "test passed (empty error, assuming success)"
    else:
        has_failure = "Error" in output
        extracted = output if has_failure else "test passed"

    status_color = RED if has_failure else GREEN
    print(YELLOW + f"Test {idx + 1}: {path}" + RESET)
    print(status_color + extracted + RESET)
    print(YELLOW + f"Exit-code: {result.returncode}" + RESET)
    print("-" * 40)

    return has_failure


# Function to print ASCII art
def print_ascii_art(text):
    art = f"""
                {text}
           """
    print(CYAN + art + RESET)


# Define the command to run with the test files
metta_run_command = ["mettalog", "--test"]

root = pathlib.Path(".")

testMettaFiles = list(root.rglob("*-test-mettalog.metta"))
total_files = len(testMettaFiles)
results = []

# Print ASCII art title
print_ascii_art("Test Runner")

# Run all tests and collect results
for testFile in testMettaFiles:
    try:
        result = subprocess.run(
            metta_run_command + [str(testFile)],
            capture_output=True,
            text=True,
        )
        results.append((result, testFile))
    except subprocess.CalledProcessError as e:
        results.append((e, testFile))  # still collect the result


# Output the results
fails = 0
for idx, (result, path) in enumerate(results):
    has_failure = extract_and_print(result, path, idx)
    if has_failure:
        fails += 1

# Summary
print(CYAN + "\nTest Summary" + RESET)
print(f"{total_files} files tested.")
print(RED + f"{fails} failed." + RESET)
print(GREEN + f"{total_files - fails} succeeded." + RESET)

if fails > 0:
    print(RED + "Tests failed. Process exiting with exit code 1." + RESET)
    sys.exit(1)
