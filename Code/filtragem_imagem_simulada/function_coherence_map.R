
# Load necessary libraries
library(maxLik)
#library(FDDPhase)
#library(hypergeo)
library(raster)
library(terra)

# modelo Gierull
dFuncGierullEq7 <- function(x, param){
  
  if (!is.numeric(param[3]) || param[3] %% 1 != 0) {
    stop("Please, set the number of looks to an integer value")
  }
  
  param[1]  <- abs(param[1])
  beta <- param[1] * cos(x - param[2])
  #
  soma1 <- 0.5 * beta * exp(param[3] * log(1 - param[1]^2)
                            + lgamma(param[3] + 0.5)
                            - (param[3] + 0.5) * log(1 - beta^2)
                            - lgamma(param[3])) / sqrt(pi)
  soma2 <- 0.5  * exp(param[3] * log(1 - param[1]^2)
                      + lgamma(param[3] - 0.5)
                      - param[3] * log(1 - beta^2)
                      - lgamma(param[3])) / pi^1.5
  soma3 <- beta * asin(beta) * exp(param[3] * log(1 - param[1]^2)
                                   + lgamma(param[3] - 0.5)
                                   + log(param[3] - 0.5)
                                   - (param[3] + 0.5)
                                   * log(1 - beta^2)
                                   - lgamma(param[3])) / pi^1.5
  y  <- 0.5 - param[3]
  vet <- rep(0, param[3] - 1)
  vet[1] <- 1
  for(i in 2: (param[3] - 1)){
    vet[i] <- y + i - 1
  }
  gammaratioln <- rep(0, param[3] - 1)
  for(i in 1: (param[3] - 1)){
    gammaratioln[i] <- log(abs(vet[i]))
  }
  soma4 <- 0
  for(i in 1: (param[3] - 1)){
    soma4 <- soma4 +  (-1)^(i+1)*(-1)^(i-1) * exp(param[3] * log(1 - param[1]^2)
                                                  + lgamma(param[3] - i) - lgamma(param[3])
                                                  + sum(gammaratioln[1: i])
                                                  + log(1 + (2 * i - 1) * beta^2)
                                                  - (i + 1) * log(1 - beta^2)) * 0.25 / pi
  }
  f <- soma1 + soma2 + soma3  + soma4
  return(f)
}

# funcao para estimar rho
estim.GierullEq7 <- function(sample, param) {
  LogLikelihoodGierullEq7 <- function(param) {
    return(sum(log(dFuncGierullEq7(sample, param))))
  }
  # Estimation with constraint
  result <- maxLik(LogLikelihoodGierullEq7, start = param, fixed = c("theta", "L"))
  return(result)
}

# Window size for local estimation
window <- 3

# Load the noisy phase image
data <- raster("C:/Meus_documentos/Doutorado/Tese_JoselitoElias/Fontes/Publicacoes/Artigos/MDPI_template/Code/filtragem_imagem_simulada/phi_raster_noisy.tif")
# Matrix to store estimated rho_c values
rho_c_matrix <- matrix(NA, nrow = nrow(data), ncol = ncol(data))

# Function to estimate rho_c using a 3x3 moving window
w3 <- function(image) {
  filtered_image <- image
  for (i in 2:(nrow(image) - 1)) {  # Loop through rows, excluding borders
    for (j in 2:(ncol(image) - 1)) {  # Loop through columns, excluding borders
      window <- image[(i - 1):(i + 1), (j - 1):(j + 1)]  # Extract 3x3 window
      a <- estim.GierullEq7(window, param)  # Estimate parameters using Gierull method
      rho_c_matrix[i, j] <- min(max(as.numeric(a$estimate[1]), 0.2), 0.8)  # Constrain values between 0 and 0.9
    }
  }
  return(rho_c_matrix)
}

# Initial parameter estimation
param <- c(r = 0.6, theta = 0, L = 2)

# Estimate rho_c locally using the w3 function
coherence_map <- w3(data)
coherence_map[,1] = coherence_map[,2]  # Left border
coherence_map[,ncol(coherence_map)] = coherence_map[,ncol(coherence_map)-1] # Right border
coherence_map[1,] = coherence_map[2,]  # Top border
coherence_map[nrow(coherence_map),]=coherence_map[nrow(coherence_map)-1,]

# plote em escala colorida
par(mfrow = c(1, 2))
par(bty = 'n') # remove a borda
plot(rast(data),  main = "", legend = T, axes = FALSE, col = rainbow(256))
plot(rast(coherence_map),  main = "", legend = T, axes = FALSE, col = rainbow(256))

# Plote em escala de cinza
par(mfrow = c(1, 2))
par(bty = 'n') # remove a borda
gray_palette <- gray.colors(256, start = 0, end = 1)
plot(rast(data), main = "", legend = TRUE, axes = FALSE, col = gray_palette)
plot(rast(coherence_map), main = "", legend = TRUE, axes = FALSE, col = gray_palette)
