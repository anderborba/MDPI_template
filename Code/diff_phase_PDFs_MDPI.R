
# ============================================================
# Figure 5: Comparison of Phase Difference PDFs
# Lee (Eq. 7) vs Gierull (Eq. 8) models
# MDPI Remote Sensing - compliant font sizes
#   - Each subfigure at width = 8.5 cm, base_size = 10 pt
# ============================================================

rm(list = ls())

library(ggplot2)
library(ggthemes)
library(extrafont)
library(latex2exp)
library(hypergeo)

loadfonts(quiet = TRUE)

# Carregar funções do modelo de fase
source("dFuncGierullEq7.R")
source("dFuncLeeEq5.R")

n      <- 10000
sample <- seq(-pi, pi, length.out = n)
rho    <- 0.7
theta  <- 0

looks_lee     <- c(3.49, 5.49, 7.49, 9.49)
looks_gierull <- c(3,    5,    7,    9)

look_labels_lee     <- c("L=3.49", "L=5.49", "L=7.49", "L=9.49")
look_labels_gierull <- c("L=3",    "L=5",    "L=7",    "L=9")

cols_lee     <- c("L=3.49" = "red", "L=5.49" = "blue", "L=7.49" = "green4", "L=9.49" = "purple")
cols_gierull <- c("L=3"    = "red", "L=5"    = "blue", "L=7"    = "green4", "L=9"    = "purple")


# ── Build data frames ─────────────────────────────────────────

build_df_lee <- function() {
  rows <- lapply(seq_along(looks_lee), function(i) {
    param <- c(r = rho, theta = theta, L = looks_lee[i])
    pdf   <- dFuncLeeEq5(sample, param)
    data.frame(x = sample, y = pdf, Looks = look_labels_lee[i])
  })
  do.call(rbind, rows)
}

build_df_gierull <- function() {
  rows <- lapply(seq_along(looks_gierull), function(i) {
    param <- c(r = rho, theta = theta, L = looks_gierull[i])
    pdf   <- dFuncGierullEq7(sample, param)
    data.frame(x = sample, y = pdf, Looks = look_labels_gierull[i])
  })
  do.call(rbind, rows)
}

df_lee     <- build_df_lee()
df_gierull <- build_df_gierull()

# ── Common theme (MDPI: base_size = 10 pt) ───────────────────

mdpi_theme <- theme_bw(base_size = 10, base_family = "serif") +
  theme(
    legend.position          = "inside",
    legend.position.inside   = c(0.85, 0.78),
    legend.background    = element_rect(fill = "transparent", colour = NA),
    legend.title         = element_text(size = 10),
    legend.text          = element_text(size = 10),
    axis.title           = element_text(size = 10),
    axis.text            = element_text(size = 9),
    panel.grid.minor     = element_blank()
  )

x_breaks <- c(-pi, -pi/2, 0, pi/2, pi)
x_labels <- TeX(c("-\\pi", "-\\pi/2", "0", "\\pi/2", "\\pi"))

# ── Lee plot ─────────────────────────────────────────────────

p_lee <- ggplot(df_lee, aes(x = x, y = y, colour = Looks)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(
    name   = NULL,
    values = cols_lee,
    labels = TeX(c("$L=3.49$", "$L=5.49$", "$L=7.49$", "$L=9.49$"))
  ) +
  scale_x_continuous(breaks = x_breaks, labels = x_labels) +
  coord_cartesian(ylim = c(0, 1.7)) +
  labs(
    x = TeX("Phase Difference (rad)"),
    y = TeX("Probability Density Function")
  ) +
  mdpi_theme

# ── Gierull plot ──────────────────────────────────────────────

p_gierull <- ggplot(df_gierull, aes(x = x, y = y, colour = Looks)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(
    name   = NULL,
    values = cols_gierull,
    labels = TeX(c("$L=3$", "$L=5$", "$L=7$", "$L=9$"))
  ) +
  scale_x_continuous(breaks = x_breaks, labels = x_labels) +
  coord_cartesian(ylim = c(0, 1.7)) +
  labs(
    x = TeX("Phase Difference (rad)"),
    y = TeX("Probability Density Function")
  ) +
  mdpi_theme

# ── Save (MDPI: each subfigure at 0.5 * 17 cm = 8.5 cm wide) ─

fig_dir <- "../Figures"

ggsave(
  file.path(fig_dir, "diff_phase_lee.pdf"),
  plot   = p_lee,
  width  = 8.5,
  height = 7.0,
  units  = "cm"
)

ggsave(
  file.path(fig_dir, "diff_phase_gierull.pdf"),
  plot   = p_gierull,
  width  = 8.5,
  height = 7.0,
  units  = "cm"
)

message("Saved: diff_phase_lee.pdf and diff_phase_gierull.pdf")
