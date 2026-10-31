# PyMOL headless render of RamR AlphaFold model colored by pLDDT
# run: pymol -c scripts/render_pymol.pml
load data/AF-Q8ZR43-F1-model_v6.pdb, ramr
hide everything
show cartoon, ramr
# color by pLDDT stored in B-factor: blue (high) -> red (low)
spectrum b, red_white_blue, ramr, minimum=50, maximum=100
# highlight documented bile-acid binding residues as sticks
select pocket, resi 59+85+137+152
show sticks, pocket
color yellow, pocket
set ray_opaque_background, off
set antialias, 2
bg_color white
zoom ramr
ray 1600, 1200
png figures/01_ramr_pymol_plddt.png, dpi=150
# second view: surface
hide sticks, pocket
show surface, ramr
color white, ramr
set transparency, 0.25, ramr
show sticks, pocket
color yellow, pocket
zoom ramr
ray 1600, 1200
png figures/01b_ramr_pymol_surface.png, dpi=150
quit
