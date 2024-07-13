# Install and load necessary packages
if (!require(plotly)) install.packages("plotly")
library(plotly)

# Create the dataset
dat <- data.frame(
  country = c("Burkina Faso", "Cambodia", "Cote d'Ivoire", "Ghana", "Kenya", "Mozambique"),
  year_menarche = c(2021, 2021, 2021, 2022, 2022, 2022),
  menarche_10 = c(0.7, 0.1, 1.3, 1.1, 0.9, 1.1),
  menarche_11 = c(0.7, 0.5, 3.1, 2.6, 1.2, 4.1),
  menarche_12 = c(5.3, 4.3, 13.1, 8.7, 9.1, 15.0),
  menarche_13 = c(10.8, 11.7, 22.3, 15.7, 17.5, 20.1),
  menarche_14 = c(24.0, 22.0, 26.4, 19.6, 23.5, 23.4)
)

# Convert the data to long format
dat_long <- pivot_longer(dat, cols = starts_with("menarche_"), names_to = "age", values_to = "percentage")

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

# Source your additional R script if needed (uncomment and adjust the path if required)
# source("C:/Users/BC Student/OneDrive - Bennett College/Periods-Worldwide/data/cleaned_data/rosemap.R")

