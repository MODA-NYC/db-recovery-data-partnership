""" Main function for Bash to call reduce CSV
Outputs as a string for bash
"""
import sys
from sys import stdout
from process_mastercard_manual_run import reduce_csv

if __name__ == "__main__":
    csv_name = sys.argv[1]
    stdout.write(reduce_csv(csv_name).to_string())
