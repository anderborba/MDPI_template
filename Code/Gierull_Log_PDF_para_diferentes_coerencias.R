
# ================================
# Gierull - Log PDF para diferentes coerências
# ================================

# Limpar ambiente
rm(list = ls())

# Carregar bibliotecas
library(ggplot2)
require(ggthemes)
require(extrafont)
loadfonts()
theme_set(theme_pander() + theme(text = element_text(family = "serif")))
library(latex2exp)
source("dFuncGierullEq7.R")

# Dados
n <- 1000
center <- pi / 6
x <- seq(center - 0.020, center + 0.020, length.out = n)

# Coerências e parâmetros
rhos <- c(0.9, 0.99, 0.999, 0.9999, 0.99999, 0.999999)

# Avaliar e aplicar log à PDF de Gierull
y_vals <- lapply(rhos, function(rho) {
  param <- c(r = rho, theta = center, L = 1000)
  log(dFuncGierullEq7(x, param) + 1e-12)  # proteção contra log(0)
})

# Combinar em um data frame
df <- data.frame(
  x = rep(x, times = length(rhos)),
  y = unlist(y_vals),
  Coherence = factor(rep(rhos, each = length(x)))
)

# Cores manuais
cores <- c(
  "0.9" = "#1b9e77",
  "0.99" = "#d95f02",
  "0.999" = "#7570b3",
  "0.9999" = "#e7298a",
  "0.99999" = "#e60000",
  "0.999999" = "#a97400"
)

# Gráfico (MDPI Remote Sensing: base_size = 10 pt)
p <- ggplot(df, aes(x = x, y = y, color = Coherence)) +
  geom_line(linewidth = 0.8, alpha = 0.7) +
  scale_color_manual(name = "Coherence", values = cores) +
  xlab(TeX("Phase Differences (Rad)")) +
  ylab(TeX("Logarithm of the Probability Density Function")) +
  scale_x_continuous(
    breaks = c(center - 0.02, center - 0.01, center, center + 0.01, center + 0.02),
    labels = TeX(c("\\frac{\\pi}{6}-0.02", "\\frac{\\pi}{6}-0.01", "\\frac{\\pi}{6}", "\\frac{\\pi}{6}+0.01", "\\frac{\\pi}{6}+0.02"))
  ) +
  coord_cartesian(ylim = c(-2, 12)) +
  theme_bw(base_size = 10, base_family = "serif") +
  theme(
    panel.grid.minor = element_blank(),
    legend.position  = "top",
    legend.title     = element_text(size = 10),
    legend.text      = element_text(size = 9),
    axis.title       = element_text(size = 10),
    axis.text        = element_text(size = 9)
  )

# Exibir gráfico
print(p)

# Salvar em PDF com dimensões MDPI (0.7 * 17 cm = 11.9 cm)
ggsave(
  "../Figures/log_pdf_gierull_n1000_rho_1.pdf",
  plot   = p,
  width  = 11.9,
  height = 8.0,
  units  = "cm"
)

