
library(raster)
library(terra)
map <- raster("map_coherence_gierull.tif")

# plot
par(bty = 'n') # remove a borda
plot(rast(map),  main = "", legend = T, axes = FALSE, col = rainbow(256))


# Paleta em escala de cinza (do preto ao branco)
gray_palette <- gray.colors(256, start = 0, end = 1)
par(bty = 'n') # remove a borda
plot(rast(map), main = "", legend = TRUE, axes = FALSE, col = gray_palette)
