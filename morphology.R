# R-code to visualize and analyze morphological differences between G. buenoi wing morphs. Source data: Supp File 1 and Supp File 2. 

library(ggplot2)
library(readxl)
library(gridExtra)
library(visreg)
library(viridis)

setwd("~/Desktop/")

# Figure code - instar 5 measurements -------------------------------------------------------------------------------------------------------

instar5_measurements <- read_excel("Supplemental_Files.xlsx", sheet = "Supp File 1", skip = 2, col_names = TRUE)  ## Instar 5 measurements
instar5_measurements$WBlength <- as.numeric(instar5_measurements$WBlength)
instar5_measurements$TibiaLength <- as.numeric(instar5_measurements$TibiaLength)

wing_buds_fig <- ggplot(instar5_measurements, aes(x=TibiaLength, y=WBlength, color=Photoperiod, shape=Photoperiod)) +
  geom_point(aes(fill=Photoperiod), color='black', size=2) +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.y = element_text(size=15),
        axis.text.x = element_text(size=15),
        axis.ticks.x = element_line(),
        axis.title = element_text(size = 15, face="bold")) +
  scale_shape_manual(values=c(21, 23)) +
  scale_color_manual(values = c("lightblue", "orange")) +
  scale_fill_manual(values = c("lightblue", "orange")) +
  ylab("i5 Wing bud length (mm)") + xlab("Tibia length (mm)")
wing_buds_fig
  
ggsave("./Morphology/wingbuds.png", plot = wing_buds_fig, dpi = 1000, height = 3, width = 4.5)
ggsave("./Morphology/wingbuds.pdf", plot = wing_buds_fig, dpi = 1000, height = 3, width = 4.5)
ggsave("./Morphology/wingbuds.pdf", plot = wing_buds_fig, dpi = 1000, height = 3.5, width = 3.5)
ggsave("./Morphology/wingbuds.pdf", plot = wing_buds_fig, dpi = 1000, height = 3.5, width = 3.5)
ggsave("./Morphology/wingbuds.png", plot = wing_buds_fig, dpi = 1000, height = 3.5, width = 3.5)


# Figure code - adult measurements -------------------------------------------------------------------------------------------------------  

adult_measurements <- read_excel("Supplemental_Files.xlsx", sheet = "Supp File 2", skip = 2, col_names = TRUE)  ## Adult measurements
adult_measurements$Wing_length_mean <- as.numeric(adult_measurements$Wing_length_mean)
adult_measurements$Body_length_mean <- as.numeric(adult_measurements$Body_length_mean)
str(adult_measurements)

wing_length_fig <-ggplot(adult_measurements, aes(x=Body_length_mean, y=Wing_length_mean, color=Photoperiod, shape=Photoperiod)) +
  geom_point(aes(fill=Photoperiod), color="black", size = 2.5) +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.y = element_text(size=15),
        axis.text.x = element_text(size=15),
        axis.ticks.x = element_line(),
        axis.title = element_text(size = 15, face="bold")) +
  scale_shape_manual(values=c(21, 23)) +
  scale_color_manual(values = c("lightblue", "orange")) +
  scale_fill_manual(values = c("lightblue", "orange")) +
  scale_x_continuous(expand = c(0.01, 0.01)) +
  xlab("Body length (mm)") + ylab("Wing length (mm)")

wing_length_fig

ggsave("./Morphology/wing_body.pdf", plot = plot_simple, dpi = 1000, height = 3, width = 3.5)
ggsave("./Morphology/wing_body.png", plot = plot_simple, dpi = 1000, height = 3, width = 3.5)
ggsave("./Morphology/wing_body.pdf", plot = wing_length_fig, dpi = 1000, height = 3, width = 3.5)
ggsave("./Morphology/wing_body.pdf", plot = wing_length_fig, dpi = 1000, height = 3, width = 3.5)
ggsave("./Morphology/wing_body.png", plot = wing_length_fig, dpi = 1000, height = 3, width = 3.5)
ggsave("./Morphology/wing_body.pdf", plot = wing_length_fig, dpi = 1000, height = 3, width = 4.5)
ggsave("./Morphology/wing_body.pdf", plot = wing_length_fig, dpi = 1000, height = 3, width = 4.5)
ggsave("./Morphology/wing_body.png", plot = wing_length_fig, dpi = 1000, height = 3, width = 4.5)


# Statistical analysis of instar 5 morphological measurements ---------------------------------------------------------------------------

str(instar5_measurements)

t.test(instar5_measurements$WBlength~instar5_measurements$Photoperiod)
t#Interpretation: Significant effect of photoperiod on wing bud length. ( B = )


t.test(instar5_measurements$TibiaLength~instar5_measurements$Photoperiod) 

#Interpretation: No significant effect of photoperiod on tibia length (body size proxy).


WB18 <- subset(instar5_measurements, Photoperiod == "18:6")
WB12<- subset(instar5_measurements, Photoperiod == "12:12")

summary(lm(WB12$WBlength~WB12$TibiaLength)) 
#Interpretation: Wing bud length in 12:12 scales significantly with tibia length (B = 0.23, t = 4.868, p = 0.29*10^-6). 

summary(lm(WB18$WBlength~WB18$TibiaLength))
#Interpretation: Wing bud length in 12:12 scales significantly with tibia length (B = 0.16, t = 3.770, p = 0.000385). 



# Statistical analysis of adult morphological measurements -------------------------------------------------------------------------------

str(adult_measurements)

AdWing12<- subset(adult_measurements, Photoperiod == "12:12")
AdWing18 <- subset(adult_measurements, Photoperiod == "18:6")


summary(lm(AdWing12$Wing_length_mean~AdWing12$Body_length_mean)) 
#Interpretation: Adult wing length in 12:12 (LW-inducing conditions) scales positively with body length (t = 13.347, p < 2*10^-16)


summary(lm(AdWing18$Wing_length_mean~AdWing18$Body_length_mean)) 
#Interpretation: Adult wing length in 18:6 (SW-inducing conditions) do not scale  with body length (t = 1.353, p = 0.179)






















