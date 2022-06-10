#taken from https://stackoverflow.com/questions/53028454/splitting-10gb-csv-file-into-equal-parts-without-reading-into-memory

import sys
import csv
import shutil
from pathlib import Path

# your input file 
in_csvfile = sys.stdin

# reader, that would read file for you line-by-line
reader = csv.DictReader(in_csvfile)

# number of current line read
num = 0

# number of output file
output_file_num = 1

# your output file
out_csvfile = open(Path.cwd() / 'output' / '{}_{}.csv'.format('mastercard', output_file_num), "w")

# writer should be constructed in a read loop, 
# because we need csv headers to be already available 
# to construct writer object
writer = None

for row in reader:
    num += 1

    # Here you have your data line in a row variable

    # If writer doesn't exists, create one
    if writer is None:
        writer = csv.DictWriter(
            out_csvfile, 
            fieldnames=row.keys(), 
            delimiter=",", quotechar='"', escapechar='"', 
            lineterminator='\n', quoting=csv.QUOTE_NONNUMERIC
        )

    # Write a row into a writer (out_csvfile, remember?)
    writer.writerow(row)

    # If we got a 10000 rows read, save current out file
    # and create a new one
    if num > 100000:
        output_file_num += 1
        out_csvfile.close()
        writer = None

        # create new file
        out_csvfile = open(Path.cwd() / 'output' / '{}_{}.csv'.format("mastercard", output_file_num), "w")
    
        # reset counter
        num = 0 

# Closing the files
in_csvfile.close()
out_csvfile.close()