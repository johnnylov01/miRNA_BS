import pandas as pd
import os
df_Proyectos= pd.read_csv(snakemake.input[0], sep=",")
df_controles = pd.read_csv(snakemake.input[1], header=None)
proyectos= df_Proyectos['Run'].isin(df_controles[0])
Proy_Acc=df_Proyectos.loc[proyectos, ['Run', 'BioProject']].drop_duplicates()

for _, row in Proy_Acc.iterrows():
    bioProy=row['BioProject']
    run= row['Run']
    ruta_proyecto=os.path.join(snakemake.output[0], bioProy)
    ruta_run=os.path.join(ruta_proyecto, run)
    os.makedirs(ruta_run, exist_ok=True)