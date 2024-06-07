import os
import pickle
import pandas as pd
import numpy as np
import tqdm

loc = input("Location of TSV's:")

if loc == "":
    wd = os.getcwd() 
    path = os.path.join(os.path.join(wd, "data"), "TSVs")
    loc = path  
    print(loc)
  

drugs_perf = {}

for job in os.listdir(loc):
    curr = os.path.join(loc, job)
    
    # 
    # print(f"----------{job}----------")
    # job_drugs.append(job)
    # samples_rmse_curr = {}
    
    for model in tqdm.tqdm(os.listdir(curr), desc=f"{job}"):
        inner = os.path.join(curr, model)
        
        for subdir, dirs, files in os.walk(inner):
            for file in files:
                f = os.path.join(subdir, file)
                df = pd.read_csv(f, sep="\t")
                
                drug = df["Drug1"][0]
                
                if drug not in drugs_perf:
                    drugs_perf[drug] = []
                    drugs_perf[drug].append(df)
                else:
                    drugs_perf[drug].append(df)
                    
drug_dict = {}
for key, value in tqdm.tqdm(drugs_perf.items()):
    drug_dict[key] = pd.concat(value)

with open('drug_data.pickle', 'wb') as handle:
    pickle.dump(drug_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)

                
