"""
Kolmogorov-Smirnov test: empirical filter distributions vs Reference
Simulated InSAR data – MDPI Remote Sensing

Filters compared:  LInSARRFE, TcNfilter, TcCfilter
Reference:         phi_raster.tif  (clean phase = model ground truth)

First test
Run gerar_filtradas_simuladas.R first to produce:
  filtragem_imagem_simulada/img_LInSARRFE_sim.tif
  filtragem_imagem_simulada/img_TcNfilter_sim.tif
  filtragem_imagem_simulada/img_TcCfilter_sim.tif
Second test
Run gerar_filtradas_simuladas.R first to produce:
  filtragem_imagem_simulada/img_LInSARRFE.tif
  filtragem_imagem_simulada/img_TcNfilter.tif
  filtragem_imagem_simulada/img_TcCfilter.tif
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.stats import ks_2samp, ecdf as scipy_ecdf
import rasterio
import warnings
warnings.filterwarnings("ignore")

# ── Paths 1 ─────────────────────────────────────────────────────
#BASE = "filtragem_imagem_simulada/"
#FILES = {
#    "Reference" : BASE + "phi_raster.tif",
#    "LInSARRFE"           : BASE + "img_LInSARRFE_sim.tif",
#    "TcNfilter"           : BASE + "img_TcNfilter_sim.tif",
#    "TcCfilter"           : BASE + "img_TcCfilter_sim.tif",
#}
# ── Paths 2 ─────────────────────────────────────────────────────
BASE = "filtragem_imagem_simulada/"
FILES = {
    "Reference"           : BASE + "phi_raster.tif",
    "LInSARRFE"           : BASE + "img_LInSARRFE.tif",
    "TcNfilter"           : BASE + "img_TcNfilter.tif",
    "TcCfilter"           : BASE + "img_TcCfilter.tif",
}
OUT_PDF = "../Figures/ks_ecdf_simulated.pdf"

# ── Load images ───────────────────────────────────────────────
phases = {}
for name, path in FILES.items():
    with rasterio.open(path) as src:
        phases[name] = src.read(1).ravel()
    print(f"Loaded {name}: {phases[name].shape[0]} pixels")

ref   = phases["Reference"]
names = ["LInSARRFE", "TcNfilter", "TcCfilter"]

# ── KS tests ──────────────────────────────────────────────────
print("\n" + "="*60)
print("Two-sample Kolmogorov-Smirnov Test")
print("H0: distributions are identical  (reject if p ≤ 0.05)")
print("="*60)

results = {}
for name in names:
    stat, p = ks_2samp(ref, phases[name])
    results[name] = (stat, p)
    sig   = "REJECT H0 (p ≤ 0.05)" if p <= 0.05 else "FAIL TO REJECT H0 (p > 0.05)"
    print(f"\n  {name} vs Reference")
    print(f"    KS statistic : {stat:.8f}")
    print(f"    p-value      : {p:.8f}")
    print(f"    Conclusion   : {sig}")

# ── Paragraph for paper ───────────────────────────────────────
print("\n" + "="*60)
print("Suggested paragraph for Results section:")
print("="*60)
for name in names:
    stat, p = results[name]
    if p > 0.05:
        interp = (f"the distribution of phases filtered by {name} is "
                  f"statistically indistinguishable from the reference "
                  f"(KS = {stat:.8f}, p = {p:.8f} > 0.05), confirming that "
                  f"{name} produces results as good as the physical model.")
    else:
        interp = (f"the distribution of phases filtered by {name} differs "
                  f"significantly from the reference "
                  f"(KS = {stat:.8f}, p = {p:.8f} ≤ 0.05).")
    print(f"\n  {name}: {interp}")

# ── ECDF figure (MDPI: 17 cm wide, 10 pt) ────────────────────
plt.rcParams.update({
    "font.family"      : "serif",
    "font.size"        : 10,
    "axes.titlesize"   : 10,
    "axes.labelsize"   : 10,
    "xtick.labelsize"  : 9,
    "ytick.labelsize"  : 9,
    "axes.linewidth"   : 0.8,
})

colors = {
    "Reference"           : "black",
    "LInSARRFE"           : "blue",
    "TcNfilter"           : "darkgreen",
    "TcCfilter"           : "red",
}
linestyles = {
    "Reference"           : "-",
    "LInSARRFE"           : "--",
    "TcNfilter"           : ":",
    "TcCfilter"           : "-.",
}

fig, ax = plt.subplots(figsize=(17 / 2.54, 8 / 2.54), constrained_layout=True)

for name, data in phases.items():
    sorted_data = np.sort(data)
    cdf         = np.arange(1, len(sorted_data) + 1) / len(sorted_data)
    ax.plot(sorted_data, cdf,
            color=colors[name], linestyle=linestyles[name],
            linewidth=1.2, label=name)

# Annotate KS results inside plot
y_pos = 0.35
for name in names:
    stat, p = results[name]
    label = f"{name}: KS={stat:.8f}, p={p:.8f}"
    ax.annotate(label, xy=(0.02, y_pos), xycoords="axes fraction",
                fontsize=8, color=colors[name])
    y_pos -= 0.08

ax.set_xlabel(r"Phase difference $\psi$ (rad)", fontsize=10)
ax.set_ylabel("Empirical CDF", fontsize=10)
ax.set_title("ECDF comparison: empirical filters vs Reference", fontsize=10)
ax.set_xlim(-np.pi, np.pi)
ax.set_xticks([-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
ax.set_xticklabels([r"$-\pi$", r"$-\pi/2$", "0", r"$\pi/2$", r"$\pi$"])
ax.legend(fontsize=9, loc="upper left")
ax.grid(True, linewidth=0.4, alpha=0.5)

fig.savefig(OUT_PDF, dpi=300, bbox_inches="tight")
print(f"\nSaved: {OUT_PDF}")
