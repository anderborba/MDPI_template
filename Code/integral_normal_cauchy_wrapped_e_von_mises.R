
#################################### Wrapped Normal ############################

# Parâmetros da Wrapped Normal
mu <- 0             # média
sigma2 <- 1         # variância
n <- 1000         # número de termos na série truncada
rho <- exp(-sigma2 / 2)

# Função densidade g_n(theta; mu, sigma^2)
g_theta <- function(theta, mu, rho, n) {
  sum_series <- 0
  for (k in 1:n) {
    sum_series <- sum_series + rho^(k^2) * cos(k * (theta - mu))
  }
  density <- (1 / (2 * pi)) * (1 + 2 * sum_series)
  return(density)
}

# Função vetorizada para integração
g_theta_vec <- function(theta) {
  sapply(theta, function(t) g_theta(t, mu, rho, n))
}

# Integração numérica no intervalo (-pi, pi]
result <- integrate(g_theta_vec, lower = -pi, upper = pi, rel.tol = 1e-10)

# Exibir resultado
cat("Valor da integral:", result$value, "\n")
cat("Erro estimado:", result$abs.error, "\n")


#################################### Wrapped Cauchy ############################

# Definição da densidade da Wrapped Cauchy
f_wrapped_cauchy <- function(theta, mu = 0, rho = 0.5) {
  num <- 1 - rho^2
  den <- 1 + rho^2 - 2 * rho * cos(theta - mu)
  (1 / (2 * pi)) * (num / den)
}

# Integração da densidade no intervalo (-pi, pi]
resultado <- integrate(f_wrapped_cauchy, lower = -pi, upper = pi,
                       mu = 0, rho = 0.5, subdivisions = 1000L, rel.tol = 1e-10)

# Exibir o valor da integral
print(resultado$value)  # Deve ser aproximadamente 1

#################################### von Mises ############################

# Carrega pacote necessário
if (!require("circular")) install.packages("circular", dependencies = TRUE)
library(circular)

# Definir os parâmetros da von Mises
mu <- 0            # parâmetro de localização (em radianos)
kappa <- 2         # parâmetro de concentração

# Função densidade da von Mises
f_vm <- function(theta, mu, kappa) {
  1 / (2 * pi * besselI(kappa, 0)) * exp(kappa * cos(theta - mu))
}

# Integrar no intervalo (-pi, pi]
resultado <- integrate(f_vm, lower = -pi, upper = pi, mu = mu, kappa = kappa)

# Mostrar o resultado
print(resultado$value)  # Deve ser aproximadamente 1

