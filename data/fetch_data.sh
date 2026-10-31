#!/bin/bash
# Fetch input data for protein-structure-docking-md
# Target: Q8ZR43 (RamR, Salmonella Typhimurium LT2), verified via UniProt REST API
set -e
cd "$(dirname "$0")"
# UniProt sequence (also saved at verification time)
curl -s "https://rest.uniprot.org/uniprotkb/Q8ZR43.fasta" -o Q8ZR43.fasta
# AlphaFold DB model (v6 is current as of 2026-10-30; API: https://alphafold.ebi.ac.uk/api/prediction/Q8ZR43)
curl -sL -A "Mozilla/5.0" "https://alphafold.ebi.ac.uk/files/AF-Q8ZR43-F1-model_v6.pdb" -o AF-Q8ZR43-F1-model_v6.pdb
echo "fetched:"; ls -la Q8ZR43.fasta AF-Q8ZR43-F1-model_v6.pdb
