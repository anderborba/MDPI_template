
# ============================================================
# Figure 6: Absolute Error between Lee (Eq. 7) and Gierull (Eq. 8)
# MDPI Remote Sensing - compliant font sizes
#   - Figure at width = 11.9 cm (0.7 * 17 cm), base_size = 10 pt
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

y   <- seq(-pi, pi, length.out = 1000)
rho <- 0.7

# L pairs: (Lee non-integer, Gierull integer)
pairs <- list(
  list(L_lee = 3.49, L_gier = 3, col = "red",    label = "L=3.49 vs L=3"),
  list(L_lee = 5.49, L_gier = 5, col = "blue",   label = "L=5.49 vs L=5"),
  list(L_lee = 7.49, L_gier = 7, col = "green4", label = "L=7.49 vs L=7"),
  list(L_lee = 9.49, L_gier = 9, col = "purple", label = "L=9.49 vs L=9")
)

df_all <- do.call(rbind, lapply(pairs, function(p) {
  lee   <- dFuncLeeEq5(y,     c(r = rho, theta = 0, L = p$L_lee))
  gier  <- dFuncGierullEq7(y, c(r = rho, theta = 0, L = p$L_gier))
  data.frame(x = y, error = abs(lee - gier), Model = p$label)
}))

cols <- c(
  "L=3.49 vs L=3" = "red",
  "L=5.49 vs L=5" = "blue",
  "L=7.49 vs L=7" = "green4",
  "L=9.49 vs L=9" = "purple"
)

x_breaks <- c(-pi/2, -pi/4, 0, pi/4, pi/2)
x_labels <- TeX(c("-\\pi/2", "-\\pi/4", "0", "\\pi/4", "\\pi/2"))

p <- ggplot(df_all, aes(x = x, y = error, colour = Model)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(
    name   = NULL,
    values = cols,
    labels = TeX(c(
      "$L=3.49$ vs $L=3$",
      "$L=5.49$ vs $L=5$",
      "$L=7.49$ vs $L=7$",
      "$L=9.49$ vs $L=9$"
    ))
  ) +
  scale_x_continuous(breaks = x_breaks, labels = x_labels) +
  labs(
    x = TeX("Phase Difference (rad)"),
    y = "Absolute Error"
  ) +
  theme_bw(base_size = 10, base_family = "serif") +
  theme(
    legend.position        = "inside",
    legend.position.inside = c(0.85, 0.78),
    legend.background      = element_rect(fill = "transparent", colour = NA),
    legend.text            = element_text(size = 9),
    axis.title             = element_text(size = 10),
    axis.text              = element_text(size = 9),
    panel.grid.minor       = element_blank()
  )

# ── Save (MDPI: 0.7 * 17 cm = 11.9 cm wide) ──────────────────

fig_dir <- "../Figures"

ggsave(
  file.path(fig_dir, "absolute_error.pdf"),
  plot   = p,
  width  = 11.7,
  height = 8.0,
  units  = "cm"
)

message("Saved: absolute_error.pdf")
