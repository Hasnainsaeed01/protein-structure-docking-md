# Protein structure prediction, docking and molecular dynamics of a Salmonella AMR regulator

End-to-end structural bioinformatics on the transcriptional regulator **RamR** from
*Salmonella* Typhimurium LT2: AlphaFold structure, PyMOL visualization, AutoDock Vina
docking of a documented bile-acid ligand, and a GROMACS molecular dynamics run
(energy minimization, NVT/NPT equilibration, production, RMSD/RMSF/Rg analysis).
All tools used are free.

## Target

- UniProt: **Q8ZR43** (HTHTR_SALTY), Transcriptional regulator RamR
- Organism: *Salmonella* Typhimurium (strain LT2 / SGSC1412 / ATCC 700720)
- Length: 193 amino acids; UniProtKB reviewed (Swiss-Prot)
- Function: TetR-family repressor of ramA; controls the AcrAB-TolC multidrug efflux pump.
- Verified via the UniProt REST API on 2026-10-30.

## Structure

- Source: AlphaFold Database, `AF-Q8ZR43-F1-model_v6.pdb` (v6 was current on 2026-10-30;
  the older v4 URL returned 404, the version was resolved via the AlphaFold API).
- Mean pLDDT: **94.5** (180 residues > 90, 8 in 70-90, 3 in 50-70, 2 < 50;
  low-confidence residues are the N- and C-termini only).
- Rendered with PyMOL (headless) colored by pLDDT in the AlphaFold convention
  (blue = high confidence, red = low); the documented bile-acid binding residues
  Tyr59, Thr85, Ser137, Asp152 are shown as yellow sticks.

## Docking

- Ligand: **cholic acid** (PubChem CID 221493, C24H40O5), a bile acid.
  Cholic acid is a documented RamR ligand: crystal structures of Salmonella RamR in
  complex with cholic acid and chenodeoxycholic acid were reported by Yamasaki et al.,
  Scientific Reports 2019 (PubMed 30655545), with H-bonds to Tyr59, Thr85, Ser137, Asp152.
- Receptor prepared with Meeko (rigid), ligand prepared with Meeko from the PubChem 3D SDF.
- Box center: centroid of the CA atoms of Tyr59/Thr85/Ser137/Asp152 in the AlphaFold
  model = (9.26, 6.43, -4.55) A; box 22 x 22 x 22 A.
- AutoDock Vina 1.2.7, exhaustiveness 16: best affinity **-6.766 kcal/mol** (9 poses).
- PLIP 3.0.1 on the top pose: 7 hydrophobic contacts, 6 hydrogen bonds, 1 salt bridge.
  The pose recovers contacts to Tyr59 and Asp152, two of the four crystallographic
  binding residues, plus a Lys63 salt bridge to the ligand carboxylate.
- Note: docking was performed on the AlphaFold monomer; in vivo RamR is a homodimer
  with one bile-acid site per monomer. This is a computational exercise, not an
  experimental binding claim.

## Molecular dynamics (GROMACS, apo protein)

- Force field: AMBER99SB-ILDN, water TIP3P, dodecahedron box (1.0 nm), 3 Na+ to neutralize.
- Energy minimization: steepest descent, converged at Fmax = 937 kJ/mol/nm (< 1000).
- Equilibration: NVT 51 ps then NPT 50 ps (300 K, 1 bar).
- Production: 100 ps NPT (50,000 steps, 2 fs timestep).
- Analysis (backbone RMSD, per-residue RMSF, radius of gyration) in `results/` and `figures/`.
- IMPORTANT CAVEAT: a sub-nanosecond production run demonstrates the complete MD
  workflow (setup, equilibration, production, analysis) but is NOT converged dynamics.
  No biological conclusions about RamR flexibility should be drawn from this timescale.

## Results summary

- Mean pLDDT: 94.5 (AlphaFold model AF-Q8ZR43-F1-model_v6)
- Vina best affinity (cholic acid): -6.766 kcal/mol
- PLIP top-pose interactions: 7 hydrophobic, 6 H-bonds, 1 salt bridge
- EM: converged, Fmax 937 kJ/mol/nm
- Production: 100 ps; final backbone RMSD 0.128 nm (mean 0.109 nm); mean Rg 1.818 nm;
  mean RMSF 0.089 nm (max 0.338 nm at residue 1, the flexible N-terminus)

## Repository layout

- `data/`: `fetch_data.sh`, `METADATA`, `Q8ZR43.fasta`, `AF-Q8ZR43-F1-model_v6.pdb`
- `results/`: `plddt_per_residue.csv`, `docking_scores.csv`, `plip_interactions.csv`,
  `rmsd_backbone.csv`, `rmsf_residue.csv`, `radius_gyration.csv`
  (plus the source `.xvg` files from GROMACS)
- `figures/`: PyMOL renders, pLDDT plot, docking pose, RMSD/Rg and RMSF plots
- `scripts/`: `run_md.sh` (full GROMACS pipeline), `plot_md_analysis.py`,
  `render_pymol.pml`, `render_docking.pml`
- `tools/`: `vina` binary (v1.2.7), `imp.py` (shim so PyMOL runs on Python 3.12+)
- `docking/`: receptor/ligand PDBQT files, Vina config, docked poses, PLIP report

## Reproduce

```bash
bash data/fetch_data.sh            # download sequence + AlphaFold model
bash scripts/run_md.sh             # full GROMACS MD (needs gmx installed)
python3 scripts/plot_md_analysis.py
PYTHONPATH=tools pymol -c scripts/render_pymol.pml
```

## Tool versions

- GROMACS 2023.3, AMBER99SB-ILDN force field, TIP3P water
- AutoDock Vina 1.2.7, Meeko (PDBQT prep), RDKit, PLIP 3.0.1, OpenBabel 3.2.1
- PyMOL 2.5.x (headless, with a small imp shim for Python 3.12), Biopython, matplotlib
