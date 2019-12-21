import sys
import pandas as pd
import sbfl_strategies as sbfl

if len(sys.argv) >= 2:
    raw_stat_file = sys.argv[1]

    raw_stat_df = pd.read_csv(raw_stat_file, header=None)

    row = 5
    np = int(raw_stat_df[1][row])
    np_not = int(raw_stat_df[2][row])
    nf = int(raw_stat_df[3][row])
    nf_not = int(raw_stat_df[4][row])

    strats = sbfl.all_sbfl_strategies
    for strat in strats:
        print(strat)
        res = strat.calc(np, np_not, nf, nf_not)
        print(res)
