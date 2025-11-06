import pandas as pd
try:
    
    df_md=pd.read_csv(snakemake.input[0], sep=",")
    df_db=pd.read_excel(snakemake.input[1], engine='openpyxl')
    df_db.columns=df_db.columns.str.strip()
    df_md.columns=df_md.columns.str.strip()
    filtro=df_db['Cellular origin']=='Microglia'
    #Accessions
    db_Filtered=df_db.loc[filtro, 'Accession'].unique()
    with open(snakemake.output[0], 'w') as proyecto_microglia:
        for accession in db_Filtered:
            if accession.startswith("PRJNA"):
                proyecto_microglia.write(accession+"\n")
except Exception as e:
    with open(snakemake.log[0], 'w') as log:
        log.write("Error en Filter_Microglia.py :\n")
        log.write(str(e)+"\n")
        log.write(traceback.format_exc())
    raise