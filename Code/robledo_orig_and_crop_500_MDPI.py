"""
Figure: Robledo InSAR phase – original and 500x500 crop
MDPI Remote Sensing standard: width = 17 cm, font size = 10 pt
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import rasterio
import warnings
warnings.filterwarnings("ignore", category=rasterio.errors.NotGeoreferencedWarning)

# ── Paths ─────────────────────────────────────────────────────
FULL_TIF = ("/home/aborba/MEGA/github/Chapter-Filtragem-em-Imagens-InSAR"
            "/Data/IMAGES/TIFF"
            "/ArgVol_24309_13045-001_14054-002_0401d_s01_L090HH_01_int_real_imag.tif")
OUT_PDF  = "../Figures/robledo_orig_and_crop_500.pdf"

# ── Crop coordinates (pixel indices in full image) ─────────────
ROW_W = 2500;  ROW_E = 3012
COL_H = 22000; COL_L = 22512

# ── MDPI typography ───────────────────────────────────────────
plt.rcParams.update({
    "font.family"     : "serif",
    "font.size"       : 10,
    "axes.titlesize"  : 10,
    "axes.labelsize"  : 10,
    "xtick.labelsize" : 9,
    "ytick.labelsize" : 9,
    "axes.linewidth"  : 0.8,
    "xtick.major.width": 0.8,
    "ytick.major.width": 0.8,
})

# ── Load full interferogram and crop ─────────────────────────
STEP = 15   # downsample factor for full image display
with rasterio.open(FULL_TIF) as src:
    bounds  = src.bounds
    n_rows, n_cols = src.shape

    # Full image (downsampled)
    data_full = src.read([1, 2], out_shape=(2, n_rows // STEP, n_cols // STEP))

    # Exact crop
    window = rasterio.windows.Window(COL_H, ROW_W,
                                     COL_L - COL_H, ROW_E - ROW_W)
    data_crop = src.read([1, 2], window=window)

phase_full = np.angle(data_full[0] + 1j * data_full[1])
phase_crop = np.angle(data_crop[0] + 1j * data_crop[1])

# Lon/Lat extent of the crop
lon_per_px = (bounds.right - bounds.left)  / n_cols
lat_per_px = (bounds.top   - bounds.bottom) / n_rows
crop_lon = [bounds.left + COL_H * lon_per_px,
            bounds.left + COL_L * lon_per_px]
crop_lat = [bounds.top  - ROW_E * lat_per_px,
            bounds.top  - ROW_W * lat_per_px]

# ── Figure layout (MDPI: 17 cm wide) ─────────────────────────
fig_width_cm  = 17.0
fig_height_cm = 7.5
fig, axes = plt.subplots(
    1, 2,
    figsize=(fig_width_cm / 2.54, fig_height_cm / 2.54),
    constrained_layout=True,
)

# ── Left panel: full phase ────────────────────────────────────
ax = axes[0]
# mask zero pixels (outside swath) so they appear as background
phase_full_masked = np.where(phase_full == 0, np.nan, phase_full)
cmap_left = plt.cm.rainbow.copy()
cmap_left.set_bad(color="whitesmoke")
ax.set_facecolor("whitesmoke")
im = ax.imshow(
    phase_full_masked,
    cmap=cmap_left,
    vmin=-np.pi, vmax=np.pi,
    extent=[bounds.left, bounds.right, bounds.bottom, bounds.top],
    origin="upper",
    aspect="auto",
)
ax.set_title("Phase", fontsize=10)
ax.set_xlabel("Longitude (°)", fontsize=10)
ax.set_ylabel("Latitude (°)",  fontsize=10)
ax.xaxis.set_major_locator(ticker.MaxNLocator(4))
ax.yaxis.set_major_locator(ticker.MaxNLocator(4))
ax.tick_params(labelsize=9)

# ── Right panel: crop with real lon/lat ───────────────────────
ax2 = axes[1]
im2 = ax2.imshow(
    phase_crop,
    cmap="rainbow",
    vmin=-np.pi, vmax=np.pi,
    extent=[crop_lon[0], crop_lon[1], crop_lat[0], crop_lat[1]],
    origin="upper",
    aspect="auto",
)
ax2.set_title("Phase Crop", fontsize=10)
ax2.set_xlabel("Longitude (°)", fontsize=10)
ax2.set_ylabel("Latitude (°)",  fontsize=10)
ax2.xaxis.set_major_locator(ticker.MaxNLocator(4))
ax2.xaxis.set_major_formatter(ticker.FormatStrFormatter("%.2f"))
ax2.yaxis.set_major_locator(ticker.MaxNLocator(4))
ax2.yaxis.set_major_formatter(ticker.FormatStrFormatter("%.2f"))
ax2.tick_params(labelsize=9)
cbar2 = fig.colorbar(im2, ax=ax2, fraction=0.046, pad=0.04, shrink=0.9)
cbar2.set_label("Phase (rad)", fontsize=9)
cbar2.ax.tick_params(labelsize=8)
cbar2.set_ticks([-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
cbar2.set_ticklabels([r"$-\pi$", r"$-\pi/2$", "0", r"$\pi/2$", r"$\pi$"])

# ── Save ──────────────────────────────────────────────────────
fig.savefig(OUT_PDF, dpi=300, bbox_inches="tight")
print(f"Saved: {OUT_PDF}")
