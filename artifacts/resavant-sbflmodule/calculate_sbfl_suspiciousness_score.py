import sys
import pandas as pd
import sbfl_strategies.SBFLTestStrategies as sbfl

if len(sys.argv) >= 2:
    raw_stat_file = sys.argv[1]

    raw_stat_df = pd.read_csv(raw_stat_file, header=None)
    
    print(raw_stat_df)

    np = int(raw_stat_df[1][0])
    np_not = int(raw_stat_df[2][0])
    nf = int(raw_stat_df[3][0])
    nf_not = int(raw_stat_df[4][0])

    strats = [sbfl.SBFLTest1(), sbfl.SBFLTest2()]
    for strat in strats:
        res = strat.calc(np, np_not, nf, nf_not)
        print(res)
