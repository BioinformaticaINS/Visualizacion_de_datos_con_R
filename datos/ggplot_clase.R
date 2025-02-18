## title: "Clase_ggplot2"
## author: "Damaris Esquen"
## Fecha: "14/02/2025"
## En este script vamos a aprender a usar ggplot2, usando como data
## cgd un ensayo controlado con placebo de interferón gamma en la 
## enfermedad granulomatosa crónica (CGD). 

# Cargar todas las librerías necesarias con pacman
pacman::p_load(dplyr, ggplot2, readxl, RColorBrewer, paletteer, cowplot)
pacman::p_load(rnaturalearth, rnaturalearthdata, sf, viridis)

library(cowplot)      # permite combinar varios gráficos creados con ggplot2 en una sola figura compuesta.
library(RColorBrewer) # Paletas de colores, Info en https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
library(paletteer)    # Paletas de colores, Info en https://pmassicotte.github.io/paletteer_gallery/
library(ggplot2)
library(dplyr)
library(readxl)

# INTRODUCCIÓN A ggplot2 ----
results_dir <- "/home/ins_user/cursoR/results/"
data_dir <- "/home/ins_user/cursoR/data/"

# Base de un gráfico en ggplot2 ----

# A. Capas en un grafico de ggplot2
## 1. Data ----
# Data
cgd <- read_excel("/home/ins_user/cursoR/data/cgd.xlsx")
cgd <- as_tibble(cgd)
cgd
# convertimos a factor
cgd$center <- as.factor(cgd$center)
cgd$treat <- as.factor(cgd$treat)
cgd$sex <- as.factor(cgd$sex)
cgd$inherit <- as.factor(cgd$inherit)
cgd$propylac <- as.factor(cgd$propylac)
cgd$hos.cat <- as.factor(cgd$hos.cat)
cgd$status <- as.factor(cgd$status)
cgd$enum <- as.factor(cgd$enum)
cgd
# cgd <- cgd %>% mutate(across(c(center, treat, sex, inherit, propylac, hos.cat ,status, enum), as.factor))
View(cgd)
# Eliminar duplicados por las observaciones repetitivas
unique_cgd <- cgd %>% select(-c(enum, status))
unique_cgd <- unique(unique_cgd)
View(unique_cgd)

unique_cgd %>% ggplot()
# Aesthetics
unique_cgd %>% ggplot(aes(x = height, y = weight))
# Geometries
unique_cgd %>% ggplot(aes(x = height, y = weight)) +
  geom_point()

## 2. Geometries----
# Una variable continua
a <- unique_cgd %>% ggplot(aes(x = weight))
# binwidth especifica el ancho de cada barra
a + geom_density(kernel = "gaussian")
a + geom_dotplot()
a + geom_dotplot(binwidth = 3)
a + geom_histogram() 

# Una variable discreta 
unique_cgd %>% ggplot(aes(x = sex)) + geom_bar()

# dos variables, ambas continuas
b <- unique_cgd %>% ggplot(aes(x = weight, y = height )) 
b + geom_point()
b + geom_count()
b + geom_smooth(method = lm) + # metodo lineal, regresion lineal
  coord_flip()                 # para voltear x y y
b + geom_label(aes(label = id))

# dos variables, una discreta y una continua
c <- unique_cgd %>% ggplot(aes(x = sex, y = weight)) 
c + geom_boxplot()
c + geom_violin()

# dos variables, ambas discretas
d <- unique_cgd %>% ggplot(aes(x = sex, y = center )) 
d + geom_count()
d + geom_jitter()

# Distribución bivariada continua, 
# level es la densidad de puntos en cada área del gráfico.
e <- unique_cgd %>% ggplot(aes(x = weight, y = height )) 
e + geom_density_2d_filled() 

# tres variables, x, y, z
f <- unique_cgd %>% ggplot(aes(x = height, y = weight))
f + geom_point(aes(size = age))

g <- unique_cgd %>% ggplot(aes(x = sex, y = age))
g + geom_tile(aes(fill = center))

# Puedes aplicar varios geom a la gráfica
h <- unique_cgd %>% ggplot(aes(x = treat, y = weight))
h + geom_boxplot() + geom_jitter()

## 3. Aesthetics ----
# x, y: Variable a lo largo del eje X e Y
# colour: Color de los elementos geométricos (geoms) según los datos
# fill: Color de relleno del elemento geométrico
# group: A qué grupo pertenece un elemento geométrico
# shape: La figura utilizada para representar un punto
# linetype: Tipo de línea utilizada (sólida, punteada, etc.)
# size: Escalado del tamaño para representar una dimensión adicional
# alpha: Transparencia del elemento geométrico

# Colour
# picked en google

# colores en R
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf
head(colors(), n = 20)
colors()
# Color del paquete RColorBrewer
display.brewer.all()

#Paleta paletteer
#https://r-charts.com/es/paletas-colores/

# Color: en aes con color por default
cgd %>% ggplot(aes(x = treat, y = status, color = sex )) +
  geom_count() +
  geom_jitter() 

# Color: en aes desde una paleta predefinida
cgd %>% ggplot(aes(x = treat, y = status, color = sex )) +
  geom_count() +
  geom_jitter() +
  scale_color_brewer(palette='Set1') 

# Color: en aes con una paleta hecha manualmente
### Personalizar colores ----
sex_color <- c( "male" = "#56B4E9", "female" = "#984ea3")
inherit_color <-c("autosomal" = "#E69F00","X-linked" = "#1a823d" )
propylac_color <-c("No" = "burlywood3","Si" = "darkseagreen3")
treat_color <-c("placebo" = "#2A5676","rIFN-g" = "chocolate1")

# Color: en aes desde una paleta manual
cgd %>% ggplot(aes(x = treat, y = status, color = sex )) +
  geom_count() +
  geom_jitter() +
  scale_color_manual(values = sex_color)

# fill: en aes 
unique_cgd %>% ggplot(aes(x = hos.cat, y = age, fill = inherit)) +
  geom_boxplot() + 
  scale_fill_manual(values = inherit_color)

# size: dentro de geom como aes
unique_cgd %>% ggplot(aes(x = height, y = weight, color = sex)) +
  geom_point(aes(size = weight)) +
  scale_color_manual(values = sex_color) 

# alpha y shape
cgd %>% ggplot(aes(x = status, y = enum)) + 
  geom_count(aes(color = treat, shape = treat)) + 
  geom_jitter(alpha = 0.3) +
  scale_shape_manual(values = c(15, 17))
 
# linetype
unique_cgd %>% ggplot(aes(x = weight, linetype = sex)) + 
  geom_density(kernel = "gaussian") +
  scale_linetype_manual(values = c("male" = "solid", "female" = "dashed"))

# size, introducimos scale
unique_cgd %>% ggplot(aes(x = hos.cat, y = age, fill = sex)) +
  geom_boxplot() +
  geom_jitter(aes(color = propylac), 
              size = 2.0, alpha = 0.6) +
  scale_fill_manual(values = sex_color) + 
  scale_color_manual(values = propylac_color)

# mapping vs settings
# mapping: el atributo visual (n en edad) se basa en los datos
xx <- unique_cgd %>% ggplot(aes(x = hos.cat, y = age, 
  color = inherit, size = weight)) +
  geom_point(alpha = 0.5) +
  scale_color_manual(values = inherit_color)
xx
# setting: atributo visual fijo NO se basa en los datos
unique_cgd %>% ggplot(aes(x = hos.cat, y = age, 
  color = inherit, size = weight)) +
  geom_point(size = 2 ,alpha = 0.5) +
  scale_color_manual(values = inherit_color)

##  scales ----
# scale_*_°(): * nombre de la estética a afectar, ° tipo de la escala 
# caso 1
cgd %>% ggplot(aes(x = inherit, y = weight, fill = sex)) +
  geom_boxplot() + geom_jitter(aes(color = height)) + 
  scale_fill_manual(values = sex_color) +
  scale_color_viridis_c()
 #scale_color_continuous(low="pink", high= "lightpink4")

# caso 2
yy <- cgd %>% ggplot(aes(x = sex, y = center)) +
  geom_count(color = "grey30") + 
  geom_jitter(aes(color = enum), size = 1.5) + 
  scale_color_discrete()
  #scale_color_brewer(palette='PRGn')
yy

# Title ----
# Analizo el el tratamiento con respecto al número de observaciones
zz <- cgd %>% ggplot(aes(x = status, y = enum)) + 
  geom_count(aes(color = treat)) + 
  geom_jitter(alpha = 0.2, size = 0.8) +
  scale_color_manual(values = treat_color) +
  labs(title = "Patients by Treatment and Infection Status", 
       x = "Status", y = "observation periods")
       #caption = "Datos: Fleming and Harrington, Counting Processes and Survival Analysis, appendix D.2.")  
zz

# 4. Theme ----
aa <- unique_cgd %>% ggplot(aes(x = height, y = weight, color = sex)) +
  geom_smooth(method = lm, color = "gray60") +
  geom_point(aes(size = weight), alpha = 0.8) +
  scale_color_manual(values = sex_color) +
  labs(title = "Weight vs Height of Patients by Gender", 
       x = "height (cm)", y = "weight (kg)")
aa
# Opciones de theme
  aa + theme_gray()
  aa + theme_light()
  aa + theme_dark()
  aa + theme_minimal()
  aa + theme_test()
  aa + theme_classic()

# 5. Facet ----
bb  <- unique_cgd %>% ggplot(aes(x = hos.cat, y = age, fill = sex)) +
    geom_boxplot() +
    geom_jitter(aes(color = inherit), 
                size = 2.0, alpha = 0.6) +
    scale_fill_manual(values = sex_color) + 
    scale_color_manual(values = inherit_color) +
    theme_light() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Inheritance of the disease by gender and age", 
         subtitle = "Enrollment centers",
       x = "categories of enrollment centers", y = "age (year)")

bb
bb + facet_grid(~ inherit)
bb + facet_grid(inherit ~ sex)

# B. Cowplot
# Permite combinar múltiples gráficos en una sola figura 
# Terminamos de colocar títulos a nuestras figuras generadas
f1 <- xx + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Inheritance of the disease by age", 
       subtitle = "Enrollment centers",
       x = "categories of enrollment centers", y = "age (year)")  

f2 <- yy + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  facet_grid(~ enum) + 
  labs(title = "observation periods by enrollment center", 
      x = "gender", y = "enrollment center") 

f3 <- zz + theme_minimal()

f4 <- aa + theme_light()

f5 <- bb + facet_grid(~ inherit)

# Unimos gráficas con la funcion plot_grid()
finalgraf1 <- plot_grid(f1, f3, labels=c("A","B"), 
                        ncol = 2, nrow = 1)
finalgraf1

finalgraf2 <- plot_grid(f4, f5, labels=c("1a","1b"), ncol = 1, nrow = 2)
finalgraf2

finalgraf3 <- plot_grid(f2, labels="C" ,ncol = 1)
finalgraf3

finalgraf4 <- plot_grid(finalgraf1, finalgraf3, ncol = 1) 
finalgraf4

# Finalmente guardamos el gráfico
ggsave(filename = paste0(results_dir, "g2_final.png"), 
       plot = finalgraf2, width = 10, height = 9, units = "in", 
       bg = "white", dpi = 600, device = "png")

ggsave(filename = paste0(results_dir, "g4_final.png"), 
       plot = finalgraf4, width = 10, height = 10, units = "in", 
       bg = "white", dpi = 600, device = "png")

# Challengue: COVID-19 Deaths Worldwide ----
# Graficar un mapa coloreado segun la mortalidad por covid19

# cargar el input desde una pagina web - en este caso de github
data_covid <- read.csv(paste0(data_dir, "data_covid_OWID.csv"))
data_covid <- as_tibble(data_covid)
View(data_covid)
# Convertir continente y location a factor
data_covid$continent <- as.factor(data_covid$continent)
data_covid$location <-  as.factor(data_covid$location)

# Obtener el mapa mundial con datos geoespaciales de continentes
world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  select(name, continent, geometry)
View(world)
# Unir el dataframe `data_covid` con el mapa sf
world_map_covid <- left_join(world, data_covid, by = c("name" = "location"))
# eliminar continent.y porque viene de data_covid y renombrar
world_map_covid <- world_map_covid %>%
  select(-c(continent.y)) %>% 
  rename(continent = continent.x)

# Crear el mapa con ggplot2
map <- ggplot(data = world_map_covid) +
  geom_sf(aes(fill = total_deaths),  color = "gray80", size = 0.01) +  
  scale_fill_viridis_c(option = "plasma", na.value = "grey95") +
  labs(title = "COVID-19 Deaths Worldwide",
       fill = "Total Deaths", 
       caption = "Data source: Our World in Data, updated on 19 August 2024") +
  theme_minimal()
map

# guardar la figura
ggsave(filename = paste0(results_dir, "map.png"), 
       plot = map, width = 10, height = 5, units = "in", 
       bg = "white", dpi = 600, device = "png")
