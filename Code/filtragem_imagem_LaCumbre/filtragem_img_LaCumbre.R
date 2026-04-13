library(terra)
library(raster)
library(circular)
#library(FDDPhase)
library(Filters)

# Importando imgem (imagem .tif)
data <- raster("diff_phase_LaCumbre.tif")
y <- raster::as.matrix(data[475:820, 355:846, drop=FALSE])

#mapa de coerencia
map.coherence <- raster("mle.Cauchy_SAR.tif")
map.coherence <- raster::as.matrix(map.coherence)

#aplicar o filtro
img_LInSARRFE <- LInSARRFE(y, map.coherence, param=c(r=0.7, theta=0, L=16), eth=0.01)

#plot
par(mfrow = c(1, 2))
par(bty = 'n') # remove a borda
plot(rast(y),  main = "", legend = T, axes = FALSE, col = rainbow(256))
plot(rast(img_LInSARRFE),  main = "", legend = T, axes = FALSE, col = rainbow(256))
