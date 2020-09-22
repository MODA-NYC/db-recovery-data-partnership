import sys
import pandas as pd

# Read input data and lookups, ignoring header information
df = pd.read_csv('input/urban_parks_perception.csv', skiprows=[1])

# Check columns
cols = [
    "StartDate", "Q41", "Q42", "Q43", 
    "Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7", "Q8", "Q9", "Q9_A",
    "Q10_A", "Q10_B", "Q10_C", "Q10_D", "Q10_E",  "Q10_F",
    "Q10_G", "Q10_H", "Q10_I", "Q10_J", "Q10_K", "Q10_L", "Q11",
    "Q11_A", "Q12", "Q13", "Q14", "Q15", "Q16", "Q17",
    "Q18", "Q19_A", "Q19_B", "Q20", "Q21", "Q21_A", "Q22", "Q22_A",
    "Q23", "Q24", "Q25", "Q26", "Q27", "Q28", "Q30", "Q29",
    "Q31", "Q32", "Q33", "Q33_A", "Q34", "Q34_A", "Q35",
    "Q36", "Q37", "Q38", "Q39", "Q40", "Q44", "Q45", "Q45_A",
    "Q46", "Q47", "Q47_A", "Q48", "Q49", "Q50"
]
# Check that all expected columns exist in input data
for col in cols:
    try:
        assert col in df.columns
    except AssertionError as error:
        print(f'{col} is missing')

df[cols].to_csv(sys.stdout, sep='|', index=False)