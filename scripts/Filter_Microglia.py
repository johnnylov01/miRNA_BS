import pandas as pd
try:
    
    df_md=pd.read_csv(snakemake.input[0], sep=",")
    df_db=pd.read_excel(snakemake.input[1], engine='openpyxl')
    df_db.columns=df_db.columns.str.strip()
    df_md.columns=df_md.columns.str.strip()
    filtro=df_db['Cellular origin']=='Microglia'
    #Accessions
    db_Filtered=df_db.loc[filtro, 'Accession'].unique()
    filtro_Accessions=df_md['BioProject'].isin(db_Filtered)
    filtro_controles=df_md['SampleName'].str.contains('con', case=False, na=False)

    md_Filtered=df_md.loc[filtro_Accessions]

    md_Filtered.to_csv(snakemake.output[0], sep=",")
except Exception as e:
    with open(snakemake.log[0], 'w') as log:
        log.write("Error en Filter_Microglia.py :\n")
        log.write(str(e)+"\n")
        log.write(traceback.format_exc())
    raise