#!/bin/bash
# GROMACS MD pipeline for RamR (Q8ZR43) apo monomer
# Force field: AMBER99SB-ILDN, water: TIP3P. Run from the md/ directory.
# Usage: bash run_md.sh [production_ps]   (default 1000 ps)
set -e
cd "$(dirname "$0")/../md"
PROD_PS=${1:-1000}
NSTEP=$((PROD_PS * 500))  # dt = 0.002 ps
export GMX_MAXBACKUP=-1

echo "=== 1. pdb2gmx (amber99sb-ildn) ==="
echo 1 | gmx pdb2gmx -f ../data/AF-Q8ZR43-F1-model_v6.pdb -o ramr_processed.gro -water tip3p -ff amber99sb-ildn

echo "=== 2. Solvate (dodecahedron, 1.0 nm) ==="
gmx editconf -f ramr_processed.gro -o ramr_newbox.gro -c -d 1.0 -bt dodecahedron
gmx solvate -cp ramr_newbox.gro -cs spc216.gro -o ramr_solv.gro -p topol.top

echo "=== 3. Add ions (neutralize) ==="
gmx grompp -f ions.mdp -c ramr_solv.gro -p topol.top -o ions.tpr -maxwarn 2
echo "SOL" | gmx genion -s ions.tpr -o ramr_solv_ions.gro -p topol.top -pname NA -nname CL -neutral

echo "=== 4. Energy minimization ==="
gmx grompp -f minim.mdp -c ramr_solv_ions.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em -nt 2
echo "Min converged? Fmax target < 1000 kJ/mol/nm (see em.log)"

echo "=== 5. NVT equilibration (100 ps) ==="
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
gmx mdrun -v -deffnm nvt -nt 2

echo "=== 6. NPT equilibration (100 ps) ==="
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun -v -deffnm npt -nt 2

echo "=== 7. Production: ${PROD_PS} ps ==="
sed "s/NSTEP_PLACEHOLDER/${NSTEP}/" md.mdp > md_run.mdp
gmx grompp -f md_run.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr
gmx mdrun -v -deffnm md -nt 2

echo "=== 8. Analysis ==="
echo "1 1" | gmx trjconv -s md.tpr -f md.xtc -o md_center.xtc -center -pbc mol -ur compact
echo "1 0" | gmx rms -s md.tpr -f md_center.xtc -o ../results/rmsd_backbone.xvg -tu ps
echo "1" | gmx rmsf -s md.tpr -f md_center.xtc -o ../results/rmsf_residue.xvg -res
echo "1" | gmx gyrate -s md.tpr -f md_center.xtc -o ../results/rg.xvg
echo "DONE. Production simulated: ${PROD_PS} ps"
