# these two commands clear the R workspace
rm(list=ls())
cat("\014")

# specify the directory that the csv file is in and the csv file name 
setwd("~/Documents/UChicago/Courses/Topics in HRI/Fall 2020/Presentations/Statistics HRI Guide/")
jibo_is_data <- read.csv("jibo_survival_experiment_data_independent_samples.csv", header=T)

# indicate missing data 
jibo_is_data[jibo_is_data == "NA"] <- NA

# for any variables that are categorical, specify them as factors
jibo_is_data$condition_2_Lin_3_Lout <- factor(
  jibo_is_data$condition_2_Lin_3_Lout, 
  levels = 2:3, 
  labels = c("liaison_ingroup", "liaison_outgroup")
)
jibo_is_data$condition_1_Rbc_0_Rnobc <- factor(
  jibo_is_data$condition_1_Rbc_0_Rnobc, 
  levels = 0:1, 
  labels = c("backchanneling_robot", "silent_robot")
)
jibo_is_data$produced_more_than_100_bcs <- factor(
  jibo_is_data$produced_more_than_100_bcs, 
  levels = 0:1, 
  labels = c("less_than_100_bcs_produced", "more_than_100_bcs_produced")
)


# ------------------------------------------------------------------------------------------------#
# one categorical IV and one categorical DV --> Chi Square Test of Independence                   #
#  -  we will test whether the between subjects condition of whether the robot is backchanneling  #
#     or not (condition_1_Rbc_0_Rnobc) influences whether the group produces over 100             #
#     verbal backchannels towards one another or not (produced_more_than_100_bcs)                 #
#  -  we will use a chi square test of independence to test this relationship                     #  
# ------------------------------------------------------------------------------------------------#

# remove the NA data in our dependent variable
jibo_is_data_prod_more_100_bcs <- jibo_is_data[!is.na(jibo_is_data["produced_more_than_100_bcs"]), ]

# create the chi square table
table_bc_robot_and_prod_100_bcs <- table(
  jibo_is_data_prod_more_100_bcs$condition_1_Rbc_0_Rnobc,
  jibo_is_data_prod_more_100_bcs$produced_more_than_100_bcs
)

# you can take a look at the table
table_bc_robot_and_prod_100_bcs

# run the test
chisq.test(
  table_bc_robot_and_prod_100_bcs,
  correct=FALSE
)











# ------------------------------------------------------------------------------------------------#
# one categorical IV and one continuous DV --> t-test                                             #
#  -  we will test whether the average group psychological safety scores                          #
#     (avg_psychological_safety) are different between groups with a backchanneling robot and     #
#     groups without a backchanneling robot (condition_1_Rbc_0_Rnobc)                             #
#  -  we will use an independent samples t-test for 2 groups                                      #
#  -  info on other types of t-test can be found: https://www.statmethods.net/stats/ttest.html    #
# ------------------------------------------------------------------------------------------------#

# run the t-test
t.test(jibo_is_data$avg_psychological_safety ~ jibo_is_data$condition_1_Rbc_0_Rnobc)
# we see that the condition of whether the robot backchannels or not does not have a significant
# influence on the group's average psychological safety











# ------------------------------------------------------------------------------------------------#
# one categorical IV and one continuous DV --> 1-way ANOVA                                        #
#  -  we will test whether the average group psychological safety scores                          #
#     (avg_psychological_safety) are different between groups with a backchanneling robot and     #
#     groups without a backchanneling robot (condition_1_Rbc_0_Rnobc) controlling for             #
#     various factors (e.g. age, emotional intelligence, number of females)                       #
#  -  we will use a 1-way ANOVA test                                                              #
#  -  more info on the 1-way ANOVA can be found here:                                             #
#     http://www.sthda.com/english/wiki/one-way-anova-test-in-r                                   #
# ------------------------------------------------------------------------------------------------#

# run the 1-way ANOVA
psych_safety_bc_robot_aov <- aov(
  avg_psychological_safety ~
    condition_1_Rbc_0_Rnobc + 
    avg_age + 
    num_females + 
    avg_extraversion + 
    avg_emotional_intelligence,
  data = jibo_is_data)

# view the ANOVA's results
summary(psych_safety_bc_robot_aov)
# we see that the psychological safety scores are not significantly different between the 
# conditions where the robot does and does not backchannel

# if you're interested in seeing the mean values for the psychological safety scores for variables
# that are significantly correlated with the average psychological safety scores use the aggregate
# command; here we see that the psychological safety scores increase as the number of females on 
# the team increase
aggregate(
  jibo_is_data$avg_psychological_safety,
  jibo_is_data['num_females'],
  mean
)











# ------------------------------------------------------------------------------------------------#
# two categorical IVs and one categorical DV --> logistic regression                              #
#  -  we will test whether the between subjects condition of whether the robot is backchanneling  #
#     or not (condition_1_Rbc_0_Rnobc) and the between subjects condition of whether              #
#     the robot liaison is an insider group member or outsider group member                       #
#     (condition_2_Lin_3_Lout) influences whether the group produces over 100                     #
#     verbal backchannels towards one another or not (produced_more_than_100_bcs), controlling    #
#     for average extraversion, average emotional intelligence, and the number of females on the  #
#     team                                                                                        #
#  -  we will use a logistic regression (glm with binomial family with logit link)                #
#  -  you can find more out about R's glm at                                                      #
#     https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/glm                     #
# ------------------------------------------------------------------------------------------------#

prod_100_bcs_glm <- glm(
  produced_more_than_100_bcs ~
    condition_1_Rbc_0_Rnobc + 
    condition_2_Lin_3_Lout + 
    condition_1_Rbc_0_Rnobc * condition_2_Lin_3_Lout +  # the interaction term
    avg_extraversion + 
    avg_emotional_intelligence + 
    num_females,
  data = jibo_is_data,
  family = binomial,   # more info on families can be found here: https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/family
  na.action = na.omit   # this takes care of removing all of the NA data
)

summary(prod_100_bcs_glm)











# ------------------------------------------------------------------------------------------------#
# two categorical IVs and one continous DV --> 2-way ANOVA                                        #
#  -  we will test whether the average group psychological safety scores                          #
#     (avg_psychological_safety) are different between groups with a backchanneling robot and     #
#     groups without a backchanneling robot (condition_1_Rbc_0_Rnobc) as well as whether the      #
#     robot liaison is an ingroup or outgroup member (condition_2_Lin_3_Lout), controlling for    #
#     various factors (e.g. age, emotional intelligence, number of females)                       #
#  -  we will use a 2-way ANOVA test                                                              #
# ------------------------------------------------------------------------------------------------#

# run the 2-way ANOVA
psych_safety_2_way_aov <- aov(
  avg_psychological_safety ~
    condition_1_Rbc_0_Rnobc + 
    condition_2_Lin_3_Lout + 
    condition_1_Rbc_0_Rnobc * condition_2_Lin_3_Lout +
    avg_age + 
    num_females + 
    avg_extraversion + 
    avg_emotional_intelligence,
  data = jibo_is_data)

# view the ANOVA's results
summary(psych_safety_2_way_aov)

# if you were to find a significant interaction term in the anova (p value of the interaction term
# that is smaller than 0.05), then you would run pairwise comparisons to investigate that 
# interaction further 
TukeyHSD(psych_safety_2_way_aov, "condition_1_Rbc_0_Rnobc", ordered = FALSE)

# if you're using a different method for performing pairwise comparisons, you may need to use some
# kind of statistical correction, a common one to perform is the Bonferroni correction - which is 
# one of the strictest forms of corrections
# if you're interested in using the Bonferroni correction, information can be found here on how to 
# run it: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/p.adjust.html











# ------------------------------------------------------------------------------------------------#
# one continuous IV and one categorical DV --> Pearson correlation                                #
#  -  we want to test if there is a significant linear correlation between the group's average    #
#     emotional intelligence (avg_emotional_intelligence) and whether or not the group produces   #
#     more than 100 backchannels (produced_more_than_100_bcs_numeric)                             #
#  -  use a Pearson correlation                                                                   #
#  -  if you want to control for other factors/control variables, run a logistic regression       #
#     instead (see logistic regression example above)                                             #
# ------------------------------------------------------------------------------------------------#

# you can't run Pearson correlations on factored variables, so we'll turn our factor variable into
# a numeric variable
jibo_is_data$produced_more_than_100_bcs_numeric <- as.numeric(jibo_is_data$produced_more_than_100_bcs)

cor.test(
  jibo_is_data$avg_emotional_intelligence, 
  jibo_is_data$produced_more_than_100_bcs_numeric,
  method="pearson",  # specify that you want it to be a Pearson correlation
  na.action=na.omit  # omit the missing (NA) data if any
)











# ------------------------------------------------------------------------------------------------#
# one continuous IV and one continuous DV --> linear regession                                    #
#  -  we want to test whether the number of robot backchannels (num_robot_bcs) influenced the     #
#     group's average psychological safety score (avg_psychological_safety), controlling for our  #
#     experimental conditions as well as other factors (e.g. age, emotional intelligence, number  #
#     of females)                                                                                 #
#  -  we will use a linear regression                                                             #
# ------------------------------------------------------------------------------------------------#

rbc_on_ps <- lm(
  avg_psychological_safety ~
    num_robot_bcs + 
    condition_1_Rbc_0_Rnobc + 
    condition_2_Lin_3_Lout + 
    condition_1_Rbc_0_Rnobc * condition_2_Lin_3_Lout +
    avg_age + 
    num_females + 
    avg_extraversion + 
    avg_emotional_intelligence,
  data = jibo_is_data
)

summary(rbc_on_ps)















