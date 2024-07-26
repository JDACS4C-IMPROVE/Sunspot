
import csv

import pandas as pd

# My spearman library
import spearman

def parse_args():
    import argparse
    parser = argparse.ArgumentParser(
        prog="spearman",
        description="Run modified spearman ranking analysis.")
    parser.add_argument("tsv",
                        help="The input TSV")
    parser.add_argument("cell",
                        help="The cell line to analyze")
    parser.add_argument("count",
                        type=int,
                        help="Number of top drugs to consider (n)")
    args = parser.parse_args()
    return args


args = parse_args()

df = pd.DataFrame(csv.reader(open(args.tsv), delimiter="\t"))

(mae, sp) = spearman.spearman(df, args.cell, args.count)

print("mae:      %6.3f" % mae)
print("spearman: %6.3f" % sp)
