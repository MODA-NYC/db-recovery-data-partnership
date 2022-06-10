from process_mastercard_manual_run import reduce_csv
from sys import stdout
if __name__ == "__main__":
    csv_name = sys.argv[1]
    stdout(reduce_csv(csv_name))