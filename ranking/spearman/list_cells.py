
import csv

import pandas as pd

# My spearman library
import spearman


def parse_args():
    import argparse
    parser = argparse.ArgumentParser(
        prog="list_cells",
        description="List cell lines in TSV.")
    parser.add_argument("tsv",
                        help="The input TSV")
    args = parser.parse_args()
    return args


args = parse_args()

df    = spearman.open_tsv(args.tsv)
cells = spearman.list_cells(df)

print("\n".join(list(cells)))
