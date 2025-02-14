# Visualización de datos con R

- Título: dplyr y ggplot2
- Autor: Dámaris Esquén
- Fecha: 14/02/2025

## Cargar todas las librerías necesarias con pacman

```R
pacman::p_load(dplyr)
```

## 7. FUNCIONES DE dyplr
Recordemos que usamos %>% (pipe) nos sirve para concatenar funciones

```R
iris <-  as_tibble(iris)
iris
```

### select()

#### Para Seleccionar columnas

##### seleccionar una columna

```R
iris %>% select(Sepal.Length) %>% head(4)
```

##### seleccionar dos columnas

```R
iris %>% select(Sepal.Length,Species) %>% head(4)
```

##### seleccionar columnas desde : hasta

```R
iris %>% select(Sepal.Length:Petal.Width) %>% head(4)
```

##### seleccionar columnas por índice

```R
iris %>% select(1,3,5) %>% head(4)
```

##### eliminar columnas 

```R
iris %>% select(-Sepal.Length) %>% head(4)
```

##### eliminar varias columnas

```R
iris %>% select(-c(Sepal.Length, Species)) %>% head(4)
iris %>% select(-c(1,5)) %>% head(4)
```

##### Selecciona todo excepto Species

```R
iris %>% select(!Species) %>% head(4)
```

##### select(contain(")): selecciona columnas que contienen un texto dado

```R
iris %>% select(contains("Sepal")) %>% head(4)
```

##### select(starts_with("")) : columnas que comienzan con el prefijo dado

```R
iris %>% select(starts_with("Petal")) %>% head(4)
```

##### select(ends_with("")) : columnas que terminan con el prefijo dado

```R
iris %>% select(ends_with("Length")) %>% head(4)
```

##### select(where()): columnas que cumplen con una condición dada

```R
iris %>% select(where(is.factor)) %>% head(4)
```

##### select(last_col()): Selecciona la última columna

```R
iris %>% select(last_col()) %>% head(4)
```

### filter()

#### filtrar filas de un data frame en base a una o varias condiciones

##### filtrar filas en base a una condición con operador de comparación

```R
iris %>% filter(Sepal.Length > 7.5) %>% head()
iris %>% filter(Species == "versicolor") %>% head()
```

##### filtrar filas en base a una función

```R
iris %>% filter(Petal.Length <= mean(Petal.Length)) %>% head()
```
##### filtrar filas en base a una condición con operador lógico

```R
iris %>% filter(Sepal.Length %in% 5) %>% head()
iris %>% filter(Sepal.Length %in% c(4.5, 5))
```
##### filtrar filas que sean el opuesto a la condición : NO : !

```R
iris %>% filter(!(Sepal.Length %in% c(4.5, 5)))  %>% head()
```
##### filtrar filas que tengan un texto específico con grepl

```R
iris %>% filter(grepl("1.4", Petal.Length)) %>% head()
```
##### filtrar con varias condiciones usan & , |

```R
iris %>% filter(Sepal.Length > 5 & Petal.Length < 1.5)
iris %>% filter(Sepal.Length > 5 | Petal.Length < 1.5)
```

### slice()

#### filtra filas basándose en su posición/índice.

##### filtra segun posicion de filas

```R
iris %>% slice(1:2)
```
##### filtra la primera fila

```R
iris %>% slice_head()
```

##### filtra la ultima fila 

```R
iris %>% slice_tail()
```

### arrange()

#### reordenar filas

##### ordena filas de una columna en orden ascendente

```R
iris %>% arrange(Sepal.Length) %>% head()
```

##### ordena filas de una columna en orden descendennte

```R
iris %>% arrange(desc(Sepal.Length)) %>% head()
iris %>% arrange(Species) %>% head()
```

##### ordena filas de varias columnas

```R
iris %>% arrange(Sepal.Length) %>% head()
iris %>% arrange(Sepal.Length, Sepal.Width) %>% head()
```

##### ordena filas por grupos

```R
iris %>% arrange(Species, .by_group = TRUE)
```

### mutate()

#### Crear nuevas columnas, modificar existentes

##### crear una nueva columna

```R
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width) %>% head()
```

##### crear varias columnas

```R
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width,
                 Area_Petal = Petal.Length * Petal.Width) %>% head()
```

##### Modificar columnas existentes

```R
iris %>% mutate(Sepal.Length = Sepal.Length/5) %>% head()
```

##### Modificar columnas, especificando que columnas usando across

```R
iris %>% mutate(across(c(Petal.Length, Petal.Width), log2)) %>% head()
iris %>% mutate(across(!Species, log2)) %>% head()
```

##### Pocisión de las nuevas columnas usando .before y .after en mutate

```R
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, .before = Species) %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, .after = Sepal.Width) %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, .before = 1) %>% head()
```

##### Mantener o eliminar columnas con .keep en mutate 

```R
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, .keep = "used") %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, .keep = "unused") %>% head()
iris %>% mutate( Area_Sepal = Sepal.Length * Sepal.Width, .keep = "none") %>% head()
```

### group_by()

#### Para agrupar 

```R
iris %>% group_by(Species)
```
#### Puedo hacer calculos de los datos agrupados?

```R
iris %>% group_by(Species) %>% mean()
iris %>% group_by(Species) %>% mean(Petal.Length)
```

### summarize()

#### Resumir datos

##### resumir datos (media) de una columna

```R
iris %>% group_by(Species) %>% summarise(promedio = mean(Petal.Length))
```

##### resumir datos (media) de varias columnas

```R
iris %>%
  group_by(Species) %>%
  summarize(
    mean_PL = mean(Petal.Length),
    mean_SL = mean(Sepal.Length),
    mean_PW = mean(Petal.Width),
    mean_SW = mean(Sepal.Width)
  )
```  

##### si quisieramos resumir de todas las columnas con valores numéricos

```R
iris %>% group_by(Species) %>% summarise_if(is.numeric, mean)
```

##### resumir datos de todas las columnas con summarise_all

```R
iris %>% group_by(Species) %>% summarise_all(mean)
```

##### resumir columnas especificas colocando en un vector summarise_at

```R
iris %>% group_by(Species) %>% summarise_at(c("Sepal.Length", "Sepal.Width"), mean) 
```

### count()

#### Contar cuántas filas hay por cada columna

```R
iris %>% count(Species)
iris %>% count(Petal.Length)
```

#### Puede renombrar la columna n por otro nombre

```R
iris %>% count(Species, name = "número_por_grupo")
```

### rename()

#### Cambiar el nombre de las columnas

```R
iris %>% rename(Longitud.Sepalo = Sepal.Length) %>% head()
iris %>% rename(Longitud.Sepalo = 1) %>% head()
```

#### renombrar varias columnas

```R
iris %>% rename(
  Longitud.Sepalo = Sepal.Length,
  Anchura.Sepalo = Sepal.Width,
  Largo.Petalo = Petal.Length,
  Ancho.Petalo = Petal.Width) %>% head()
```

#### renombrar columnas en base a una función con rename_with

```R
iris %>% rename_with(toupper) %>% head()
```

#### rennombrar columnas en base a una funcion para columnas con un texto especifico

```R
iris %>% rename_with(toupper, .cols = contains("Sep")) %>% head()
```

#### Agregar un prefijo a las columnas

```R
iris %>% rename_with(~paste0("NEW_", .)) %>% head()
iris = iris
```

### distinct() 

#### Eliminar filas duplicadas

```R
iris %>% distinct(Species)
iris %>% distinct(Species, .keep_all = TRUE)
```

#### comparemos con unique, duplicated de R base

```R
unique(iris$Species)
duplicated(iris$Species)
sum(duplicated(iris$Species))
```

### join()

#### combinar dataframes

```R
d1 <- data.frame(ID = 1:2, X1 = c("a1", "a2"))
d1
d2 <- data.frame(ID = 2:3,X2 = c("b1", "b2"))
d2
```

#### left_join mantiene todas las filas de d1 y agrega la info coincidentente de d2

```
left_join(d1, d2, by = "ID")
```

#### right_join mantiene todas las filas de d2 y agrega la info coincidente de d1

```R
right_join(d1, d2, by = "ID")
```

#### inner_join unimos filas reteniendo solo filas que estan en ambas df

```R
inner_join(d1, d2, by = "ID")
```

#### full_join unimos filas reteniendo todos los valores, todas las filas

```R
full_join(d1, d2, by = "ID")
```

#### Utilizar select_if() con tipos de clase

```R
iris %>% select_if(is.numeric) %>% head()
```

#### usando condiciones lógicas

```R
iris %>%  select_if(~ is.numeric(.) && all(. < 7))
```

### 1. INTRODUCCIÓN A ggplot2 ----

#### Base de un gráfico en ggplot2 ----

##### Data

```R
iris %>% ggplot()
```

##### Aesthetics

```R
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width))
```

##### Geometries

```R
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point()
```

### Data

#### Formato tydir

##### Aesthetics

```
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

##### PALETAS DE COLOR PERSONALIZADAS

```R
dcMarvelPalette <- c("#0476F2", "#EC1E24")
goodBadPalette <- c("#A71D20", "#0DA751", "#818385")
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf
```

```R
head(colors(), n = 20)
colors()
#Crear paleta manualmente
Paleta <- c("cadetblue","coral","mediumspringgreen")
#Paleta paletteer
#https://r-charts.com/es/paletas-colores/
#terrain.colors() heat.colors(), topo.colors(), cm.colors(), rainbow().
```
