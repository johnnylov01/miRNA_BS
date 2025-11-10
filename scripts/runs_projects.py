import pandas as pd
import os
df_Proyectos= pd.read_csv(snakemake.input[0], sep=",")
df_controles = pd.read_csv(snakemake.input[1], sep="\t")

proyectos= df_Proyectos['Run'].isin(df_controles['Run'])
Proy_Acc=df_Proyectos.loc[proyectos, ['Run','BioProject', 'LibraryLayout']].drop_duplicates()
organismo=df_controles['Organism']
df_filtro_completo=Proy_Acc.merge(df_controles[['Run', 'Organism']], on='Run', how='inner')

print(df_filtro_completo)
print("Creando carpetas de organismos...")
output_dir = snakemake.output[0]



for _, row in df_filtro_completo.iterrows():
    layout=row['LibraryLayout']    
    organism=row['Organism'].replace(" ", "_")
    bioproject=row['BioProject']
    run=row['Run']
    ruta_layout=os.path.join(output_dir, layout)
    ruta_organismo=os.path.join(ruta_layout, organism)
    ruta_proyecto=os.path.join(ruta_organismo, bioproject)
    ruta_organismo_proyecto_run=os.path.join(ruta_proyecto, run)
    os.makedirs(ruta_organismo_proyecto_run, exist_ok=True)