
# Log Gierull para diferentes valores de coerências (rho_c)

# Limpar ambiente
rm(list = ls())

#install.packages("devtools")  # ou
#install.packages("remotes")
#devtools::install_github("araujoUFPE/FDDPhase")

# Carregar pacotes
library(ggplot2)
require(ggthemes)
require(extrafont)
loadfonts()
theme_set(theme_pander() + theme(text = element_text(family = "serif")))
library(latex2exp)
library(FDDPhase)

# Dados
n <- 1000
center <- pi / 6
x <- seq(center - 0.020, center + 0.020, length.out = n)

# Coerências
rhos <- c(0.9, 0.99, 0.999, 0.9999, 0.99999, 0.999999)

# Aplicar log ao modelo do Gierull
y_vals <- lapply(rhos, function(rho) {
  param <- c(r = rho, theta = center, L = 1000)
  log(dFuncGierullEq7(x, param) + 1e-12)
})

# Data frame
df <- data.frame(
  x = rep(x, times = length(rhos)),
  y = unlist(y_vals),
  Coherence = factor(rep(rhos, each = length(x)))
)

# Cores

cores <- c(
  "0.9" = "red",      
  "0.99" = "blue",
  "0.999" = "green",
  "0.9999" = "purple",
  "0.99999" = "#d95f02",
  "0.999999" = "#e7298a"
)

# Gráfico
p <- ggplot(df, aes(x = x, y = y, color = Coherence)) +
  geom_line(linewidth = 1, alpha = 0.7) +
  scale_color_manual(name = "Coherence", values = cores) +
  xlab(TeX("Phase Differences (Rad)")) +
  ylab(TeX("Logarithm of the Probability Density Function")) +
  scale_x_continuous(
    breaks = c(center - 0.02, center - 0.01, center, center + 0.01, center + 0.02),
    labels = TeX(c("\\frac{\\pi}{6}-0.02", "\\frac{\\pi}{6}-0.01", "\\frac{\\pi}{6}", "\\frac{\\pi}{6}+0.01", "\\frac{\\pi}{6}+0.02"))
  ) +
  coord_cartesian(ylim = c(-2, 12)) +
  theme_pander(base_size = 12) +
  theme(
    text = element_text(family = "serif"),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )

# Exibir gráfico
print(p)

