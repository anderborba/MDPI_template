
# ============================================================
# Figure 14: Optimized Execution Time
# Comparison of filters across Simulated and SAR datasets
# MDPI Remote Sensing - compliant font sizes
#   - Figure at width = 15.3 cm (0.9 * 17 cm), base_size = 10 pt
# ============================================================

rm(list = ls())

library(ggplot2)
library(extrafont)
library(latex2exp)

loadfonts(quiet = TRUE)

# ── Runtime data (in seconds) from article tables ─────────────

df <- data.frame(
  Dataset = rep(
    c("Simulated", "La Cumbre", "Los Alamos", "Robledo"),
    each = 4
  ),
  Filter = rep(
    c("Refined Lee", "LInSARRFE", "TcNfilter", "TcCfilter"),
    times = 4
  ),
  Runtime = c(
    # Simulated
    5656.09, 624.82, 343.78, 433.64,
    # La Cumbre
    57851.37, 12069.78, 2023.66, 2436.25,
    # Los Alamos
    6021.06, 1642.30, 1369.55, 1408.87,
    # Robledo
    6540.03, 1601.69, 1390.55, 1433.03
  )
)

df$Dataset <- factor(
  df$Dataset,
  levels = c("Simulated", "La Cumbre", "Los Alamos", "Robledo")
)
df$Filter <- factor(
  df$Filter,
  levels = c("Refined Lee", "LInSARRFE", "TcNfilter", "TcCfilter")
)

# Convert to minutes for readability
df$Runtime_min <- df$Runtime / 60

cols <- c(
  "Refined Lee" = "#e41a1c",
  "LInSARRFE"   = "#377eb8",
  "TcNfilter"   = "#4daf4a",
  "TcCfilter"   = "#ff7f00"
)

p <- ggplot(df, aes(x = Dataset, y = Runtime_min, fill = Filter)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, colour = "grey30", linewidth = 0.2) +
  scale_fill_manual(name = "Filter", values = cols) +
  labs(
    x = NULL,
    y = "Execution Time (min)"
  ) +
  theme_bw(base_size = 10, base_family = "serif") +
  theme(
    legend.position  = "top",
    legend.title     = element_text(size = 10),
    legend.text      = element_text(size = 9),
    axis.title       = element_text(size = 10),
    axis.text        = element_text(size = 9),
    axis.text.x      = element_text(angle = 0, hjust = 0.5),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

# ── Save (MDPI: 0.9 * 17 cm = 15.3 cm wide) ──────────────────

fig_dir <- "../Figures"

ggsave(
  file.path(fig_dir, "runtime.pdf"),
  plot   = p,
  width  = 15.3,
  height = 9.0,
  units  = "cm"
)

message("Saved: runtime.pdf")
