library(readxl)
library(ggplot2)
library(stringr)
library(dplyr)

ruta_datos <- "data/datos_impacto.xlsx"
df <- read_excel(ruta_datos)

if (!dir.exists("output/figuras")) {
  dir.create("output/figuras", recursive = TRUE)
}

# --- 1. Gráfico de barras: frecuencia de herramientas de IA ---
# Extraer lista de herramientas y ajustar texto
tools_raw <- df[[4]]
tools_wrapped <- str_wrap(tools_raw, width = 30)
# Definir niveles manualmente para orden fijo
tool_levels <- str_wrap(c(
  "Asistentes virtuales (ChatGPT, Meta AI)",
  "Plataformas generación contenidos (DALL-E, Canva)",
  "Plataformas adaptativo (Duolingo, Coursera)",
  "Herramientas productividad (Grammarly, Copilot)",
  "Otra"
), width = 30)

# Contar frecuencia y ordenar
df_barras <- data.frame(
  Herramienta = factor(tools_wrapped, levels = tool_levels)
) %>%
  count(Herramienta, name = "Frecuencia")

graf_barras <- ggplot(df_barras, aes(x = Frecuencia, y = Herramienta, fill = Herramienta)) +
  geom_col(show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Frecuencia de uso de herramientas de IA para estudiar",
    x = "Frecuencia",
    y = "Herramienta de IA"
  ) +
  theme_minimal()

ggsave(
  filename = "output/figuras/frecuencia_herramientas.png",
  plot = graf_barras,
  width = 8, height = 5
)

# --- 2. Histograma: promedios ponderados de calificaciones ---
# Convertir columna a numérico y eliminar NA
promedios <- as.numeric(df[[9]])
promedios <- na.omit(promedios)
# Definir bins con regla de Sturges
bins <- ceiling(1 + log2(length(promedios)))

graf_hist <- ggplot(data.frame(Promedio = promedios), aes(x = Promedio)) +
  geom_histogram(bins = bins, fill = "#7B68EE", color = "black") +
  labs(
    title = "Histograma de promedios ponderados",
    x = "Promedio ponderado",
    y = "Frecuencia"
  ) +
  theme_minimal()

ggsave(
  filename = "output/figuras/histograma_promedios.png",
  plot = graf_hist,
  width = 8, height = 5
)

# --- 3. Dispersión y regresión lineal ---
# Datos predefinidos de meses de uso y promedios
meses_uso <- c(4, 4, 18, 4, 2, 1, 1, 10, 3, 24, 20, 6, 21, 8, 12)
promedios_sem <- c(17.00, 15.68, 13.00, 15.79, 16.00, 14.79, 13.88, 13.12,
                   15.69, 17.00, 16.41, 16.82, 16.10, 13.73, 15.72)
# Unir en data frame
df_lineal <- data.frame(meses_uso, Promedio = promedios_sem)
# Ajustar modelo\modelo <- lm(Promedio ~ meses_uso, data = df_lineal)

graf_lineal <- ggplot(df_lineal, aes(x = meses_uso, y = Promedio)) +
  geom_point(color = "#00008B", size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(
    title = "Relación meses de uso de IA vs promedio ponderado",
    x = "Meses de uso de IA",
    y = "Promedio ponderado"
  ) +
  theme_minimal()

ggsave(
  filename = "output/figuras/regresion_lineal.png",
  plot = graf_lineal,
  width = 8, height = 5
)