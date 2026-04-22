
# Generate filtered simulated images for KS test
# Outputs: img_LInSARRFE_sim.tif, img_TcNfilter_sim.tif, img_TcCfilter_sim.tif

library(raster)
library(terra)
library(circular)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
JOSELITO <- "/home/aborba/MEGA/github/Joselito/Tese_JoselitoElias/Codigos/R/Programs/Artigo_periodico/"
source("../dFuncGierullEq7.R")
source("../LInSARRFE.R")
source(paste0(JOSELITO, "funcoes_distribuicoes_fase.R"))
source(paste0(JOSELITO, "TcNfilter.R"))
source(paste0(JOSELITO, "TcCfilter.R"))

# Load inputs
map_coherence   <- as.matrix(raster("map_coherence_gierull.tif"))
phi_noisy       <- as.matrix(raster("phi_raster_noisy.tif"))

param_gierull <- c(r = 0.7, theta = 0, L = 16)
param_tcn     <- c(1.0, 0.5)   # c(mu, sigma) para dTruncNorm
param_tcc     <- c(0.5, 0.5)   # c(mu, sigma) para dTruncCauchy

message("Running LInSARRFE filter...")
img_linsarrfe <- LInSARRFE(phi_noisy, map_coherence, param = param_gierull, eth = 0.01)

message("Running TcNfilter...")
img_tcn <- TcNfilter(phi_noisy, param = param_tcn, eth = 0.01)

message("Running TcCfilter...")
img_tcc <- TcCfilter(phi_noisy, param = param_tcc, eth = 0.01)

# Save as GeoTIFF
ref <- raster("phi_raster.tif")

r_lin <- raster(img_linsarrfe)
extent(r_lin) <- extent(ref)
crs(r_lin)    <- crs(ref)
writeRaster(r_lin, "img_LInSARRFE_sim.tif", overwrite = TRUE)
message("Saved: img_LInSARRFE_sim.tif")

r_tcn <- raster(img_tcn)
extent(r_tcn) <- extent(ref)
crs(r_tcn)    <- crs(ref)
writeRaster(r_tcn, "img_TcNfilter_sim.tif", overwrite = TRUE)
message("Saved: img_TcNfilter_sim.tif")

r_tcc <- raster(img_tcc)
extent(r_tcc) <- extent(ref)
crs(r_tcc)    <- crs(ref)
writeRaster(r_tcc, "img_TcCfilter_sim.tif", overwrite = TRUE)
message("Saved: img_TcCfilter_sim.tif")
