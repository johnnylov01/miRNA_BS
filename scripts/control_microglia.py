import subprocess
import xml.etree.ElementTree as ET
import re

accession_file = snakemake.input[0]
metadata_map = {}
microglia_exo_control_runs = []  # lista de microglia/exosome + control

# Palabras clave biológicas
keywords = ["microglia", "exosome", "extracellular vesicle", "extracellular vesicles", "EVs"]

with open(accession_file) as f:
    for line in f:
        acc = line.strip()
        if not acc:
            continue
        print(f"Procesando {acc}...")
        cmd = f"esearch -db sra -query {acc} | efetch -format xml"
        try:
            xml_output = subprocess.check_output(cmd, shell=True, universal_newlines=True)
        except subprocess.CalledProcessError:
            print(f"Error al procesar {acc}")
            continue

        try:
            root = ET.fromstring(xml_output)
        except ET.ParseError:
            print(f"Error al parsear XML de {acc}")
            continue

        # RUN accession
        run_elem = root.find(".//RUN")
        run_accession = run_elem.attrib.get("accession") if run_elem is not None else acc

        # Atributos conocidos
        treatment, cell_line, tissue = None, None, None

        # Buscar tags específicos
        for attr in root.findall(".//SAMPLE_ATTRIBUTE"):
            tag_elem = attr.find("TAG")
            val_elem = attr.find("VALUE")
            if tag_elem is not None and val_elem is not None:
                tag = tag_elem.text.lower().strip()
                val = val_elem.text.strip()
                if tag == "treatment":
                    treatment = val
                elif tag == "cell_line":
                    cell_line = val
                elif tag == "tissue":
                    tissue = val

        # Si no hay tratamiento explícito, intentar inferirlo
        if not treatment:
            for tag in ["TITLE", "DESIGN_DESCRIPTION"]:
                elem = root.find(f".//{tag}")
                if elem is not None and elem.text:
                    text = elem.text
                    m = re.search(
                        r"((?:QD|LPS|NaCl|Dex|treated|control)[\w\s\-]*group\s*\d+|treated\s*with\s*[A-Za-z0-9\-\s]+|control)",
                        text, re.IGNORECASE
                    )
                    if m:
                        treatment = m.group(0).strip()
                        break

        # Guardar metadatos
        metadata_map[run_accession] = {
            "treatment": treatment or "N/A",
            "cell_line": cell_line or "N/A",
            "tissue": tissue or "N/A"
        }

        # Revisar si menciona microglia/exosomes y es control
        xml_text = xml_output.lower()
        if any(k in xml_text for k in keywords) and treatment and "control" in treatment.lower():
            microglia_exo_control_runs.append(run_accession)

# Mostrar resultados generales
print("\nResultados:")
for run, meta in metadata_map.items():
    print(f"{run}: treatment={meta['treatment']}, cell_line={meta['cell_line']}, tissue={meta['tissue']}")

# Mostrar los runs de interés
print("\nRuns que son microglia/exosome y control:")
for run in microglia_exo_control_runs:
    print(run)

print(f"\nTotal: {len(microglia_exo_control_runs)} runs detectados con microglia/exosome y control")

# (Opcional) Guardar en un archivo
with open(snakemake.output[0], "w") as out:
    for run in microglia_exo_control_runs:
        out.write(run + "\n")
