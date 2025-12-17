library(ggplot2)
library(readxl)
library(gridExtra)
library(dplyr)

# Importing standards data
Standards <- data.frame(read_excel("/Users/erikgudmunds/Documents/20E ELISA/20E_Data_and_analysis.xlsx",
                                   sheet = "R_standards"))
str(Standards)
# Fixing objects
Standards$Concentration <- as.numeric(Standards$Concentration)
Standards$Plate <- as.factor(Standards$Plate)

#Setting decimals  
Standards <- Standards %>%
  mutate(
    Tech_avg_Net = round(Tech_avg_Net, 4),
    B_B0 = round(B_B0, 1)
  )
# Importing samples data
R_450_data <- data.frame(read_excel("/Users/erikgudmunds/Documents/20E ELISA/20E_Data_and_analysis.xlsx",
                                    sheet = "R_450_data"))

str(R_450_data)

# Fixing objects
R_450_data$Plate <- as.factor(R_450_data$Plate)
str(R_450_data)

#Setting decimals
R_450_data <- R_450_data %>%
mutate(
  Tech_avg_Net = round(Tech_avg_Net, 4),
  B_B0 = round(B_B0, 1),
  Rel_dev = round(Rel_dev, 0)
)
str(R_450_data)

#Plotting standards B_B0
str(Standards)

ggplot(Standards, aes(x = B_B0, y = Concentration, color = Plate)) +
  geom_point()+ 
  theme_classic()+
  scale_color_brewer(palette="Dark2")+
  scale_fill_brewer(palette="Dark2")+
  theme(legend.position="top")+
  labs(title = "Net OD 450 nm")

#Modeling plate 1 curves. A 5 degree polynomial fits the data best, I erased the code for the rest. 

Plate1_model5 <- lm(Concentration~poly(B_B0,5,raw=TRUE), data=subset(Standards, Plate == 1)) 
summary(Plate1_model5)$adj.r.squared ## Best!

#Modeling plate 2 curves. A 5 degree polynomial fits the data best, I erased the code for the rest. 

Plate2_model5 <- lm(Concentration~poly(B_B0,5,raw=TRUE), data=subset(Standards, Plate == 2)) 
summary(Plate2_model5)$adj.r.squared ## Best!

# Generation concentration estimates for samples using the standard curve models

Concentrations_plate1 <- predict(Plate1_model5, R_450_data)
Concentrations_plate2 <- predict(Plate2_model5, R_450_data)
str(Concentrations_plate1)
str(Concentrations_plate2)
Concentration <- c(Concentrations_plate1,Concentrations_plate2)
R_450_data <- cbind(R_450_data,Concentration)
str(R_450_data)

# Plotting raw concentrations

R_450_data$Photoperiod <- as.factor(R_450_data$Photoperiod)
Total_20E <- R_450_data$Concentration*2.5
R_450_data <- cbind(R_450_data,Total_20E)

Raw_20E <- ggplot(R_450_data, aes(x = as.factor(HAE), y = Total_20E, color = Photoperiod)) +
  geom_boxplot() + 
  theme_classic() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  theme(legend.position = "none") +
  facet_wrap(~Photoperiod)+
  labs(title = "")
Raw_20E

# Plotting weight-normalized concentrations

Per_mg <- R_450_data$Concentration/R_450_data$Weight
R_450_data <- cbind(R_450_data,Per_mg)

normalized_concentrations <- ggplot(R_450_data, aes(x = as.factor(HAE), y = Per_mg, color = Photoperiod)) +
  geom_boxplot() + 
  theme_classic() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  theme(
    legend.position = "none",
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 14),
    strip.text = element_blank() # Removes facet labels
  ) +
  facet_wrap(~Photoperiod) +
  labs(
    title = "",
    y = "20E (pg) / mg", # Y-axis label
    x = "Hours after i5 eclosion" # X-axis label
  )

# Print the plot
normalized_concentrations


# Comparing the raw vs. weight-normalized plots
grid.arrange(normalized_concentrations, avg_plot, nrow = 1)


# Calculate  average and standard error
R_450_data_avg <- R_450_data %>%
  group_by(HAE, Photoperiod) %>%
  summarise(
    Mean_Per_mg_bodyweight = mean(Per_mg, na.rm = TRUE),
    SE_Per_mg_bodyweight = sd(Per_mg, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Plot average with error shading, facets vertically aligned
avg_plot <- ggplot(R_450_data_avg, aes(x = as.numeric(HAE), y = Mean_Per_mg_bodyweight, color = Photoperiod, fill = Photoperiod)) +
  # Error shading (confidence interval)
  geom_ribbon(aes(ymin = Mean_Per_mg_bodyweight - SE_Per_mg_bodyweight, 
                  ymax = Mean_Per_mg_bodyweight + SE_Per_mg_bodyweight, 
                  fill = Photoperiod), 
              alpha = 0.2, color = NA) +
  # Running average line
  geom_line(size = 1.5, linetype = "solid") +
  # Apply themes and labels
  theme_classic() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(
    breaks = c(0, 24, 36, 48, 60, 72, 96, 120), # Specify custom tick marks
    labels = c("0", "24", "36", "48", "60", "72", "96", "120") # Custom labels
  ) +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14,),
    strip.text = element_text(size = 14,) # Adjust facet label style
  ) +
  labs(
    title = "",
    y = "20E (pg) / mg", # Y-axis label
    x = "Hours after i5 eclosion" # X-axis label
  )

grid.arrange(normalized_concentrations, avg_plot, nrow=1)

# Generalized additive model for comparison of 20E titer between 12:12 and 18:6

##### Generalized additive model ########
library(mgcv)

# Fit a GAM model with reduced degrees of freedom for the spline term
gam_model <- gam(Per_mg ~ s(HAE, by = Photoperiod, k = 7) + Photoperiod, data = R_450_data)

# Summary of the model
summary(gam_model)

# Plot the smooths
plot(gam_model, pages = 1, rug = TRUE)

# To test for the interaction significance (whether the smooth terms differ between photoperiods)
anova(gam_model)


# Fit a simpler model without the interaction between HAE and Photoperiod
gam_simple <- gam(Per_mg ~ s(HAE, k = 4) + Photoperiod, data = R_450_data)

# Compare models using anova (likelihood ratio test)
anova(gam_simple, gam_model, test = "F")
##### Generalized additive model ########



Rel_dev_plot <- ggplot(R_450_data, aes(x = as.factor(Rel_dev), y = Per_mg, color = Photoperiod)) +
  geom_boxplot() + 
  theme_classic() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  theme(
    legend.position = "none",
    axis.text = element_text(size = 8),
    axis.title = element_text(size = 14),
    strip.text = element_blank() # Removes facet labels
  ) +
  
  labs(
    title = "",
    y = "20E (pg) / mg", # Y-axis label
    x = "Hours after i5 eclosion" # X-axis label
  )

grid.arrange(normalized_concentrations, Rel_dev_plot, nrow=1)



# Relative development average plot
# Calculate  average and standard error
R_450_data_avg <- R_450_data %>%
  group_by(Rel_dev, Photoperiod) %>%
  summarise(
    Mean_Per_mg_bodyweight = mean(Per_mg, na.rm = TRUE),
    SE_Per_mg_bodyweight = sd(Per_mg, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Plot average with error shading, facets vertically aligned
Rel_dev_avg_plot <- ggplot(R_450_data_avg, aes(x = as.numeric(Rel_dev), y = Mean_Per_mg_bodyweight, color = Photoperiod, fill = Photoperiod)) +
  # Error shading (confidence interval)
  geom_ribbon(aes(ymin = Mean_Per_mg_bodyweight - SE_Per_mg_bodyweight, 
                  ymax = Mean_Per_mg_bodyweight + SE_Per_mg_bodyweight, 
                  fill = Photoperiod), 
              alpha = 0.2, color = NA) +
  # Running average line
 geom_line(size = 1.5, linetype = "solid") +
  # Apply themes and labels
  theme_classic() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(
    breaks = c(0, 15, 30, 45, 60, 75, 90, 105), # Specify custom tick marks
    labels = c("0", "15", "30", "50", "60", "75", "85", "100") # Custom labels
  ) +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14,),
    strip.text = element_text(size = 14,) # Adjust facet label style
  ) +
  labs(
    title = "",
    y = "20E (pg) / mg", # Y-axis label
    x = "% Development" # X-axis label
  )



grid.arrange(normalized_concentrations, Rel_dev_avg_plot, nrow=1)













