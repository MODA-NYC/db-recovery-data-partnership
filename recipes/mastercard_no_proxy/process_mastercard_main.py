""" main function to call process_mastercard_manual_run"""
import sys
from sys import stdout
from process_mastercard_manual_run import reduce_csv

if __name__ == "__main__":
    """ runs the reduce CSV function to rename boro and borocode 
    writes the CSV to stdout for bash to process             
    """
    csv_name = sys.argv[1]
    stdout.write(reduce_csv(csv_name))
