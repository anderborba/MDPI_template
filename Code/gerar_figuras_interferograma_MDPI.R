
# ============================================================
# Geração das figuras raster (interferogramas) com fontes MDPI
# Figuras 10-13 do artigo: imagens filtradas + unwrapped
#
# MDPI Remote Sensing: cada subfigura a ~0.20 * 17 cm = 3.4 cm
# Para garantir legibilidade, salvar individualmente a 6 cm de
# largura com pointsize=10 (fonte 10 pt no PDF final).
# ============================================================

# Requer: terra, raster
# Parâmetros de fonte para base R graphics (terra::plot):
#   cex       - fator de escala geral do texto
#   cex.axis  - escala dos eixos (tick labels)
#   cex.lab   - escala dos rótulos dos eixos
#   cex.main  - escala do título

# Função auxiliar para salvar interferograma com barra de cores
save_insar_pdf <- function(rast_obj, filepath, width_cm = 6, height_cm = 6,
                            col_palette = rainbow(256),
                            pointsize = 10) {
  pdf(
    file      = filepath,
    width     = width_cm / 2.54,   # converter cm para polegadas
    height    = height_cm / 2.54,
    pointsize = pointsize           # fonte 10 pt
  )
  par(
    mar    = c(2, 2, 0.5, 4),  # margens: bottom, left, top, right
    cex    = 1.0,
    cex.axis = 0.85,
    cex.lab  = 1.0,
    bty    = "n"
  )
  terra::plot(
    rast_obj,
    main    = "",
    legend  = TRUE,
    axes    = FALSE,
    col     = col_palette,
    plg     = list(cex = 0.8)  # tamanho do texto da legenda de cor
  )
  dev.off()
  message("Saved: ", filepath)
}

# Função para salvar barra de cores separada (BarraCores.pdf)
save_colorbar_pdf <- function(min_val = -pi, max_val = pi,
                               filepath = "../Figures/BarraCores.pdf",
                               width_cm = 11.4, height_cm = 1.5,
                               col_palette = rainbow(256),
                               pointsize = 10) {
  pdf(
    file      = filepath,
    width     = width_cm / 2.54,
    height    = height_cm / 2.54,
    pointsize = pointsize
  )
  par(mar = c(2.5, 0.5, 0.5, 0.5))
  image(
    x    = seq(min_val, max_val, length.out = length(col_palette)),
    y    = 0,
    z    = matrix(seq(min_val, max_val, length.out = length(col_palette)), ncol = 1),
    col  = col_palette,
    axes = FALSE,
    xlab = ""
  )
  axis(1, cex.axis = 0.85,
       at     = c(-pi, -pi/2, 0, pi/2, pi),
       labels = expression(-pi, -pi/2, 0, pi/2, pi))
  dev.off()
  message("Saved: ", filepath)
}

# ── Exemplo de uso ─────────────────────────────────────────────
# Ajuste os caminhos conforme os dados disponíveis no seu ambiente

# library(terra)
#
# # Figura 10 – dados simulados
# original   <- rast("path/to/original_phase.tif")
# noisy      <- rast("path/to/noise_phase.tif")
# lee        <- rast("path/to/LeeRefined.tif")
# linsarrfe  <- rast("path/to/LInSARRFE.tif")
# tcn        <- rast("path/to/TcNfilter.tif")
# tcc        <- rast("path/to/TcCfilter.tif")
#
# fig_dir <- "../Figures"
# save_insar_pdf(original,  file.path(fig_dir, "original_phase.pdf"))
# save_insar_pdf(noisy,     file.path(fig_dir, "noise_phase.pdf"))
# save_insar_pdf(lee,       file.path(fig_dir, "LeeRefined.pdf"))
# save_insar_pdf(linsarrfe, file.path(fig_dir, "LInSARRFE.pdf"))
# save_insar_pdf(tcn,       file.path(fig_dir, "TcNfilter.pdf"))
# save_insar_pdf(tcc,       file.path(fig_dir, "TcCfilter.pdf"))
#
# save_colorbar_pdf()
