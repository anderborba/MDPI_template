
# Pacotes
library(ggplot2)
library(ggthemes)
library(extrafont)
loadfonts()
theme_set(theme_pander() + theme(text = element_text(family = "serif")))
library(latex2exp)
library(dplyr)
library(tidyr)

# Funções PDFs truncadas
trunc_gaussian <- function(x, mean, sd, a, b) {
  Z <- pnorm(b, mean = mean, sd = sd) - pnorm(a, mean = mean, sd = sd)
  pdf <- dnorm(x, mean = mean, sd = sd) / Z
  pdf[x < a | x > b] <- 0
  return(pdf)
}

trunc_cauchy <- function(x, location, scale, a, b) {
  Z <- pcauchy(b, location = location, scale = scale) - pcauchy(a, location = location, scale = scale)
  pdf <- dcauchy(x, location = location, scale = scale) / Z
  pdf[x < a | x > b] <- 0
  return(pdf)
}

# Parâmetros
n <- 1000
mean <- 0
sd <- 1
a <- -2
b <- 2

# Dados Gaussian
x <- seq(-6, 6, length.out = n)
y_normal <- dnorm(x, mean = mean, sd = sd)
y_normal_trunc <- trunc_gaussian(x, mean, sd, a, b)

# Dados Gaussian com translação
mean_transl <- 25
sd_transl <- 1.5
xt <- seq(-6 + mean_transl, 6 + mean_transl, length.out = n)
y_normal_transl <- dnorm(xt, mean = mean_transl, sd = sd_transl)
y_normal_trunc_transl <- trunc_gaussian(xt, mean_transl, sd_transl, a + mean_transl, b + mean_transl)

# Dados Cauchy
scale <- 1.5
y_cauchy <- dcauchy(x, location = mean, scale = scale)
y_cauchy_trunc <- trunc_cauchy(x, location = mean, scale = scale, a, b)

# Dados Cauchy com translação
location_transl <- 25
scale_transl <- 1.5
y_cauchy_transl <- dcauchy(xt, location = location_transl, scale = scale_transl)
y_cauchy_trunc_transl <- trunc_cauchy(xt, location_transl, scale_transl, a + location_transl, b + location_transl)

# Dataframes longos
df_gaussian_long <- data.frame(x = x, Gaussian = y_normal, Truncated = y_normal_trunc) %>%
  pivot_longer(cols = c("Gaussian", "Truncated"), names_to = "Model", values_to = "Densidade")

df_gaussian_transl_long <- data.frame(x = xt, Gaussian = y_normal_transl, Truncated = y_normal_trunc_transl) %>%
  pivot_longer(cols = c("Gaussian", "Truncated"), names_to = "Model", values_to = "Densidade")

df_cauchy_long <- data.frame(x = x, Cauchy = y_cauchy, Truncated = y_cauchy_trunc) %>%
  pivot_longer(cols = c("Cauchy", "Truncated"), names_to = "Model", values_to = "Densidade")

df_cauchy_transl_long <- data.frame(x = xt, Cauchy = y_cauchy_transl, Truncated = y_cauchy_trunc_transl) %>%
  pivot_longer(cols = c("Cauchy", "Truncated"), names_to = "Model", values_to = "Densidade")

# Função base de plot com estilo
plot_base <- function(df, titulo) {
  ggplot(df) +
    geom_line(aes(x = x, y = Densidade, col = Model), linewidth = 1) +
    labs(title = titulo, x = "x", y = "Probability Density Function", color = "Model") +
    scale_color_manual(values = c("Gaussian" = "blue", "Truncated" = "red",
                                  "Cauchy" = "blue", "Truncated" = "red")) +
    theme_pander() +
    theme(
      text = element_text(family = "serif"),
      panel.grid.minor = element_blank(),
      legend.position = "top",
      axis.title.x = element_text(size = 12),
      axis.title.y = element_text(size = 12)
    )
}

# Gráficos
g1 <- plot_base(df_gaussian_long, "") #Gaussian vs Truncated Gaussian
g2 <- plot_base(df_gaussian_transl_long, "") #Gaussian Transl. vs Truncated Gaussian Transl.
g3 <- plot_base(df_cauchy_long, "") #Cauchy vs Truncated Cauchy
g4 <- plot_base(df_cauchy_transl_long, "") #Cauchy Transl. vs Truncated Cauchy Transl.

# Mostrar plots
print(g1)
print(g2)
print(g3)
print(g4)
