library(ggplot2)
library(tidyr)
library(dplyr)
library(patchwork)

# Read the data
data <- read.csv("menopause_wide.csv")

# Define the region mapping with continents
region_mapping <- c(
  # Africa
  Egypt = "Africa/Northern Africa",
  Morocco = "Africa/Northern Africa",
  Burundi = "Africa/Eastern Africa",
  Comoros = "Africa/Eastern Africa",
  Eritrea = "Africa/Eastern Africa",
  Ethiopia = "Africa/Eastern Africa",
  Kenya = "Africa/Eastern Africa",
  Madagascar = "Africa/Eastern Africa",
  Malawi = "Africa/Eastern Africa",
  Mozambique = "Africa/Eastern Africa",
  Rwanda = "Africa/Eastern Africa",
  Tanzania = "Africa/Eastern Africa",
  Uganda = "Africa/Eastern Africa",
  Zambia = "Africa/Eastern Africa",
  Zimbabwe = "Africa/Eastern Africa",
  Angola = "Africa/Middle Africa",
  Cameroon = "Africa/Middle Africa",
  `Central African Republic` = "Africa/Middle Africa",
  Chad = "Africa/Middle Africa",
  Congo = "Africa/Middle Africa",
  `Congo Democratic Republic` = "Africa/Middle Africa",
  Gabon = "Africa/Middle Africa",
  `Sao Tome and Principe` = "Africa/Middle Africa",
  Eswatini = "Africa/Southern Africa",
  Lesotho = "Africa/Southern Africa",
  Namibia = "Africa/Southern Africa",
  `South Africa` = "Africa/Southern Africa",
  Benin = "Africa/Western Africa",
  `Burkina Faso` = "Africa/Western Africa",
  `Cote d'Ivoire` = "Africa/Western Africa",
  Gambia = "Africa/Western Africa",
  Ghana = "Africa/Western Africa",
  Guinea = "Africa/Western Africa",
  Liberia = "Africa/Western Africa",
  Mali = "Africa/Western Africa",
  Mauritania = "Africa/Western Africa",
  Niger = "Africa/Western Africa",
  Nigeria = "Africa/Western Africa",
  Senegal = "Africa/Western Africa",
  `Sierra Leone` = "Africa/Western Africa",
  Togo = "Africa/Western Africa",

  # Asia
  Afghanistan = "Asia/Central Asia",
  Kazakhstan = "Asia/Central Asia",
  `Kyrgyz Republic` = "Asia/Central Asia",
  Tajikistan = "Asia/Central Asia",
  Turkmenistan = "Asia/Central Asia",
  Uzbekistan = "Asia/Central Asia",
  Bangladesh = "Asia/Southern Asia",
  India = "Asia/Southern Asia",
  Maldives = "Asia/Southern Asia",
  Nepal = "Asia/Southern Asia",
  Pakistan = "Asia/Southern Asia",
  Armenia = "Asia/Western Asia",
  Azerbaijan = "Asia/Western Asia",
  Jordan = "Asia/Western Asia",
  Turkey = "Asia/Western Asia",
  Yemen = "Asia/Western Asia",
  Cambodia = "Asia/Southeastern Asia",
  Indonesia = "Asia/Southeastern Asia",
  Myanmar = "Asia/Southeastern Asia",
  Philippines = "Asia/Southeastern Asia",
  `Timor-Leste` = "Asia/Southeastern Asia",
  Vietnam = "Asia/Southeastern Asia",

  # Europe
  Moldova = "Europe/Eastern Europe",
  Ukraine = "Europe/Eastern Europe",

  # Americas
  Bolivia = "Americas/South America",
  Brazil = "Americas/South America",
  Colombia = "Americas/South America",
  Guyana = "Americas/South America",
  Paraguay = "Americas/South America",
  Peru = "Americas/South America",
  `Dominican Republic` = "Americas/Caribbean",
  Haiti = "Americas/Caribbean",

  # Oceania
  `Papua New Guinea` = "Oceania/Melanesia"
)


# Prepare data for rose chart with updated age group labels
data_long <- data %>%
  pivot_longer(
    cols = starts_with("menopause_"),
    names_to = "age_group",
    values_to = "percentage"
  ) %>%
  mutate(
    age_group = sub("menopause_", "", age_group),
    region = region_mapping[country],
    continent = sub("/.*", "", region),
    subregion = sub(".*?/", "", region),
    age_group_label = case_when(
      age_group == "30.34" ~ "30-34",
      age_group == "35.39" ~ "35-39",
      age_group == "40.41" ~ "40-41",
      age_group == "42.43" ~ "42-43",
      age_group == "44.45" ~ "44-45",
      age_group == "46.47" ~ "46-47",
      age_group == "48.49" ~ "48-49",
      TRUE ~ age_group
    )
  )

# Function to create a rose chart for a given set of countries
create_rose_chart <- function(region_data, group_name) {
  ggplot(region_data, aes(
    x = country,
    y = -percentage,
    fill = factor(
      age_group_label,
      levels = c("30-34", "35-39", "40-41", "42-43", "44-45", "46-47", "48-49")
    )
  )) +
    geom_bar(
      stat = "identity",
      position = "fill",
      width = 0.9,
      color = "black",
      size = 0.1
    ) +
    coord_polar(clip = "off") +
    scale_fill_viridis_d(option = "turbo", alpha = 0.7) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(
        angle = 0,
        hjust = 2,
        vjust = -1,
        size = 6
      ),
      legend.position = "right",
      legend.key.size = unit(0.5, "cm"),
      legend.text = element_text(size = 8),
      legend.title = element_text(size = 10),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(
        color = "lightgrey",
        fill = NA,
        size = 0.5
      ),
      # Light grey box around each plot
      axis.title = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      plot.title = element_text(size = 8, face = "bold"),
      plot.margin = margin(15, 5, 15, 5)
    ) +
    expand_limits(y = c(-0.4, 0.1))  # Adjust this to reduce center whitespace
}
# Group all countries into sets of 5
# Sort countries by continent and then alphabetically by country
data_long <- data_long %>% arrange(continent, country)

# Convert 'country' to factor in the sorted order of continent and country
data_long$country <- factor(data_long$country, levels = unique(data_long$country))

# Extract unique countries and group them into sets of 5
all_countries <- unique(data_long$country)
country_groups <- split(all_countries, ceiling(seq_along(all_countries) /
                                                 5))
# Create plots and display them
plots <- lapply(seq_along(country_groups), function(i) {
  group_data <- data_long %>% filter(country %in% country_groups[[i]])
  create_rose_chart(group_data, paste("Group", i))
})

combined_plot <- wrap_plots(plots, ncol = 4) +
  plot_layout(
    # widths = rep(1, 4),
    #           heights = rep(1, 4),
              guides = "collect") +
  theme(
    legend.position = "right",
    legend.key.size = unit(0.5, "cm"),
    legend.text = element_text(size = 8),
    legend.title = element_text(size = 10),
    panel.spacing = unit(1, "lines")  # Decrease the space between plots
  )

# Add a title to the combined plot
final_plot <- combined_plot +
  plot_annotation(title = "Menopause Onset by Age Group Across Countries",
                  theme = theme(plot.title = element_text(hjust = 0.5, size = 16))) &
  theme(plot.margin = margin(12, 12, 12, 12)) &
  guides(
    fill = guide_legend(
      title = "Age Group",
      nrow = 7,
      label.position = "right",
      keywidth = unit(0.4, "cm"),
      keyheight = unit(0.4, "cm"),
      override.aes = list(size = 2)
    )
  )

# Display the final plot
print(final_plot)
# Save the combined plot
ggsave("menopause_rose_charts_all_countries.jpg", final_plot, width = 20, height = 24, dpi = 300)






#---------------------------------END---------------------------------

# RADAR PLOT ----

# # Read the data
# data <- read.csv("menopause_wide.csv")
# 
# # Prepare data for radar chart
# data_long <- data %>%
#   pivot_longer(cols = starts_with("menopause_"), names_to = "age_group", values_to = "percentage") %>%
#   mutate(
#     age_group = sub("menopause_", "", age_group),
#     age_group = case_when(
#       age_group == "30.34" ~ 32,
#       age_group == "35.39" ~ 37,
#       age_group == "40.41" ~ 40.5,
#       age_group == "42.43" ~ 42.5,
#       age_group == "44.45" ~ 44.5,
#       age_group == "46.47" ~ 46.5,
#       age_group == "48.49" ~ 48.5
#     )
#   )
# 
# # Calculate average age of onset
# data_avg <- data_long %>%
#   group_by(country) %>%
#   summarize(avg_age = sum(age_group * percentage) / sum(percentage))
# 
# # Sort countries alphabetically
# data_avg <- data_avg %>% arrange(country)
# 
# # Group countries into sets of 5
# country_groups <- split(data_avg$country, ceiling(seq_along(data_avg$country)/5))
# # Function to create a radar chart for a given set of countries
# # Function to create a radar chart for a given set of countries
# create_radar_chart <- function(group_data) {
#   ggplot(group_data, aes(x = factor(country, levels = unique(country)), y = avg_age)) +
#     geom_polygon(aes(group = 1), fill = "lightblue", alpha = 0.8) +
#     # geom_line(aes(group = 1), color = "blue") +
#     # geom_point(color = "blue", size = 3) +
#     coord_polar() +
#     scale_y_continuous(limits = c(42, 47), breaks = seq(40, 50, by = 2)) +
#     theme_minimal() +
#     theme(
#       axis.text.x = element_text(angle = 0, hjust = 1, size = 8),
#       axis.text.y = element_text(size = 8),
#       panel.grid.major = element_line(color = "grey80"),
#       axis.title = element_blank()
#     )
# }
# # Create plots for each group of countries
# plots <- lapply(country_groups, function(group) {
#   group_data <- data_avg %>% filter(country %in% group)
#   create_radar_chart(group_data)
# })
# 
# # Combine all plots using patchwork
# combined_plot <- wrap_plots(plots, ncol = 4) +
#   plot_layout(guides = "collect") +
#   theme(legend.position = "none")
# 
# # Add a title to the combined plot
# final_plot <- combined_plot +
#   plot_annotation(
#     title = "Average Age of Menopause Onset Across Countries",
#     theme = theme(plot.title = element_text(hjust = 0.5, size = 16))
#   )
# 
# # Display the final plot
# print(final_plot)
# # Save the combined plot
# # ggsave("menopause_radar_charts_all_countries.jpg", final_plot, width = 20, height = 24, dpi = 300)