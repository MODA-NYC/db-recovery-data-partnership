import pandas as pd

## remove duplicates in attendance files
df_att = pd.read_csv('input/attendance_raw.csv',
                     header=None,
                     names=['Date', 'Building', 'Count', 'Type', 'Method', 'State', 'Country'])

print(df_att.shape)

# sometimes counts are updated in later versions of the file. keep the latest count
df_att.drop_duplicates(subset=['Date', 'Building', 'Type', 'Method', 'State', 'Country'],
                   keep='last',
                   inplace=True)

print(df_att.shape)

df_att.to_csv('input/attendance_raw.csv',
              index=False,
              header=False)

df_att.to_csv('input/attendance_raw_named.csv',
              index=False)


## remove duplicates in membership files
df_mem = pd.read_csv('input/membership_raw.csv',
                     header=None,
                     names=['Date', 'Count', 'Transaction_Type'])
# remove duplicates
# sometimes counts are updated in later versions of the file. keep the latest count
df_mem.drop_duplicates(subset=['Date', 'Transaction_Type'],
                   keep='last',
                   inplace=True)

df_mem.to_csv('input/membership_raw.csv',
              index=False,
              header=False)
              
df_mem.to_csv('input/membership_raw_named.csv',
              index=False)