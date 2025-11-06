import pandas as pd
df=pd.read_excel(snakemake.input[0], engine="openpyxl")
accessions=df["Accession"]
with open(snakemake.output[0], 'w') as projects, open(snakemake.output[1], 'w') as sras:
    for acc in accessions:
        clean_id=str(acc).strip()
        if clean_id.startswith("PRJNA"):
            projects.write(f"{clean_id}\n")
        else:
            sras.write(f"{clean_id}\n")
print("Proyectos y SRAs identificados")