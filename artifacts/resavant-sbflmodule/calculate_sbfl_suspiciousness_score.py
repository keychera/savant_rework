import sys
import pandas as pd
import sbfl_strategies as sbfl

if len(sys.argv) >= 2:
    raw_stat_file = sys.argv[1]

    raw_stat_df = pd.read_csv(raw_stat_file, header=None)

    strats = sbfl.all_sbfl_strategies
    n_strat = len(strats)
    n_method = len(raw_stat_df[0])
    suspicousness_scores = pd.DataFrame(columns=range(0, n_strat + 1), index=range(0, n_method))
    suspicousness_scores.iloc[:,0] = raw_stat_df[0]

    for row in range(0, n_method):
        np = int(raw_stat_df[1][row])
        np_not = int(raw_stat_df[2][row])
        nf = int(raw_stat_df[3][row])
        nf_not = int(raw_stat_df[4][row])

        i = 1
        for strat in strats:
            res = strat.calc(np, np_not, nf, nf_not)
            suspicousness_scores.iloc[row:,i] = res
            i += 1

    if len(sys.argv) >= 3:
        output_file = sys.argv[2]
        suspicousness_scores.to_csv(path_or_buf=output_file, header=False, index=False)
    else:
        print(suspicousness_scores)

else:
    print('python calculate_sbfl_suspiciousness_score [raw stat file] (opt)[output path]')