#http://dataconomy.com/2015/03/14-best-python-pandas-features/
import pytest, pandas as pd

@pytest.fixture
def series_values():
  return [2, 9, 0, 1]

@pytest.fixture
def series(series_values):
  return pd.Series(series_values)

def test_pandas_series(series, series_values):
  assert series.values.tolist() == series_values

def test_pandas_series_index(series):
  assert all(series.index == range(0, 4))

def test_pandas_series_custom_index(series):
  series.index = ['a', 'b', 'c', 'd']
  assert series.index[0] == 'a'
  assert series.index[1] == 'b'
  assert series.index[2] == 'c'
  assert series.index[3] == 'd'

def test_pandas_series_custom_index(series):
  series.index = ['a', 'b', 'c', 'd']
  assert series.loc['b'] == series.iloc[1]

def test_series_prefix(series):
  assert series.add_prefix("something").index[0] == "something0"

@pytest.fixture
def df_data():
  return {'Names':['John', 'Ryan', 'Emily'],
          'Standard': [7, 8, 9], 
          'Age': [25, 25, 27], 
          'Subject': ['English', 'Math', 'Science']}

@pytest.fixture
def df(df_data):
  df = pd.DataFrame(df_data)
  return df
  
def test_df_head(df, df_data):
  d_head = {key:dict(enumerate(value[0:2])) for key, value in df_data.items()}
  assert df.head(2).to_dict() == d_head

def test_df_rename_column(df):
  first_col = df.columns[0]
  new_name = 'something else'
  df.rename(columns={first_col:new_name}, inplace=True)
  assert df.columns[0] == new_name

def test_df_map_on_column(df, df_data):
  from functools import partial
  from operator import add
  incr = partial(add, 1)
  new_vals = list(map(incr, df_data['Standard']))
  mapped_vals = df.Standard.map(lambda n: n + 1)
  assert all(new_vals == mapped_vals)

def test_df_apply(df):
  cols_of_interest = ['Names', 'Subject']
  df_applied = df[cols_of_interest].apply(lambda s: 'nothing')
  assert all(df_applied == ['nothing'] * 2)
  assert isinstance(df_applied.Names, str)
  assert isinstance(df_applied.Subject, str)

def test_df_apply(df):
  cols_of_interest = ['Names', 'Subject']
  df_applied = df[cols_of_interest].applymap(lambda s: 'nothing')
  assert all(df_applied.Names == ['nothing'] * 3)
  assert all(df_applied.Subject == ['nothing'] * 3)

def test_df_shape(df, df_data):
  keys = len(df_data)
  random_column = list(df_data.keys())[0]
  random_column_values = df_data[random_column]
  len_data = len(random_column_values)
  assert df.shape == (len_data, keys)

def test_df_unique(df, df_data):
  source_uniq_age = []
  for age in df_data['Age']:
    if not age in source_uniq_age:
      source_uniq_age.append(age)
  source_unique_ages = df_data['Age']
  df_unique_ages = df.Age.unique()
  assert all(df_unique_ages == source_uniq_age)

def test_crosstab(df, df_data):
  cross_df = pd.crosstab(df.Age, df.Subject)
  for age in df['Age']:
    for subj in df['Subject']:
      field_values = df[(df['Subject'] == subj) & 
                        (df['Age'] == age)].shape[0]
      assert cross_df.loc[age][subj] == field_values

def test_crosstab_2():
  s1 = pd.Series([1, 1, 1, 2, 33])
  s2 = pd.Series([1, 1, 1, 1])
  cross_df = pd.crosstab(s1, s2)
  assert cross_df.loc[1][1] == 3
  assert cross_df.loc[2][1] == 1
  with pytest.raises(KeyError):
    dump = cross_df.loc[33]

#print(s1.index)
#s1.index = ['a', 'b', 'c', 'd']
#print(s1.index)
#print(s1['d'])
#data = {'Names':['John', 'Ryan', 'Emily'],
#        'Standard': [7, 8, 9], 
#        'Subject': ['English', 'Math', 'Science']}
#df = pd.DataFrame(data, index=['s1', 's2', 's3'],
#                        columns=['Names', 'Standard', 'Subject'])
#print(df)
#print(df.Names)
#
