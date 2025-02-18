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
pacman::p_load(dplyr, readr, ggplot2, readxl, RColorBrewer, paletteer, cowplot)
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

### Base de un gráfico en ggplot2 ----

Data
```R
iris %>% ggplot()
```

Aesthetics
```R
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width))
```

Geometries
```R
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point()
```

### Data
Tus datos, en un formato ordenado (tidy), proporcionarán los ingredientes para tu gráfico, puedes usar el paquete tydir

### Aesthetics
Asigna las variables del conjunto de datos (valores de los datos) a las características visuales de los elementos gráficos (como los ejes, colores, formas, tamaños, etc.).
```R
# x, y: Variable a lo largo del eje X e Y
# colour: Color de los elementos geométricos (geoms) según los datos
# fill: Color de relleno del elemento geométrico
# group: A qué grupo pertenece un elemento geométrico
# shape: La figura utilizada para representar un punto
# linetype: Tipo de línea utilizada (sólida, punteada, etc.)
# size: Escalado del tamaño para representar una dimensión adicional
# alpha: Transparencia del elemento geométrico
```

##### Color

```R
display.brewer.all()
```
Paletas de color personalizada

```R
dcMarvelPalette <- c("#0476F2", "#EC1E24")
goodBadPalette <- c("#A71D20", "#0DA751", "#818385")
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf
```
