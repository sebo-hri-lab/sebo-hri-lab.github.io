# these two commands clear the R workspace
rm(list=ls())
cat("\014")

library(lme4)
library(lmerTest)
library(emmeans)

# specify the directory that the csv file is in and the csv file name 
# setwd("Statistics HRI Guide/")
vuln_data_survey <- read.csv("nao_vulnerability_experiment_survey_data.csv", header=T)
# only include in this analysis rows where the include column is 1 
vuln_data_survey <- vuln_data_survey[which(vuln_data_survey$include==1), ]

# specify the factors for the repeated measures data 
vuln_data_survey$condition <- factor(
  vuln_data_survey$condition, 
  levels = 0:2, 
  labels = c("neutral", "vulnerable", "silent")
)
vuln_data_survey$gender_0m_1f <- factor(
  vuln_data_survey$gender_0m_1f, 
  levels = 0:1, 
  labels = c("male", "female")
)
vuln_data_survey$participant_id <- factor(
  vuln_data_survey$participant_id
)
vuln_data_survey$group_id <- factor(
  vuln_data_survey$group_id
)





# ------------------------------------------------------------------------------------------------#
# grouped data + a continuous DV --> linear mixed effects model (lmer)                            #
#  -  We're interested in testing whether the utterances of the robot, which was specified by     #
#     the experimental condition (condition), influenced people's ratings of the warmth of the    #
#     robot (rosas_warmth).                                                                       #
#  -  We use a linear mixed effects model, you can find out more about this model here:           #
#     https://www.rdocumentation.org/packages/lme4/versions/1.1-21/topics/lmer                    #
#  -  We set the REML argument to FALSE while fitting our model and then when we run the model    #
#     for the final analysis, we set REML to TRUE.                                                #
# ------------------------------------------------------------------------------------------------#

warmth_lmer_1 <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +    # random intercept for each group 
    condition + 
    age + 
    gender_0m_1f + 
    avg_familiarity + 
    extraversion_score
  , REML=FALSE,    
  vuln_data_survey)
summary(warmth_lmer_1)

# examine the variance inflation factor (VIF)
# VIF provides a measure of multicollinearity in a set of regression variables
# as a rule of thumb, I was told to remove factors if they got to be larger than 10 
vif(warmth_lmer_1)

# we see that our fixed factors don't seem to be highly correlated, which is good (we don't have)
# to do anything special to accomodate for correlated fixed factors


# now we'll try and get the model with the best fit by eliminiating one by one the fixed factors
# that seem to be contributing the least to the model overall (highest p-value)
# first we'll remove avg_familiarity 
warmth_lmer_2 <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +
    condition + 
    age + 
    gender_0m_1f + 
    extraversion_score
  , REML=FALSE,    
  vuln_data_survey)
summary(warmth_lmer_2)

# next we'll remove extraversion_score
warmth_lmer_3 <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +
    condition + 
    age + 
    gender_0m_1f
  , REML=FALSE,    
  vuln_data_survey)
summary(warmth_lmer_3)

# then we'll remove gender_0m_1f
warmth_lmer_4 <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +
    condition + 
    age 
  , REML=FALSE,    
  vuln_data_survey)
summary(warmth_lmer_4)


# then we'll remove age
warmth_lmer_5 <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +
    condition 
  , REML=FALSE,    
  vuln_data_survey)
summary(warmth_lmer_5)


# now let's figure out which model best fits our data
# we figure out which model best fits our data by looking for the model with the lowest AIC 
# (Akaike information criterion) or BIC (Baysean information criterion). BIC has a heavier penalty
# on having additional variables in your model, which is the largest apparent difference between
# the two criterion. I've usually used AIC. 
anova(
  warmth_lmer_1,
  warmth_lmer_2,
  warmth_lmer_3,
  warmth_lmer_4,
  warmth_lmer_5
)

# we see that warmth_lmer_5 has the lowest AIC of 553.72, so we will use that model moving forward 

# by examining the model residuals, we can make sure our model is fitting the data well
# a residual refers to the amount of variability in a dependent variable that is "left over"
# after accounting for the variability explained by the predictors in your analysis

# so we will plot the residuals, making sure that they're within 3 SDs and don't have any trends
residuals = residuals(warmth_lmer_5, type="pearson")
plot(residuals~vuln_data_survey$condition); abline(h=c(-3,0,3))
plot(residuals~fitted(warmth_lmer_5)); abline(h=c(-3,0,3))

# visualize the model predictions to the response variable
plot(vuln_data_survey$rosas_warmth ~ fitted(warmth_lmer_5)); abline(c(0,0), c(1,1))

# things are looking good, let's now run the final model (from warmth_lmer_5) with REML=TRUE
# and we'll rename the model to warmth_lmer_final

warmth_lmer_final <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +
    condition 
  , REML=TRUE,    
  vuln_data_survey)
summary(warmth_lmer_final)

# we see a singificant difference between the vulnerable and neutral conditions (p = 0.00029),
# and since the estimate of conditionvulnerable is positive, we can conclude that those in the
# vulnerable condition have significantly higher ratings of warmth of the robot than participants
# in the neutral condition

# we also see a significant difference between the silent and netural condition (p = 0.0297), 
# and since the estimate of conditionsilent is negative, we conclude that those in the silent 
# condition have significantly lower ratings of the robot's warmth than participants in the 
# neutral condition

# if we want to see the remaining comparison (between the vulnerable and silent conditions)
# we can relevel our condition variable (making silent the reference condition) and 
# run the model again

vuln_data_survey$condition <- relevel(vuln_data_survey$condition, "silent")

warmth_lmer_final <- lmer(
  rosas_warmth ~ 
    (1 | group_id) +
    condition 
  , REML=TRUE,    
  vuln_data_survey)
summary(warmth_lmer_final)

# we now see a significant difference between the vulnerable and silent conditions (p < 0.001)
# and since the estimate for conditionvulnerable is positive, we conclude that those in the 
# vulnerable condition view the robot to be warmer than participants in the silent condition



# NOTE: If you have a significant interaction term in the final lmer analysis and want to do 
#       post-hoc comparisons, use: 
#       emmeans(warmth_lmer_final, list(pairwise ~ condition_a * condition_b), adjust = "tukey")


