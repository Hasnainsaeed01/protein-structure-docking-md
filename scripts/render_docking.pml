# PyMOL headless render of RamR + docked cholic acid (top Vina pose)
# run: PYTHONPATH=tools pymol -c scripts/render_docking.pml
load docking/complex_pose1.pdb, complex
hide everything
select rec, chain A
select lig, chain B
show cartoon, rec
color lightblue, rec
show sticks, lig
color magenta, lig
# key interacting residues from PLIP (sticks, labeled)
select keyres, (resi 59+63+92+142+148+152) and chain A
show sticks, keyres
color yellow, keyres
# H-bond dashes for Tyr59 and Asp152 (documented binding residues)
distance hb1, (resi 59 and chain A and name OH), (chain B), 3.5
distance hb2, (resi 152 and chain A and name OD1+OD2), (chain B), 3.5
hide labels
set dash_color, red
set dash_width, 2
bg_color white
set antialias, 2
zoom lig, 10
ray 1600, 1200
png figures/05_docking_pose.png, dpi=150
quit
