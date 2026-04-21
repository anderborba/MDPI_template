
# ============================================================
# Figure 7: Standard deviation of Gierull interferometric phase
#           as a function of coherence and number of looks
# MDPI Remote Sensing - compliant font sizes
#   - Figure at width = 11.9 cm (0.7 * 17 cm), base_size = 10 pt
# ============================================================

rm(list = ls())

library(ggplot2)
library(extrafont)
library(latex2exp)

loadfonts(quiet = TRUE)

# Carregar função do modelo de Gierull
source("dFuncGierullEq7.R")

# Gauss-Kronrod numerical integration of standard deviation
# std(L, rho) = sqrt( integral (phi - mean)^2 * f(phi; rho, 0, L) dphi )
std_gierull <- function(rho, L) {
  param  <- c(r = rho, theta = 0, L = L)
  # mean (should be 0 for theta=0)
  mu_f   <- function(x) x * dFuncGierullEq7(x, param)
  mu     <- tryCatch(
    integrate(mu_f, lower = -pi, upper = pi,
              subdivisions = 500, rel.tol = 1e-6)$value,
    error = function(e) 0
  )
  # variance
  var_f  <- function(x) (x - mu)^2 * dFuncGierullEq7(x, param)
  v      <- tryCatch(
    integrate(var_f, lower = -pi, upper = pi,
              subdivisions = 500, rel.tol = 1e-6)$value,
    error = function(e) NA_real_
  )
  sqrt(v)
}

rho_seq <- seq(0.01, 0.99, by = 0.01)
L_vals  <- c(1, 2, 4, 8, 16, 32)

df <- do.call(rbind, lapply(L_vals, function(L) {
  sd_vals <- sapply(rho_seq, function(rho) std_gierull(rho, L))
  data.frame(rho = rho_seq, sd = sd_vals, L = factor(L))
}))

cols <- c(
  "1"  = "#e41a1c",
  "2"  = "#ff7f00",
  "4"  = "#4daf4a",
  "8"  = "#377eb8",
  "16" = "#984ea3",
  "32" = "#a65628"
)

p <- ggplot(df, aes(x = rho, y = sd, colour = L)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(
    name   = "Looks (L)",
    values = cols
  ) +
  labs(
    x = TeX("Coherence $|\\rho_c|$"),
    y = TeX("Standard Deviation (rad)")
  ) +
  theme_bw(base_size = 10, base_family = "serif") +
  theme(
    legend.position  = "right",
    legend.title     = element_text(size = 10),
    legend.text      = element_text(size = 9),
    axis.title       = element_text(size = 10),
    axis.text        = element_text(size = 9),
    panel.grid.minor = element_blank()
  )

# ── Save (MDPI: 0.7 * 17 cm = 11.9 cm wide) ──────────────────

fig_dir <- "../Figures"

ggsave(
  file.path(fig_dir, "std_dev_vs_coherence_Gierull.pdf"),
  plot   = p,
  width  = 11.9,
  height = 8.0,
  units  = "cm"
)

message("Saved: std_dev_vs_coherence_Gierull.pdf")
