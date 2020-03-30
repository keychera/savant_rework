import argparse

# parse arguments
parser = argparse.ArgumentParser(description='Get inputs')
parser.add_argument('--result_file', dest='result_file_path', type=str, required=True,help='resavant\'s output/result file')
parser.add_argument('--test_file', dest='test_feature_path', type=str, required=True, help='resavant\' input file on deployment')

args = parser.parse_args()
result_file_path = args.result_file_path
test_feature_path = args.test_feature_path

# get scores and ground truth
scores = list()
with open(result_file_path) as fp:
    for count, line in enumerate(fp):
        score = float(line.rstrip())
        scores.append(score)

ground_truths = list()
with open(test_feature_path) as fp:
    for count, line in enumerate(fp):
        ground_truth = int(line.rstrip().split(' ')[0])
        ground_truths.append(ground_truth)

score_truth_pairs = list()
for score, ground_truth in zip(scores, ground_truths):
    score_truth_pairs.append((score, ground_truth))

sorted_pairs = sorted(score_truth_pairs, key=lambda a_tuple: a_tuple[0], reverse=True)

#calculate all metrics
metrics = list()

pairs_len = len(sorted_pairs)
if pairs_len < 5:
    n_iteration = pairs_len
else:
    n_iteration = 5

# calc acc@1, acc@3, acc@5
acc_1 = 0
acc_3 = 0
acc_5 = 0

for i, pair in zip(range(0, n_iteration), sorted_pairs):
    if pair[1] == 1:
        if i < 1:
            acc_1 += 1
        if i < 3:
            acc_3 += 1
        if i < 5:
            acc_5 += 1


# calc wef@1, wef@3, wef@5d
wef_1 = 0
wef_3 = 0
wef_5 = 0

for i, pair in zip(range(0, n_iteration), sorted_pairs):
    if pair[1] != 1:
        if i < 1:
            wef_1 += 1
        if i < 3:
            wef_3 += 1
        if i < 5:
            wef_5 += 1
    else:
        break

# calc AP
AP = 0

total_faulty = 0
for i, pair in zip(range(0, pairs_len), sorted_pairs):
    if (pair[1] == 1):
        total_faulty += 1

n_faulty = 0
for i, pair in zip(range(0, pairs_len), sorted_pairs):
    if (pair[1] == 1):
        n_faulty += 1
        pos_i = 1
    else:
        pos_i = 0
    Pi = n_faulty / (i + 1)
    AP += (Pi * pos_i) / total_faulty

all_scores = [acc_1, acc_3, acc_5, wef_1, wef_3, wef_5, AP]

for score in all_scores:
    print(score)


