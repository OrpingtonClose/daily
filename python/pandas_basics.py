#http://dataconomy.com/2015/03/14-best-python-pandas-features/
#https://www.safaribooksonline.com/library/view/pandas-for-everyone/9780134547046/ch10.xhtml
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

def test_describe_stats_made():
  d = pd.Series([1]*10).describe()
  assert all(d.index == ['count', 'mean', 'std', 'min', '25%', '50%', '75%', 'max'])

def test_stats_describe_values():
  d = pd.Series([1]*10).describe()
  assert d['count'] == 10.0
  assert d['mean'] == 1.0
  assert d['std'] == 0.0
  assert d['min'] == 1.0
  assert d['25%'] == 1.0
  assert d['50%'] == 1.0
  assert d['75%'] == 1.0
  assert d['max'] == 1.0

def test_basic_groupby():
  df = pd.DataFrame([1, 1, 1, 3, 5, 6, 7, 1, 1]).groupby(0)[0].count()
  assert df[1] == 5
  assert df[3] == 1
  assert df[5] == 1
  assert df[6] == 1
  assert df[7] == 1

def test_groupby_regular(df):
  assert all(df.groupby('Age').Subject.sum() == ['EnglishMath', 'Science'])

def test_groupby_agg(df):
  import numpy as np
  aggrs = {'Names': ['count', 'sum', np.max]}
  grouped = df.groupby('Age').agg(aggrs)
  names = grouped['Names']
  assert names['count'].loc[25] == 2
  assert names['count'].loc[27] == 1
  assert names['sum'].loc[25] == 'JohnRyan'
  assert names['sum'].loc[27] == 'Emily'
  assert names['amax'].loc[25] == 'Ryan'
  assert names['amax'].loc[27] == 'Emily'
  
def test_pandas_join():
  #along indices
  import operator
  left_data = pd.DataFrame({'name': ['john', 'marge'], 
                            'age':[25, 27]})
  right_data = pd.DataFrame({'name': ['john', 'marge', 'marge'], 
                             'possesions': ['dog', 'cider', 'chair']})
  left = left_data.set_index('name')
  right = right_data.set_index('name')

  result = {'age': {'john': 25, 
                    'marge': 27}, 
            'possesions': {'john': 'dog', 
                           'marge': 'chair'}}
  assert left.join(right).to_dict() == result

def test_pandas_merge():
  #not based on indices
  left = pd.DataFrame({ 'name':       ['john', 'marge'], 
                        'age':        [25, 27]})
  right = pd.DataFrame({'name':       ['john', 'marge', 'marge'], 
                        'possesions': ['dog', 'cider', 'chair']})
  result = {'age': { 0: 25, 1: 27, 2: 27 },
            'name': { 0: 'john', 1: 'marge', 2: 'marge' },
            'possesions': { 0: 'dog', 1: 'cider', 2: 'chair' }}
  assert left.merge(right, on='name').to_dict() == result

#https://github.com/jakevdp/PythonDataScienceHandbook/blob/46cfb1c8b28edcdf543b4aabd59c0d5b7202236b/notebooks/03.04-Missing-Values.ipynb
def test_masking():
  import numpy as np
  data = pd.Series([1, np.nan, 'Hello', None])
  data_no_nulls = data[data.notnull()]
  assert data_no_nulls[0] == 1
  assert data_no_nulls[2] == 'Hello'

def test_fillna():
  import numpy as np
  data = pd.Series([1, np.nan, 'Hello', None])  
  filled = data.fillna('something')
  assert filled[0] == 1
  assert filled[1] == 'something'
  assert filled[2] == 'Hello'
  assert filled[3] == 'something'
