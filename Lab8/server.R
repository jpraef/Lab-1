

library(shiny)
library(maptools)
library(akima)
library(ggplot2)
library(reshape2)
pt_shp <- readShapePoints("~/Desktop/General/Spring 2016/ES 207/Labs/Projects/Lab-1/Data/ahearn_allobs/allobs.shp")

#shinyServer(
 # function(input, output) {
  
  shinyServer(
    function(input, output) {
      output$map <- renderPlot({
        pt <- switch(input$var,
                     "Feb 16, 2005" = pt_shp[pt_shp$DateTime_ == "2005-02-16",],
                    "Feb 17, 2005" = pt_shp[pt_shp$DateTime_ == "2005-02-17",],
                     "Feb 18, 2005" = pt_shp[pt_shp$DateTime_ == "2005-02-18",],
                     "Feb 23, 2005" = pt_shp[pt_shp$DateTime_ == "2005-02-23",],
                     "Feb 28, 2005" = pt_shp[pt_shp$DateTime_ == "2005-02-28",])
        date <- switch(input$var,
                     "Feb 16, 2005" = "Feb 16, 2005",
                     "Feb 17, 2005" = "Feb 17, 2005",
                     "Feb 18, 2005" = "Feb 18, 2005",
                     "Feb 23, 2005" = "Feb 23, 2005",
                     "Feb 28, 2005" = "Feb 28, 2005")
       pt.filled <- switch(input$var.var,
                           "Temperature" = interp(pt$Longitude,pt$Latitude,pt$Temp,duplicate='mean'),
                           "Chlorophyl" = interp(pt$Longitude,pt$Latitude,pt$Chlorophyl,duplicate='mean'),
                           "Dissolved Oxygen" = interp(pt$Longitude,pt$Latitude,pt$DO__,duplicate='mean'),
                           "Turbidity" = interp(pt$Longitude,pt$Latitude,pt$Turbidity_,duplicate='mean'),
                           "Total Dissolved Solids" = interp(pt$Longitude,pt$Latitude,pt$TDS,duplicate='mean'))
       
       color <- switch(input$var.var,
                       "Temperature" = "Oranges",
                       "Chlorophyl" = "Spectral",
                       "Dissolved Oxygen" = "BuPu",
                       "Turbidity" = "PRGn",
                       "Total Dissolved Solids" = "BrBG")
       name <- switch(input$var.var,
                       "Temperature" = "Temperature (°C)",
                       "Chlorophyl" = "Chlorophyl (μg L−1)",
                       "Dissolved Oxygen" = "Dissolved Oxygen (%)",
                      "Turbidity" = "Turbidity (NTU)",
                      "Total Dissolved Solids" = "Total Dissolved Solids (mg L−1)")
                      
       pt.fill_df<- data.frame(z = rev(melt(pt.filled$z)$value), x = rep(pt.filled$x, each = 40), y = rep(pt.filled$y, 40))
       ggplot(pt.fill_df, aes(x = x, y = y, z = z, fill = z)) +
         geom_raster() +
         stat_contour(color = "black", alpha = 1/4) +
         scale_fill_distiller(name = name, palette= color, direction = 1, na.value="white")+
         theme_minimal() +
         theme(legend.title = element_text(size = 10), legend.justification=c(0,1), legend.position=c(0,1))+
         labs(title = paste(name, "in triangle floodzone of Consumnes River Preserve,", date, sep = " "),x = "Longitude", y = "Latitude")
      }) 
    }
  )

