import argparse, os

# parse arguments
parser = argparse.ArgumentParser(description='Get inputs')
parser.add_argument('--eval_scores_dir', dest='eval_scores_dir', type=str, required=True,help='resavant\'s output/result file')

args = parser.parse_args()
eval_scores_dir = args.eval_scores_dir

# get all eval scores
total_acc_1 = 0.0
total_acc_3 = 0.0
total_acc_5 = 0.0
total_wef_1 = 0.0
total_wef_3 = 0.0
total_wef_5 = 0.0
total_AP = 0.0

all_scores = [total_acc_1, total_acc_3, total_acc_5, total_wef_1, total_wef_3, total_wef_5, total_AP]

eval_scores = list()
for eval_score in os.listdir(eval_scores_dir):
    with open('{}/{}'.format(eval_scores_dir, eval_score)) as fp:
        for count, line in enumerate(fp):
            all_scores[count] += float(line)


MAP = all_scores[count] / float(count + 1)
all_scores[count] = MAP

for score in all_scores:
    print(score)