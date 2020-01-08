import sys
import pandas as pd

def calculate_statistic(df):
    col_len = len(df.columns)
    row_len = len(df.index)

    n_total = col_len - 1

    n_exec_df = df[df.columns[1:col_len]].sum(axis=1)
    
    n_not_df = pd.DataFrame(columns=range(0,1), index=range(0, row_len))
    total_series = pd.Series(n_total, index=range(0,row_len))
    n_not_df = total_series - n_exec_df

    return n_total, n_exec_df, n_not_df

if len(sys.argv) >= 3:
    pass_matrix_file = sys.argv[1]
    fail_matrix_file = sys.argv[2]

    pass_df = pd.read_csv(pass_matrix_file, header=None)
    fail_df = pd.read_csv(fail_matrix_file, header=None)

    total_passed_test = len(pass_df.columns) - 1
    total_failed_test = len(fail_df.columns) - 1
    all_methods = pass_df[0]

    np_total, np_exec_df, np_not_df = calculate_statistic(pass_df)

    nf_total, nf_exec_df, nf_not_df = calculate_statistic(fail_df)

    n_method = len(all_methods.index)
    raw = pd.DataFrame(columns=range(0, 5), index=range(0, n_method))
    raw.iloc[:,0] = all_methods
    raw.iloc[:,1] = np_exec_df
    raw.iloc[:,2] = np_not_df
    raw.iloc[:,3] = nf_exec_df
    raw.iloc[:,4] = nf_not_df

    if len(sys.argv) >= 4:
        output_file = sys.argv[3]
        raw.to_csv(path_or_buf=output_file, header=False, index=False)
    else:
        print(raw.to_csv)
     
else:
    print('python calculate_sbfl_raw_statistic.py [pass matrix path] [fail matrix path] (opt)[output path]')