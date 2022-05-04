#' @author Antony Barja :3 
# Requeriments
library(rgee)
library(rayshader)
library(raster)
library(sf)
library(magick)
ee_Initialize()

# Preprocesing population data in rgee
pop <- ee$ImageCollection$Dataset$WorldPop_GP_100m_pop
pop_max <- pop$max()

# sf -> featurecollection 
peru <- st_read("gpkg/peru.gpkg")

# Define new extent for country
extent <- peru %>% 
  st_bbox() %>% 
  st_as_sfc() %>% 
  sf_as_ee()

# Simple visualization of Peru box
# Map$addLayer(extent)

# Image to raster o stars ~ 185 s
get_pop_data <- ee_as_raster(
  image = pop_max,
  region = extent,
  dsn = "/home/ambarja/Documentos/github/rgee3D/population.tif",
  scale = 1000
)

# Working in local with raster
pop_local <- raster("population.tif") %>%
  crop(peru) %>%
  mask(peru)

# Preparing raster for rayshader 
pop_local <- raster_to_matrix(pop_local)

# Visualization 3D
pop_local %>%
  sphere_shade(
    texture = create_texture(
      "#5e0010", "#5e0010","#5e0010",
      "#5e0010", "#ffffff")
    ) %>%
  plot_3d(pop_local ,
          zscale = 3,
          fov = 0, theta = 0,
          zoom = 0.85,
          phi = 45,
          soliddepth = -20,
          solidcolor = "#5e0010", shadow = TRUE, shadowdepth = -15,
          shadowcolor = "#5e0010", background = "white",
          windowsize = c(1200, 1000)
          )

# render_snapshot(clear=TRUE)
render_snapshot(
  "3D_population.png"
  )

# Magick :3 (Customization)
edited <- image_read("3D_population.png")
edited %>%
  image_annotate(
    "Population density 2020\n [ rgee + rayshader + R spatial ecosystem ]",
    gravity = "NorthWest",font = "Bodoni MT",
    size = 80, degrees = 0, location = "+20+10"
    ) %>% 
  image_annotate(
    "Source: WorlPop | Created by: Antony Barja | @antony_barja",
    font = "ScriptS", gravity = "SouthWest",
    size = 15, degrees = 0, location = "+560+10"
    ) 
