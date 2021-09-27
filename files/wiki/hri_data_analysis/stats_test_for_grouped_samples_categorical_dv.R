# these two commands clear the R workspace
rm(list=ls())
cat("\014")

# we'll need this package to run our desired model
library(lme4)
library(car)

# specify the directory that the csv file is in and the csv file name 
# setwd("Statistics HRI Guide/")
vuln_data_rm <- read.csv("nao_vulnerability_experiment_repeated_measures_data.csv", header=T)
# only include in this analysis rows where the include column is 1 
vuln_data_rm <- vuln_data_rm[which(vuln_data_rm$include==1), ]

# indicate missing data 
vuln_data_rm[vuln_data_rm == "."] <- NA

# specify the factors for the data
vuln_data_rm$condition <- factor(
  vuln_data_rm$condition, 
  levels = 0:2, 
  labels = c("neutral", "vulnerable", "silent")
)
vuln_data_rm$gender_0m_1f <- factor(
  vuln_data_rm$gender_0m_1f, 
  levels = 0:1, 
  labels = c("male", "female")
)
vuln_data_rm$participant_id <- factor(
  vuln_data_rm$participant_id
)
vuln_data_rm$group_id <- factor(
  vuln_data_rm$group_id
)
vuln_data_rm$did_explain_mistake <- factor(
  vuln_data_rm$did_explain_mistake
)




# ------------------------------------------------------------------------------------------------#
# grouped data + a categorical DV --> genearlized linear mixed effects model (glmer)              #
#  -  We're interested in testing whether the utterances of the robot, which was specified by     #
#     the experimental condition (condition), influenced whether people explained their error to  #
#     their fellow human teammates (did_explain_mistake). This is repeated measures data, meaning #
#     that each participant made multiple mistakes, the mistake round number is represented in    #
#     the round variable.                                                                         #
#  -  We use a generalized linear mixed effects model with a binomial family and logit link       #
#     you can find out more about this model here:                                                #
#     https://www.rdocumentation.org/packages/lme4/versions/1.1-21/topics/glmer                   #
#  -  I've also found this page very helpful (especially in determining model specification):     #
#     https://bbolker.github.io/mixedmodels-misc/glmmFAQ.html                                     #
#  -  I did not use a random slope for each participant over the rounds because our data was      #
#     sparse and each participant only had 2 data points. However, if I did want to include that  #
#     term, it would look like this:  (1 | round | participant_id)                                #
# ------------------------------------------------------------------------------------------------#

explain_error_glmer_1 <- glmer(
  did_explain_mistake ~
    (1 | group_id) +    # random intercept for each group
    condition +
    round + 
    condition * round + 
    age + 
    gender_0m_1f + 
    avg_familiarity + 
    extraversion_score,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_1)

# examine the variance inflation factor (VIF)
# VIF provides a measure of multicollinearity in a set of regression variables
# as a rule of thumb, I was told to remove factors if they got to be larger than 10 
vif(explain_error_glmer_1)

# to try and obtain a better model fit, I'm going to remove the interaction term
# (since it's vif value was above 8)
explain_error_glmer_2 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    age + 
    gender_0m_1f + 
    avg_familiarity + 
    extraversion_score,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_2)

# this model failed to converge, so in order to help convergence, I'll scale some of my factors
# and then try the model again
vuln_data_rm$extraversion_score <- scale(vuln_data_rm$extraversion_score)
vuln_data_rm$age <- scale(vuln_data_rm$age)
vuln_data_rm$avg_familiarity <- scale(vuln_data_rm$avg_familiarity)

explain_error_glmer_2 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    age + 
    gender_0m_1f + 
    avg_familiarity + 
    extraversion_score,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_2)

# it still failed to converge, so I'm going to remove the fixed factor that had the lowest p-value
# from explain_error_glmer_1 --> gender_0m_1f
explain_error_glmer_3 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    age + 
    avg_familiarity + 
    extraversion_score,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_3)

# I'm going to keep removing non-significant contributors to this model until each contributor 
# is either my variable of interest (condition) or is a significant contributor
# this time I'll remove extraversion
explain_error_glmer_4 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    age + 
    avg_familiarity,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_4)

# then age
explain_error_glmer_5 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    avg_familiarity,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_5)

# then avg_familiarity
explain_error_glmer_6 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_6)

# then round
explain_error_glmer_7 <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_7)

# now let's figure out which model best fits our data
# we figure out which model best fits our data by looking for the model with the lowest AIC 
# (Akaike information criterion) or BIC (Baysean information criterion). BIC has a heavier penalty
# on having additional variables in your model, which is the largest apparent difference between
# the two criterion. I've usually used AIC. 
anova(
  explain_error_glmer_1,
  explain_error_glmer_3,
  explain_error_glmer_4,
  explain_error_glmer_5,
  explain_error_glmer_6, 
  explain_error_glmer_7
)

# looking at the result from this model, we see that explain_error_glmer_5 has the lowest AIC, so
# we will use that model moving forward and rename it to explain_error_glmer_final

# you may want to run some tests on the model residuals and graph the model fit to the results
# to ensure that this is a good model fit; I don't go into it here, but it's worth researching 
# if you're running these kinds of models

explain_error_glmer_final <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    avg_familiarity,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_final)

# this summary gives us the comparisons between the vulnerable and neutral conditions 
# as well as the comparison between the silent and neutral conditions

# we see that there is a significant difference between the vulnerable and neutral conditions
# and since the estimate is positive, we can conclude that more people in the vulnerabe condition
# explain their error to their teammates than people in the neutral condition

# there is no significant difference between people in the neutral and silent conditions

# if we want to see the remaining comparison (between the vulnerable and silent conditions)
# we can relevel our condition variable (making silent the reference condition) and 
# run the model again

vuln_data_rm$condition <- relevel(vuln_data_rm$condition, "silent")

explain_error_glmer_final <- glmer(
  did_explain_mistake ~
    (1 | group_id) + 
    condition +
    round + 
    avg_familiarity,
  family=binomial(link = "logit"),
  data=vuln_data_rm
)
summary(explain_error_glmer_final)

# we can now see the comparison between the vulnerable condition and the silent condition
# because the estimate of "conditionvulnerable" is positive, we can conclude that more people
# in the vulnerable condition as opposed to the silent condition explained their error to their 
# teammates 


