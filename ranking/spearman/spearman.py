
import csv

import pandas as pd


"""
Headers:
0: model
1: cell line
2: drug
3: mean(predicted_auc)
4: std(predicted_auc)
5: mean(actual_auc)
6: std(actual_auc)
7: num_observations
"""

def open_tsv(filename):
    with open(filename) as fp:
        df = pd.DataFrame(csv.reader(fp, delimiter="\t"))
    return df


def list_cells(df):
    dedup = df[1].sort_values().drop_duplicates()
    return dedup


def spearman(df, cell, n):
    """
    df: The dataframe (see headers above)
    cell: The cell line string
    n: The count of drugs of interest
    """

    print("original dataframe length: %i" % len(df))

    # The selected rows:
    rows = df.loc[df[1] == cell]
    # print("matching rows for cell '%s': %i" % (args.cell, len(rows)))

    # Sort to copy and update index
    rank_predict = rows.sort_values(3, ignore_index=True)
    # print(str(rank_predict[0:n]))

    # Sort to copy and update index
    rank_actual = rows.sort_values(5, ignore_index=True)
    # print(str(rank_actual[0:n]))

    # Basic sum of differences (Σ d)
    sum1 = 0
    # Sum of difference squares (Σ d^2)
    sum2 = 0

    for i in range(0, n):
        drug = rank_actual.iloc[i][2]
        #print("drug ", drug)
        match = rank_actual.loc[rank_predict[2] == drug]
        # print("match ", match.index.item())
        diff  = abs(i - match.index.item())
        sum1 += diff
        diff2 = diff ** 2
        print("diff2 ", diff2)
        sum2 += diff2
        # print("match ", str(match), " is ", )

    mae = (sum1/n)
    denominator = (n*(n**2 - 1))
    spearman = 1 - 6*diff2 / denominator
    print("denominator: %i" % denominator)
    return (mae, spearman)

def spearman_clustered(df, cell, n):
    """
    df: The dataframe (see headers above)
    cell: The cell line string
    n: The count of drugs of interest
    """

    print("original dataframe length: %i" % len(df))

    # The selected rows:
    rows = df.loc[df[1] == cell]
    # print("matching rows for cell '%s': %i" % (args.cell, len(rows)))

    # Sort to copy and update index
    rank_predict = rows.sort_values(3, ignore_index=True)
    # print(str(rank_predict[0:n]))

    # Sort to copy and update index
    rank_actual = rows.sort_values(5, ignore_index=True)
    # print(str(rank_actual[0:n]))

    # Basic sum of differences (Σ d)
    sum1 = 0
    # Sum of difference squares (Σ d^2)
    sum2 = 0

    for i in range(0, n):
        drug = rank_actual.iloc[i][2]
        #print("drug ", drug)
        match = rank_actual.loc[rank_predict[2] == drug]
        # print("match ", match.index.item())
        diff  = abs(i - match.index.item())
        sum1 += diff
        diff2 = diff ** 2
        print("diff2 ", diff2)
        sum2 += diff2
        # print("match ", str(match), " is ", )

    mae = (sum1/n)
    denominator = (n*(n**2 - 1))
    spearman = 1 - 6*diff2 / denominator
    print("denominator: %i" % denominator)
    return (mae, spearman)
