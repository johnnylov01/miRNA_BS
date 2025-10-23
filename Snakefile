rule all:
    input:
        "data/metadata_microglia.tsv"
    shell:
        "cat extras/title.txt"
        
# rule filtro1:
#     input:
#         "db/DB_Microglial_exosomes_literature.xlsx"
#     output:
#         "txt/projects.txt",
#         "txt/sras.txt"
#     script:
#         "scripts/selector.py"

# rule metadata:
#     input:
#         "txt/projects.txt"
#     output:
#         "data/metadata.tsv"
#     log:
#         "logs/log_metadata.log"
#     shell:
#         """
#         #Consulta a NCBI SRA para obtener la metadata de los proyectos
#         QUERY=$(awk '{{printf "%s%s", sep, $0; sep=" OR "}}' {input})
#         mkdir 
#         #Impresión de la consulta (para debugging)
#         echo "La consulta a NCBI es:"
#         echo "$QUERY"
    
#         #Búsqueda
#         (esearch -db sra -query "$QUERY" | efetch -format runinfo > {output}) 2> {log}
#         """

rule filtro_microglia:
    input:
        "data/metadata.tsv",
        "db/DB_Microglial_exosomes_literature.xlsx"
    log:
        "logs/filtro_microglia.log"
    output:
        "data/metadata_microglia.tsv"
    script:
        "scripts/Filter_Microglia.py"