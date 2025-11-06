rule all:
    input:
        "Pipeline/Projects"
    shell:
        """
        cat extras/title.txt
        echo "Metadata de proyectos de microglía guardada en {output}"
        echo "Para consultarlo en txt, el archivo se encuentra en txt/metadata_microglia.tsv.txt"
        cp {input} txt/metadata_microglia.tsv.txt
        """
        
rule filtro1:
    input:
        "db/DB_Microglial_exosomes_literature.xlsx"
    output:
        temp("txt/projects.txt"),
        temp("txt/sras.txt")
    script:
        "scripts/selector.py"

rule microglia:
    input:
        "txt/projects.txt",
        "db/DB_Microglial_exosomes_literature.xlsx"
    output:
        temp("txt/microglia_projects.txt")
    log:
        "logs/log_metadata.log"
    script:
        "scripts/Filter_Microglia.py"

rule Metadata_Microglia:
    input:
        "txt/microglia_projects.txt"
    output:
        "data/metadata_microglia.tsv"
    log:
        "logs/log_metadata_MC.log"
    shell:
        """
        #Consulta a NCBI SRA para obtener la metadata de los proyectos
        QUERY=$(awk '{{printf "%s%s", sep, $0; sep=" OR "}}' {input})
        #Impresión de la consulta (para debugging)
        echo "La consulta a NCBI es:"
        echo "$QUERY"
    
        #Búsqueda
        (esearch -db sra -query "$QUERY" | efetch -format runinfo > {output}) 2> {log}
        """
rule clean_srr:
    input:
        "data/metadata_microglia.tsv"
    output:
        temp("txt/srrs_clean.txt")
    log:
        "logs/clean_srr.log"
    script:
        "scripts/clean_srr.py"

rule control_Microglia:
    input:
        "txt/srrs_clean.txt"
    output:
        "txt/microglia_exosome_control.txt"
    script:
        "scripts/control_microglia.py"

rule dir_proy:
    input:
        "data/metadata_microglia.tsv",
        "txt/microglia_exosome_control.txt"
    output:
        directory("Pipeline/Projects")
    script:
        "scripts/runs_projects.py"
# rule control:
#     input:
#         "data/metadata_microglia.tsv"
#     output:
#         "txt/srr_microglia.txt"
#     script:
        
# rule filtro_microglia:
#     input:
#         "data/metscriptsadata.tsv",
#         "db/DB_Microglial_exosomes_literature.xlsx"
#     log:
#         "logs/filtro_microglia.log"
#     output:
#         "data/metadata_microglia.tsv"
    
#     script:
#         "scripts/Filter_Microglia.py"
        
# rule filtro_control:
#     input:
#         "data/metadata_microglia.tsv"
#     log:
#         "logs/filtro_control.log"
#     output:
#         "data/metadata_microglia_control.tsv"
#     script:
#         "scripts/Filter_control.py"

# rule dir_proy:
#     input:
#         "data/metadata_microglia.tsv"
#     output:
#         "txt/proyectosACC.txt"
#     script:
#         "scripts/script_list.py"

        
    