import pandas as pd
try:
    df_md=pd.read_csv(snakemake.input[0], sep=",")
    Accessions=df_md['Run']
    with open(snakemake.output[0], 'w') as clean_srr:
        for accession in Accessions:
            clean_id=str(accession).strip()
            clean_srr.write(clean_id+"\n")
except Exception as e:
    with open(snakemake.log[0], 'w') as log:
        log.write("Error en clean_srr.py :\n")
        log.write(str(e)+"\n")
        log.write(traceback.format_exc())
    raise