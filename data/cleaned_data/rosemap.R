# Install and load necessary packages
if (!require(plotly)) install.packages("plotly")
library(plotly)
# Convert the age to a more readable format
dat_long$age <- sub("menarche_", "", dat_long$age)

# Create the rose map plot
fig <- plot_ly(
  data = dat_long,
  r = ~percentage,
  theta = ~age,
  type = "barpolar",
  color = ~country,
  hovertemplate = paste('Percentage: %{r}', '<br>Age: %{theta}', '<br>Country: %{country}<br>')
) %>%
  layout(
    legend = list(title = list(text = 'Country')),
    polar = list(
      angularaxis = list(rotation = 90, direction = 'clockwise', period = 6)
    ),
    margin = list(l = 0, r = 0, t = 0, b = 0)
  )
# Display the plot
fig
