# Visualización de datos con R

- Título: dplyr y ggplot2
- Autor: Dámaris Esquén
- Fecha: 14/02/2025
  
## En bash instalar los siguientes programas
```bash
sudo apt update
sudo apt upgrade
sudo apt-get install libudunits2-dev libgdal-dev libgeos-dev libproj-dev
```

## En RStudio, instalar y cargar todas las librerías necesarias con pacman
```R
pacman::p_load(dplyr, ggplot2, readxl, RColorBrewer, paletteer, cowplot)
pacman::p_load(rnaturalearth, rnaturalearthdata, sf, viridis)
```

## 1. FUNCIONES DE dyplr
Recordemos que usamos %>% (pipe) nos sirve para concatenar funciones

```R
iris <-  as_tibble(iris)
iris
iris %>% head(4)
```

### 1.1 select(): Seleccionar columnas

Sintaxis: select(x, column1, column2, ...)

```R
# Selecciono una columna
iris %>% select(Sepal.Length)
# seleccionar dos columnas
iris %>% select(Sepal.Length, Species)
# seleccionar columnas con desde:hasta
iris %>% select(Sepal.Length:Petal.Width)
# seleccionar columnas según su pocisión
iris %>% select(1,3,5)
# eliminar una columna con -
iris %>% select(-Sepal.Length)
# Selecciona todo excepto una columna
iris %>% select(!Species)

## select() con otros argumentos 
# (contain("")) en select selecciona columnas que contienen un texto dado
iris %>% select(contains("Sepal"))
# select(starts_with("")) : columnas que comienzan con el prefijo dado
iris %>% select(starts_with("Petal"))
# select(ends_with("")) : columnas que terminan con el prefijo dado
iris %>% select(ends_with("Length"))
# select(where()): columnas que cumplen con una condición dada
iris %>% select(where(is.factor))
```

### 1.2 filter(): filtrar filas de un data frame en base a una o varias condiciones

Sintaxis: filter(x, condition)
```R
# filtrar filas en base a una condición con operador de comparación
iris %>% filter(Sepal.Length > 7.6)
iris %>% filter(Species == "versicolor")
# filtrar filas en base a una condición con operador lógico
iris %>% filter(Species %in% "setosa") 
# filtrar filas que sean el opuesto a la condición con !
iris %>% filter(!(Sepal.Length %in% 5)) 
# filtrar con varias condiciones usan & , |
iris %>% filter(Sepal.Length > 5 & Petal.Length < 1.5)
iris %>% filter(Sepal.Length > 5 | Petal.Length < 1.5)
```

### 1.3 slice(): filtra filas basándose en su posición/índice.

Sintaxis: slice(x, row1, row2, ...)
```R
# filtra segun posicion de filas
iris %>% slice(1:2)
# filtra la primera fila
iris %>% slice_head()
# filtra la ultima fila 
iris %>% slice_tail()
```

### 1.4 arrange(): reordenar filas

Sintaxis: arrange(x, column1, column2, ..., .desc(column))
```R
# ordena filas de una columna en orden ascendente
iris %>% arrange(Sepal.Length)
# ordena filas de una columna en orden descendennte
iris %>% arrange(desc(Sepal.Length))
# ordena filas de varias columnas
iris %>% arrange(Sepal.Length, Sepal.Width)
```

### 1.5 mutate(): Crear nuevas columnas, modifica las existentes

Sintaxis: mutate(x, new_column = expression)
```R
# Para visualizar mejor lo cambios vamos a coercionar a dataframe
iris <- as.data.frame(iris)
# crear una nueva columna
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width) %>% head()
# crear varias columnas
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width,
                 Area_Petal = Petal.Length * Petal.Width) %>% head()
# Modificar columnas existentes
iris %>% mutate(Sepal.Length = Sepal.Length/5) %>% head()
# Posición de las nuevas columnas usando .before y .after en mutate
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, 
                 .before = Species) %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, 
                 .after = Species) %>% head()
# Mantener o eliminar columnas con .keep en mutate 
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width,
                 .keep = "used") %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width,
                 .keep = "unused") %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width,
                 .keep = "none") %>% head()
```

### 1.6 group_by(): Para agrupar
Es util para hacer calculos en datos agrupados, pero lo veremos mejor al usa con la funcion summarize 

Sintaxis: group_by(x, column1, column2, ...)
```R
iris %>% group_by(Species)
```

### 1.7 summarize(): Resumir datos

Sintaxis: summarize(x, new_column = function(column))
```R
# resumir datos (media) de una columna con datos agrupados
iris %>% group_by(Species) %>% summarise(promedio_Petal.Length = mean(Petal.Length))
# resumir datos (media) de varias columnas
iris %>%
  group_by(Species) %>%
  summarize(
    mean_PL = mean(Petal.Length),
    mean_SL = mean(Sepal.Length),
    mean_PW = mean(Petal.Width),
    mean_SW = mean(Sepal.Width)
  )

# si quisieramos resumir de todas las columnas con valores numéricos
iris %>% group_by(Species) %>% summarise_if(is.numeric, mean)

```

### 1.8 count(): Contar cuántas filas hay por cada columna

Sintaxis: count(x, column1, column2, ...)
```R
# volvemos a coercionar a tibble para visualizar mejor los resultados
iris <- as_tibble(iris)
# Numero de filas en una columna
iris %>% count(Species)
iris %>% count(Petal.Length)
```

### 1.9 rename():  Cambiar el nombre de las columnas

Sintaxis: rename(x, new_name = old_name)
```R
# Renombrar colocando el nombre de la columna a renombrar
iris %>% rename(longitud.sepalo = Sepal.Length)
# Renombrar colocando la posición de la columna a renombrar
iris %>% rename(ancho.sepalo = 2)
# renombrar varias columnas
iris %>% rename(
  longitud.sepalo = Sepal.Length,
  ancho.sepalo = Sepal.Width,
  longitud.petalo = Petal.Length,
  ancho.petalo = Petal.Width)
# renombrar columnas en base a una función con rename_with
iris %>% rename_with(toupper)
```

### 1.10 distinct(): Eliminar filas duplicadas

Sintaxis: distinct(x, column1, column2, ...)
```R
# Eliminar filas duplicadas en Species
iris %>% distinct(Species)
# .keep_all= TRUE mantiene todas las columnas del dataframe, no solo las seleccionadas, mientras que
# FALSE (por defecto) conservan solo las columnas especificadas.
iris %>% distinct(Species, .keep_all = TRUE)
```

### 1.11 join(): combinar dataframes

Sintaxis: left_join(x, y, by = "column")
```R
# Declaro los dataframes
d1 <- data.frame(ID = 1:2, X1 = c("a1", "a2"))
d1
d2 <- data.frame(ID = 2:3,X2 = c("b1", "b2"))
d2

# left_join mantiene todas las filas de d1 y agrega la info coincidentente de d2
left_join(d1, d2, by = "ID")

# right_join mantiene todas las filas de d2 y agrega la info coincidente de d1
right_join(d1, d2, by = "ID")

# inner_join unimos filas reteniendo solo filas que estan en ambas df
inner_join(d1, d2, by = "ID")

# full_join unimos filas reteniendo todos los valores, todas las filas
full_join(d1, d2, by = "ID")
```

#### 1.12 Utilizar select_if() con tipos de clase

Sintaxis: select_if(x, condition)
```R
# selecciono si... son de tipo numerico
iris %>% select_if(is.numeric) %>% head()
```


## 2. INTRODUCCIÓN A ggplot2 ----

### Base de un gráfico en ggplot2 

### 2.1. Data
Los datos provienen de un ensayo controlado con placebo de interferón gamma en la enfermedad granulomatosa crónica (CGD). Contienen información sobre el tiempo hasta la aparición de infecciones graves observadas hasta el final del estudio para cada paciente.

```R
# Genero los objetivos de dirección de directorio
results_dir <- "/home/ins_user/cursoR/results/"
data_dir <- "/home/ins_user/cursoR/data/"
```

Manipulo mi data con funciones de dyplr, cada columna debe ser una variable bien identificada.
```R
# manipulo mi data con funciones de dyplr
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
View(cgd)
# Eliminar duplicados por las observaciones repetitivas
unique_cgd <- cgd %>% select(-c(enum, status))
unique_cgd <- unique(unique_cgd)
View(unique_cgd)
```
Base de un grafico en ggplot
```R
# Genero el gráfico más simple en R con las capas data, Aesthetics y Geometries
unique_cgd %>% ggplot()
# Aesthetics
unique_cgd %>% ggplot(aes(x = height, y = weight))
# Geometries
unique_cgd %>% ggplot(aes(x = height, y = weight)) +
  geom_point()
```
### 2.2. Geometries
Para agregar geometrías que representen los datos en ggplot2, se utiliza geom_*(). Esta función permite representar gráficos mediante objetos geométricos. 
Su sintaxis sigue el patrón geom_ * (seguido del nombre de la geometría en inglés). 

```R
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
```

### 2.3. Aesthetics
Asigna las variables del conjunto de datos (valores de los datos) a las características visuales de los elementos gráficos (como los ejes, colores, formas, tamaños, etc.).

Tenemos las siguientes caracteristicas visuales
x, y: Variable a lo largo del eje X e Y
colour: Color de los elementos geométricos (geoms) según los datos
fill: Color de relleno del elemento geométrico
group: A qué grupo pertenece un elemento geométrico
shape: La figura utilizada para representar un punto
linetype: Tipo de línea utilizada (sólida, punteada, etc.)
size: Escalado del tamaño para representar una dimensión adicional
alpha: Transparencia del elemento geométrico

##### Color
Color de los elementos geométricos (geoms) según los datos.
Podemos usar paletas predefinidas o hacerlas manualmente

```R
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
```

La función **color** pinta bordes, lineas, puntos 
```R
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
```
La función **fill** pinta el interior de objetos que tienen un área como boxplot, polígonos, etc. 
```R
# fill: en aes 
unique_cgd %>% ggplot(aes(x = hos.cat, y = age, fill = inherit)) +
  geom_boxplot() + 
  scale_fill_manual(values = inherit_color)
```
**size** define el escalado del tamaño para representar una variable o una dimensión adicional
```R
# size: dentro de geom como aes
unique_cgd %>% ggplot(aes(x = height, y = weight, color = sex)) +
  geom_point(aes(size = weight)) +
  scale_color_manual(values = sex_color)
```
**alpha** define la transparencia del elemento geométrico, mejora visualización de datos superpuestos
**shape** define la forma del elemento geometrico utilizado 
```R
# alpha y shape
cgd %>% ggplot(aes(x = status, y = enum)) + 
  geom_count(aes(color = treat, shape = treat)) + 
  geom_jitter(alpha = 0.3) +
  scale_shape_manual(values = c(15, 17))
```

**linetype** define el tipo de línea utilizada (sólida, punteada, etc.)
```R
# linetype
unique_cgd %>% ggplot(aes(x = weight, linetype = sex)) + 
  geom_density(kernel = "gaussian") +
  scale_linetype_manual(values = c("male" = "solid", "female" = "dashed"))
```
**mapping vs settings**
mapping: usado para asignar un atributo visual (tamaño, color…) basado en los datos.
	Lo usamos en aes()
setting: para establecer un atributo visual fijo sin basarse en los datos.
	Lo usamos fuera de aes, en el ejemplo en geom_*()
```R
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
```
**Scales**
scale_<aesthetic>_<type>()
nombre de la estética a afectar, tipo de la escala 
```R
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
```
**Title** define los titulos, subtitulos, nombres de los ejes y pie de foto
```R
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
```
### 2.4. Theme
Los temas son una forma de personalizar los componentes que no son datos de tu gráficos: títulos, etiquetas, fuentes, fondo, cuadrículas y leyendas. Los temas pueden ser utilizados para dar al grafico un aspecto personalizado. 

```R
# generemos un gráfico
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
```
### 2.5.  Facet
Usado para dividir un gráfico en varios paneles o subgráficos basados en los valores de una o más variables. 

```R
# Generemos un gráfico
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
# Opciones de facet
bb + facet_grid(~ inherit)
bb + facet_grid(inherit ~ sex)
```
### 2.6 Cowplot
No es parte de ggplot2, pero nos permite combinar múltiples gráficos generados por ggplot2 en una sola figura para facilitar la comparación visual. 

```R
# Definimos los gráficos
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
```
#### Guardamos las figuras generadas con ggsave()
Podemos guardar los gráficos egnerados por ggplot2, y configurar sus parámetros como ancho, alto, resolución, tipo de archivo. 
```R
# Finalmente guardamos el gráfico
ggsave(filename = paste0(results_dir, "g2_final.png"), 
       plot = finalgraf2, width = 10, height = 9, units = "in", 
       bg = "white", dpi = 600, device = "png")

ggsave(filename = paste0(results_dir, "g4_final.png"), 
       plot = finalgraf4, width = 10, height = 10, units = "in", 
       bg = "white", dpi = 600, device = "png")
```

## 3. Challengue: COVID-19 Deaths Worldwide
Graficar un mapa coloreado segun la mortalidad por covid19 en el mundo, para esto usamos la data covid de Our World in Data (OWID) 
que proporciona datos sobre el impacto de Covid19 sobre la mortalidad y otros parámetros a nivel mudial.
https://github.com/owid/covid-19-data/tree/master/public/data


```R
# cargar la data input, esta data ha sido descargada desde el github de OWID
# y manipulada para filtrar datos como paises, continentes, total de muertos.

# a. Data de OWID
data_covid <- read.csv(paste0(data_dir, "data_covid_OWID.csv"))
data_covid <- as_tibble(data_covid)
View(data_covid)
# Convertir continente y location a factor
data_covid$continent <- as.factor(data_covid$continent)
data_covid$location <-  as.factor(data_covid$location)

# b. Datos geoespaciales
# Obtener el mapa mundial con datos geoespaciales de continentes
world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  select(name, continent, geometry)
View(world)

# c. Unimos ambas datas
# Unir el dataframe `data_covid` con el mapa sf
world_map_covid <- left_join(world, data_covid, by = c("name" = "location"))
# eliminar continent.y porque viene de data_covid y renombrar
world_map_covid <- world_map_covid %>%
  select(-c(continent.y)) %>% 
  rename(continent = continent.x)

# d. Crear el mapa con ggplot2
map <- ggplot(data = world_map_covid) +
  geom_sf(aes(fill = total_deaths),  color = "gray80", size = 0.01) +  
  scale_fill_viridis_c(option = "plasma", na.value = "grey95") +
  labs(title = "COVID-19 Deaths Worldwide",
       fill = "Total Deaths", 
       caption = "Data source: Our World in Data, updated on 19 August 2024") +
  theme_minimal()
map

# e. guardar la figura
ggsave(filename = paste0(results_dir, "map.png"), 
       plot = map, width = 10, height = 5, units = "in", 
       bg = "white", dpi = 600, device = "png")
```

