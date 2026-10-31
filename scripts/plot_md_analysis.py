"""Plot GROMACS MD analysis: RMSD + Rg vs time, per-residue RMSF.
Reads results/rmsd_backbone.xvg, results/rmsf_residue.xvg, results/rg.xvg
(written by scripts/run_md.sh). Writes figures/03_rmsd_rg.png and figures/04_rmsf.png.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def read_xvg(path):
    x, y = [], []
    with open(path) as f:
        for line in f:
            if line.startswith(('#', '@')):
                continue
            parts = line.split()
            if len(parts) >= 2:
                x.append(float(parts[0])); y.append(float(parts[1]))
    return np.array(x), np.array(y)

# --- RMSD + Rg ---
t_rmsd, rmsd = read_xvg(os.path.join(BASE, 'results', 'rmsd_backbone.xvg'))
t_rg, rg = read_xvg(os.path.join(BASE, 'results', 'rg.xvg'))
sim_ps = t_rmsd[-1] if len(t_rmsd) else 0

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 7), sharex=True)
ax1.plot(t_rmsd, rmsd, color='#1f78b4', lw=1.2)
ax1.set_ylabel('Backbone RMSD (nm)')
ax1.set_title(f'RamR (Q8ZR43) apo MD: backbone RMSD and radius of gyration ({sim_ps:.0f} ps production)')
ax1.grid(alpha=0.3)
ax2.plot(t_rg, rg, color='#e31a1c', lw=1.2)
ax2.set_xlabel('Time (ps)')
ax2.set_ylabel('Radius of gyration (nm)')
ax2.grid(alpha=0.3)
fig.tight_layout()
fig.savefig(os.path.join(BASE, 'figures', '03_rmsd_rg.png'), dpi=150)
print(f'RMSD: final {rmsd[-1]:.3f} nm, mean {rmsd.mean():.3f} nm | Rg: mean {rg.mean():.3f} nm')

# --- RMSF ---
res, rmsf = read_xvg(os.path.join(BASE, 'results', 'rmsf_residue.xvg'))
fig, ax = plt.subplots(figsize=(10, 4.5))
ax.bar(res, rmsf, color='#6a3d9a', width=1.0)
for b, label in ((59, 'Tyr59'), (85, 'Thr85'), (137, 'Ser137'), (152, 'Asp152')):
    ax.axvline(b, color='blue', ls='--', lw=0.8, alpha=0.7)
ax.text(0.99, 0.95, 'dashed: bile-acid binding residues', transform=ax.transAxes,
        ha='right', va='top', fontsize=8, color='blue')
ax.set_xlabel('Residue')
ax.set_ylabel('RMSF (nm)')
ax.set_title(f'RamR (Q8ZR43) apo MD: per-residue RMSF (mean {rmsf.mean():.3f} nm)')
ax.set_xlim(1, len(res))
fig.tight_layout()
fig.savefig(os.path.join(BASE, 'figures', '04_rmsf.png'), dpi=150)
print(f'RMSF: mean {rmsf.mean():.3f} nm, max {rmsf.max():.3f} nm at residue {res[int(np.argmax(rmsf))]:.0f}')
