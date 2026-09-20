# Project:
# The Velocity of Virality: A Statistical Analysis of Algorithmic
# Acceleration and Engagement Ratios on YouTube

# Import packages
# install.packages("tidyverse")
# install.packages("gt")
# install.packages("effectsize")

library(tidyverse)
library(lubridate)
library(jsonlite)
library(ggplot2)
library(car)
library(rstatix)
library(gridExtra)
library(gt)
library(effectsize)

# US data
us_data <- read.csv("./data/USvideos.csv")

# Germany data
de_data <- read.csv("./data/DEvideos.csv")

# South Korea data
# Data needs to be imported using UTF-8 because the default ASCII cannot parse
# multi-byte Korean characters
kr_data <- read.csv("./data/KRvideos.csv", 
                    fileEncoding = "UTF-8", 
                    encoding = "UTF-8")


View(us_data)
glimpse(us_data)

View(de_data)
glimpse(de_data)

View(kr_data)
glimpse(kr_data)

# Data cleaning
colSums(is.na(us_data))

colSums(is.na(de_data))

colSums(is.na(kr_data))
# No nulls found in either dataset


sum(duplicated(us_data))
# 48 duplicates found in the US videos dataset

sum(duplicated(de_data))

sum(duplicated(kr_data))

View(us_data[duplicated(us_data) | duplicated(us_data, fromLast = "TRUE"), ])

us_duplicates <- 
  us_data[duplicated(us_data) | duplicated(us_data, fromLast = "TRUE"), ]

View(us_duplicates[1:48, ])
View(us_duplicates[49:96, ])

us_data <- us_data[!duplicated(us_data), ]
# Duplicates are not useful for this research


us_data$trending_date <- as.Date(us_data$trending_date, format = "%y.%d.%m")
class(us_data$trending_date)

de_data$trending_date <- as.Date(de_data$trending_date, format = "%y.%d.%m")
class(de_data$trending_date)

kr_data$trending_date <- as.Date(kr_data$trending_date, format = "%y.%d.%m")
class(kr_data$trending_date)


us_data$publish_time <- ymd_hms(us_data$publish_time)
class(us_data$publish_time)

de_data$publish_time <- ymd_hms(de_data$publish_time)
class(de_data$publish_time)

kr_data$publish_time <- ymd_hms(kr_data$publish_time)
class(kr_data$publish_time)


categories <- fromJSON("./data/US_category_id.json")

category_lookup <- data.frame(
  category_id = categories$items$id,
  category_title = categories$items$snippet$title
)
# Categories are the same throughout the JSON files

View(category_lookup)
class(category_lookup$category_id)

category_lookup$category_id <- as.integer(category_lookup$category_id)
class(category_lookup$category_id)

us_data <- us_data %>%
  left_join(category_lookup, by = "category_id")

de_data <- de_data %>%
  left_join(category_lookup, by = "category_id")

kr_data <- kr_data %>%
  left_join(category_lookup, by = "category_id")


# Exploratory Data Analysis
# Single Variable Distributions
ggplot(us_data, aes(x = log10(views))) +
  geom_histogram(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Log10 Views Distribution in the US",
    x = "Log10(Views)",
    y = "Count"
  ) +
  theme_minimal()

# ggsave("log10_views_distribution_us.png")

ggplot(de_data, aes(x = log10(views))) +
  geom_histogram(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Log10 Views Distribution in Germany",
    x = "Log10(Views)Count",
    y = "Count"
  ) +
  theme_minimal()

# ggsave("log10_views_distribution_de.png")

ggplot(kr_data, aes(x = log10(views))) +
  geom_histogram(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Log10 Views Distribution in South Korea",
    x = "Log10(Views)Count",
    y = "Count"
  ) +
  theme_minimal()

# ggsave("log10_views_distribution_kr.png")

us_data %>%
  count(category_title) %>%
  ggplot(aes(x = reorder(category_title, -n), y = n)) +
  geom_col(fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Bar chart of Category Distribution in the US",
    x = "Category",
    y = "Count"
    )

# ggsave("cat_distribution_us.png")

de_data %>%
  count(category_title) %>%
  ggplot(aes(x = reorder(category_title, -n), y = n)) +
  geom_col(fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Bar chart of Category Distribution in Germany",
    x = "Category",
    y = "Count"
  )

# ggsave("cat_distribution_de.png")

kr_data %>%
  count(category_title) %>%
  ggplot(aes(x = reorder(category_title, -n), y = n)) +
  geom_col(fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Bar chart of Category Distribution in South Korea",
    x = "Category",
    y = "Count"
  )

# ggsave("cat_distribution_kr.png")

# Groups Comparison & Spread
ggplot(us_data, 
       aes(x = reorder(category_title, views, FUN = median), 
           y = log10(views))) + 
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Log10 Views Distribution by Category in the US",
    x = "Category",
    y = "Log10(Views)"
  ) +
  theme_minimal()

# ggsave("log10_views_by_cat_us.png")

ggplot(de_data, 
       aes(x = reorder(category_title, views, FUN = median), 
           y = log10(views))) + 
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Log10 Views Distribution by Category in Germany",
    x = "Category",
    y = "Log10(Views)"
  ) +
  theme_minimal()

# ggsave("log10_views_by_cat_de.png")

ggplot(kr_data, 
       aes(x = reorder(category_title, views, FUN = median), 
           y = log10(views))) + 
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Log10 Views Distribution by Category in South Korea",
    x = "Category",
    y = "Log10(Views)"
  ) +
  theme_minimal()

# ggsave("log10_views_by_cat_kr.png")


us_data %>%
  count(category_title, comments_disabled) %>%
  group_by(category_title) %>%
  mutate(
    percentage = n / sum(n)
  ) %>%
  ggplot(aes(
    x = reorder(category_title, percentage * (comments_disabled == TRUE)), 
    y = percentage,
    fill = comments_disabled
    )) +
  geom_col() +
  geom_text(
    aes(label = scales::percent(percentage, accuracy = 1)),
    position = position_stack(vjust = 0.5)
  ) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Percentage of Videos with Comments Disabled",
    x = "Category",
    y = "Percentage",
    fill = "Comments Disabled"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Statistical Analysis

# 1. Does publishing time accelerate a video's journey to the Trending page?
# Null hypothesis (H0): The day of the week or time of day a video is published 
# has no effect on the time it takes to trend. Alternative hypothesis (H1): 
# Videos published on specific peak days/times trend significantly faster.
# Statistical method: ANOVA testing

# us_data_clean <- us_data %>%
#  mutate(
#    publish_datetime = ymd_hms(publish_time),
#    publish_day = wday(publish_datetime, label = TRUE, abbr = TRUE),
#    publish_hour = hour(publish_datetime),
#    
#    trending_datetime = ymd(paste0("20", trending_date)),
#    
#    days_to_trend = as.numeric(
#      difftime(trending_datetime, publish_datetime, units = "days")
#      )
#  ) %>%
#  filter(!is.na(publish_datetime) & days_to_trend >= 0 & days_to_trend <= 30)

failed_rows <- us_data %>%
  filter(is.na(ymd_hms(publish_time))) %>%
  select(video_id, title, publish_time)

View(failed_rows)
# 34 corrupted rows should be removed

us_data_clean <- us_data %>%
  mutate(
    publish_datetime = as_datetime(publish_time),
    publish_day = wday(publish_datetime, label = TRUE, abbr = TRUE),
    publish_hour = hour(publish_datetime),
    
    trending_datetime = as.Date(trending_date, format = "%y.%d%.%m"),
    
    days_to_trend = as.numeric(
      difftime(trending_datetime, publish_datetime, units = "days")
    )
  ) %>%
  filter(!is.na(publish_datetime) & 
           !is.na(trending_datetime) & days_to_trend >= 0 & days_to_trend <= 30
  )

print(nrow(us_data) - nrow(us_data_clean))
# 485 rows have dropped for various issues. Firstly, there are 34 records with 
# the wrong format for publish_time. Secondly, YouTube records timestamps in UTC
# (publish_time), while trending_date is logged at a localized daily snapshot, 
# and so this time zone offset can cause a video to appear as if it trended a 
# few hours before recorded publish time, producing negative time lags.
# One more possible reason that some records would have got caught from the 
# filter is that videos that were published months or years prior that suddenly
# went viral should be considered outliers and so should not be in the research.

ggplot(us_data_clean, aes(x = days_to_trend)) +
  geom_density(fill = "steelblue") +
  labs(
    title = "Distribution of Days to Trend in the US",
    x = "Days to Trend",
    y = "Density"
  )
# The distribution is right skewed (positively skewed).

# ggsave("dist_days_trend_us.png")

anova_model_us <- aov(days_to_trend ~ publish_day, data = us_data_clean)

summary(anova_model_us)

leveneTest(days_to_trend ~ publish_day, data = us_data_clean)
# The p-value in the ANOVA test is less than 0.05 in publish_day, which means 
# that publish_day is significant, so accept the alternate hypothesis.
# The Levene test was also significant because the variances differed 
# significantly between groups, so the assumption of homogeneity of variance
# was not met.

welch_anova_us <- oneway.test(days_to_trend ~ publish_day, 
                           data = us_data_clean, 
                           var.equal = FALSE
                           )
print(welch_anova_us)
# The result shows statistical significance, which means that publishing day 
# does impact trending speed

games_howell_results_us <- us_data_clean %>%
  games_howell_test(days_to_trend ~ publish_day)
print(games_howell_results_us)


table_us <- games_howell_results_us %>%
  select(group1, group2, estimate, conf.low, conf.high, p.adj) %>%
  mutate(Significance = ifelse(p.adj < 0.05, "Yes", "No")) %>%
  gt() %>%
  tab_header(
    title = "Post-Hoc Pairwise Comparisons for the US",
    subtitle = "Dependent Variable: days_to_trend"
  ) %>%
  cols_label(
    group1 = "Group 1",
    group2 = "Group 2",
    estimate = "Estimate (Diff)",
    conf.low = "95% CI Low",
    conf.high = "95% CI High",
    p.adj = "p (adj)",
    Significance = "Significance"
  ) %>%
  fmt_number(
    columns = c(estimate, conf.low, conf.high, p.adj),
    decimals = 3
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", color = "darkred"),
    locations = cells_body(
      columns = Significance,
      rows = Significance == "Yes"
    )
  )

# gtsave(table_us, "pairwise_comparisons_table_us.png")


de_data_clean <- de_data %>%
  mutate(
    publish_datetime = as_datetime(publish_time),
    publish_day = wday(publish_datetime, label = TRUE, abbr = TRUE),
    publish_hour = hour(publish_datetime),
    
    trending_datetime = as.Date(trending_date, format = "%y.%d.%m"),
    
    days_to_trend = as.numeric(
      difftime(trending_datetime, publish_datetime, units = "days")
    )
  ) %>%
  filter(!is.na(publish_datetime) & !is.na(trending_datetime) & 
           days_to_trend >= 0 & days_to_trend <= 30)

ggplot(de_data_clean, aes(x = days_to_trend)) +
  geom_density(fill = "steelblue") +
  labs(
    title = "Distribution of Days to Trend in Germany",
    x = "Days to Trend",
    y = "Density"
  )

anova_model_de <- aov(days_to_trend ~ publish_day, data = de_data_clean)

summary(anova_model_de)

leveneTest(days_to_trend ~ publish_day, data = de_data_clean)
# For the Germany dataset, the results are the same, the results are 
# statistically significant

welch_anova_de <- oneway.test(days_to_trend ~ publish_day, 
                              data = de_data_clean, 
                              var.equal = FALSE
)
print(welch_anova_de)
# The result shows statistical significance, which means that publishing day 
# does impact trending speed as well

games_howell_results_de <- de_data_clean %>%
  games_howell_test(days_to_trend ~ publish_day)
print(games_howell_results_de)


table_de <- games_howell_results_de %>%
  select(group1, group2, estimate, conf.low, conf.high, p.adj) %>%
  mutate(Significance = ifelse(p.adj < 0.05, "Yes", "No")) %>%
  gt() %>%
  tab_header(
    title = "Post-Hoc Pairwise Comparisons for Germany",
    subtitle = "Dependent Variable: days_to_trend"
  ) %>%
  cols_label(
    group1 = "Group 1",
    group2 = "Group 2",
    estimate = "Estimate (Diff)",
    conf.low = "95% CI Low",
    conf.high = "95% CI High",
    p.adj = "p (adj)",
    Significance = "Significance"
  ) %>%
  fmt_number(
    columns = c(estimate, conf.low, conf.high, p.adj),
    decimals = 3
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", color = "darkred"),
    locations = cells_body(
      columns = Significance,
      rows = Significance == "Yes"
    )
  )

# gtsave(table_de, "pairwise_comparisons_table_de.png")


kr_data_clean <- kr_data %>%
  mutate(
    publish_datetime = as_datetime(publish_time),
    publish_day = wday(publish_datetime, label = TRUE, abbr = TRUE),
    publish_hour = hour(publish_datetime),
    
    trending_datetime = as.Date(trending_date, format = "%y.%d.%m"),
    
    days_to_trend = as.numeric(
      difftime(trending_datetime, publish_datetime, units = "days")
    )
  ) %>%
  filter(!is.na(publish_datetime) & !is.na(trending_datetime) & 
           days_to_trend >= 0 & days_to_trend <= 30)

ggplot(kr_data_clean, aes(x = days_to_trend)) +
  geom_density(fill = "steelblue") +
  labs(
    title = "Distribution of Days to Trend in South Korea",
    x = "Days to Trend",
    y = "Density"
  )

anova_model_kr <- aov(days_to_trend ~ publish_day, data = kr_data_clean)

summary(anova_model_kr)

leveneTest(days_to_trend ~ publish_day, data = kr_data_clean)
# The ANOVA test showed statistical significance, while the Levene test did not.
# This means that it is safe to use the Tukey post-hoc test.

tukey_results_kr <- TukeyHSD(anova_model_kr)
print(tukey_results_kr)

tukey_df_kr <- as.data.frame(tukey_results_kr$publish_day) %>%
  rownames_to_column(var = "Comparison") %>%
  mutate(
    diff = round(diff, 3),
    lwr = round(lwr, 3),
    upr = round(upr, 3),
    p_adj = ifelse(`p adj` < 0.001, "< 0.001", sprintf("%.4f", `p adj`)),
    Significant = ifelse(`p adj` < 0.05, "Yes", "No")
  ) %>%
  select(Comparison, diff, lwr, upr, p_adj, Significant)

grid.table(tukey_df_kr)

tukey_table_kr <- tukey_df_kr %>%
  gt() %>%
  tab_header(
    title = "Tukey HSD Post-Hoc Pairwise Comparisons for South Korea",
    subtitle = "Differences in mean time-to-trend (days) across publishing days"
  ) %>%
  cols_label(
    Comparison = "Day Comparison",
    diff = "Mean diff",
    lwr = "Lower CI",
    upr = "Upper CI",
    p_adj = "p-value (adj)"
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", color = "darkred"),
    locations = cells_body(
      columns = Significant,
      rows = Significant == "Yes"
    )
  )

# gtsave(tukey_table_kr, "tukey_table_kr.png")


# 2. Are certain videos categories significantly more reliant on audience 
# engagement than others?
# Hypothesis: Categories like News & Politics generate significantly higher 
# comment-to-view compared to passive entertainment like Music or Gaming.
# Statistical method: Welch's Two-Sample t-Test

# Engagement Ratio = (Likes + Comment counts) / Views

us_engagement <- us_data_clean %>%
  mutate(
    engagement_ratio = ifelse(views > 0, (likes + comment_count) / views, NA)
  ) %>%
  filter(!is.na(engagement_ratio) & is.finite(engagement_ratio))

us_engagement <- us_engagement %>%
  mutate(
    category_group = case_when(
      category_id %in% c("10", "24", "20") ~ "High Interaction",
      category_id %in% c("25", "26", "27") ~ "Informational",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(category_group))

# H0 hypothesis: There is no difference in mean audience engagement reliance 
# between category groups.
# H1 hypothesis: High interaction categories rely significantly on audience
# engagement than informational categories.

welch_ttest_result_us <- t.test(
  engagement_ratio ~ category_group,
  data = us_engagement,
  var.equal = FALSE
)

print(welch_ttest_result_us)

# d = 0.2 (Small), d = 0.5 (Medium), d = 0.8 (Large)
cohens_d(
  engagement_ratio ~ category_group, data = us_engagement, var.equal = FALSE
)
# The result here is 0.01, which means that there is little effect in terms of 
# audience engagement on categories, so accept null hypothesis. The p-value in 
# the Welch test also was greater than 0.05, so this further proves that 
# categories do not rely on audience engagement

ttest_table_us <- us_engagement %>%
  t_test(engagement_ratio ~ category_group, var.equal = FALSE) %>%
  add_significance() %>%
  mutate(Significance = ifelse(p < 0.05, "Yes", "No")) %>%
  gt() %>%
  tab_header(
    title = "Welch's Two-Sample t-test: Audience Engagement Reliance in the US",
    subtitle = "Comparing Engagement Ratio [(Likes + Comments) / Views] Across Category Types",
  ) %>%
  cols_label(
    .y. = "Item of Interest",
    group1 = "Group 1",
    group2 = "Group 2",
    statistic = "t-statistic",
    p = "p-value"
  ) %>%
  fmt_number(
    columns = c(statistic, p),
    decimals = 2
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", color = "darkred"),
    locations = cells_body(
      columns = Significance,
      rows = Significance == "Yes"
    )
  )

# gtsave(ttest_table_us, "welch_ttest_engagement_results_us.png")

de_engagement <- de_data_clean %>%
  mutate(
    engagement_ratio = ifelse(views > 0, (likes + comment_count) / views, NA)
  ) %>%
  filter(!is.na(engagement_ratio) & is.finite(engagement_ratio))

de_engagement <- de_engagement %>%
  mutate(
    category_group = case_when(
      category_id %in% c("10", "24", "20") ~ "High Interaction",
      category_id %in% c("25", "26", "27") ~ "Informational",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(category_group))

welch_ttest_results_de <- t.test(
  engagement_ratio ~ category_group,
  data = de_engagement,
  var.equal = FALSE
)

print(welch_ttest_results_de)

cohens_d(
  engagement_ratio ~ category_group, data = de_engagement, var.equal = FALSE
)
# The result here is much lower than 0.05 and the p-value is 0.6

ttest_table_de <- de_engagement %>%
  t_test(engagement_ratio ~ category_group, var.equal = FALSE) %>%
  add_significance() %>%
  mutate(Significance = ifelse(p < 0.05, "Yes", "No")) %>%
  gt() %>%
  tab_header(
    title = "Welch's Two-Sample t-test: Audience Engagement Reliance in Germany",
    subtitle = "Comparing Engagement Ratio [(Likes + Comments) / Views] Across Category Types",
  ) %>%
  cols_label(
    .y. = "Item of Interest",
    group1 = "Group 1",
    group2 = "Group 2",
    statistic = "t-statistic",
    p = "p-value"
  ) %>%
  fmt_number(
    columns = c(statistic, p),
    decimals = 2
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", color = "darkred"),
    locations = cells_body(
      columns = Significance,
      rows = Significance == "Yes"
    )
  )

# gtsave(ttest_table_de, "welch_ttest_engagement_results_de.png")


kr_engagement <- kr_data_clean %>%
  mutate(
    engagement_ratio = ifelse(views > 0, (likes + comment_count) / views, NA)
  ) %>%
  filter(!is.na(engagement_ratio) & is.finite(engagement_ratio))

kr_engagement <- kr_engagement %>%
  mutate(
    category_group = case_when(
      category_id %in% c("10", "24", "20") ~ "High Interaction",
      category_id %in% c("25", "26", "27") ~ "Informational",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(category_group))

welch_ttest_results_kr <- t.test(
  engagement_ratio ~ category_group,
  data = de_engagement,
  var.equal = FALSE
)

print(welch_ttest_results_kr)

cohens_d(
  engagement_ratio ~ category_group, data = kr_engagement, var.equal = FALSE
)
# The result here is 0.18 and the p-value is 0.6

ttest_table_kr <- kr_engagement %>%
  t_test(engagement_ratio ~ category_group, var.equal = FALSE) %>%
  add_significance() %>%
  mutate(Significance = ifelse(p < 0.05, "Yes", "No")) %>%
  gt() %>%
  tab_header(
    title = "Welch's Two-Sample t-test: Audience Engagement Reliance in South Korea",
    subtitle = "Comparing Engagement Ratio [(Likes + Comments) / Views] Across Category Types",
  ) %>%
  cols_label(
    .y. = "Item of Interest",
    group1 = "Group 1",
    group2 = "Group 2",
    statistic = "t-statistic",
    p = "p-value"
  ) %>%
  fmt_number(
    columns = c(statistic, p),
    decimals = 2
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", color = "darkred"),
    locations = cells_body(
      columns = Significance,
      rows = Significance == "Yes"
    )
  )

# gtsave(ttest_table_kr, "welch_ttest_engagement_results_kr.png")


# 3. Do 'Clickbait' title elements (All-Caps, Exclamation marks) correlate with
# higher view-to-like conversion?
# Hypothesis: Titles containing high uppercase ratios or extreme sentiment 
# polarity experience higher initia views but signigicantly lower like-to-view 
# ratios.
# Statistical method: Pearson's Rank Correlation Coefficient

us_clickbait <- us_data_clean %>%
  filter(views > 0) %>%
  mutate(
    like_conversion = likes / views,
    title_clean = str_replace_all(title, "[^a-zA-Z]", ""),
    caps_ratio = ifelse(
      nchar(title_clean) > 0,
      str_count(title_clean, "[A-Z]") / nchar(title_clean),
      0
    ),
    exclamation_count = str_count(title, "!"),
    is_high_caps = as.numeric(caps_ratio > 0.5),
    has_exclamation = as.numeric(exclamation_count > 0)
  ) %>%
  filter(
    !is.na(like_conversion) & !is.numeric(like_conversion) == FALSE &
    !is.na(caps_ratio) & is.finite(like_conversion)
  )

# Pearson Correlation (Linear)
cor_caps_pearson_us <- cor.test(
  us_clickbait$caps_ratio, 
  us_clickbait$like_conversion, 
  method = "pearson"
)

cor_excl_pearson_us <- cor.test(
  us_clickbait$exclamation_count, 
  us_clickbait$like_conversion,
  method = "pearson"
)

print(cor_caps_pearson_us)
print(cor_excl_pearson_us)

# Spearman Rank Correlation (Monotonic / Non)
cor_caps_spearman_us <- cor.test(
  us_clickbait$caps_ratio,
  us_clickbait$like_conversion,
  method = "spearman",
  exact = FALSE
)

cor_excl_spearman_us <- cor.test(
  us_clickbait$exclamation_count,
  us_clickbait$like_conversion,
  method = "spearman",
  exact = FALSE
)

print(cor_caps_spearman_us)
print(cor_excl_spearman_us)

cor_summary_us <- tibble(
  `Clickbait Feature` = c("ALL-CAPS Ratio", "Exclamation Mark Count"),
  `Pearson r` = c(cor_caps_pearson_us$estimate, cor_excl_pearson_us$estimate),
  `Pearson p-value` = c(cor_caps_pearson_us$p.value, cor_excl_pearson_us$p.value),
  `Spearman rho` = c(cor_caps_spearman_us$estimate, cor_excl_spearman_us$estimate),
  `Spearman p-value` = c(cor_caps_spearman_us$p.value, cor_excl_spearman_us$p.value)
)

table_cor_us <- cor_summary_us %>%
  gt() %>%
  tab_header(
    title = "Correlation: Clickbait Title Elements vs Like Conversion",
    subtitle = "Target Variable: Likes / Views Ratio"
  ) %>%
  fmt_number(
    columns = c(`Pearson r`, `Pearson p-value`, `Spearman rho`, `Spearman p-value`),
    decimals = 4
  ) %>%
  cols_align(align = "center")

# gtsave(table_cor_us, "clickbait_correlation_table_us.png")

ggplot(us_clickbait, aes(x = caps_ratio, y = like_conversion)) +
  geom_point(color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(
    title = "ALL-CAPS Ratio vs View-to-Like Conversion Rate",
    x = "Proportion of ALL-CAPS in Title",
    y = "Like Conversion Rate (Likes / Views)"
  ) +
  theme_minimal()

# The results show the p-value of both Pearson and Spearman to be 0, which is 
# normal because of the large dataset, and it also confirms that the observed 
# columns are not random noise.
# The ALL-CAPS ratio r value in both methods (r = 0.21, r = 0.17) indicate a 
# weak to moderate positive relationships. However, for exclamation marks, the 
# r values are less than 0.1, indicating a very weak positive relationship.


de_clickbait <- de_data_clean %>%
  filter(views > 0) %>%
  mutate(
    like_conversion = likes / views,
    title_clean = str_replace_all(title, "[^a-zA-Z]", ""),
    caps_ratio = ifelse(
      nchar(title_clean) > 0,
      str_count(title_clean, "[A-Z]") / nchar(title_clean),
      0
    ),
    exclamation_count = str_count(title, "!"),
    is_high_caps = as.numeric(caps_ratio > 0.5),
    has_exclamation = as.numeric(exclamation_count > 0)
  ) %>%
  filter(
    !is.na(like_conversion) & !is.numeric(like_conversion) == FALSE &
      !is.na(caps_ratio) & is.finite(like_conversion)
  )

# Pearson Correlation (Linear)
cor_caps_pearson_de <- cor.test(
  de_clickbait$caps_ratio, 
  de_clickbait$like_conversion, 
  method = "pearson"
)

cor_excl_pearson_de <- cor.test(
  de_clickbait$exclamation_count, 
  de_clickbait$like_conversion,
  method = "pearson"
)

print(cor_caps_pearson_de)
print(cor_excl_pearson_de)

# Spearman Rank Correlation (Monotonic / Non)
cor_caps_spearman_de <- cor.test(
  de_clickbait$caps_ratio,
  de_clickbait$like_conversion,
  method = "spearman",
  exact = FALSE
)

cor_excl_spearman_de <- cor.test(
  de_clickbait$exclamation_count,
  de_clickbait$like_conversion,
  method = "spearman",
  exact = FALSE
)

print(cor_caps_spearman_de)
print(cor_excl_spearman_de)

cor_summary_de <- tibble(
  `Clickbait Feature` = c("ALL-CAPS Ratio", "Exclamation Mark Count"),
  `Pearson r` = c(cor_caps_pearson_de$estimate, cor_excl_pearson_de$estimate),
  `Pearson p-value` = c(cor_caps_pearson_de$p.value, cor_excl_pearson_de$p.value),
  `Spearman rho` = c(cor_caps_spearman_de$estimate, cor_excl_spearman_de$estimate),
  `Spearman p-value` = c(cor_caps_spearman_de$p.value, cor_excl_spearman_de$p.value)
)

table_cor_de <- cor_summary_de %>%
  gt() %>%
  tab_header(
    title = "Correlation: Clickbait Title Elements vs Like Conversion",
    subtitle = "Target Variable: Likes / Views Ratio"
  ) %>%
  fmt_number(
    columns = c(`Pearson r`, `Pearson p-value`, `Spearman rho`, `Spearman p-value`),
    decimals = 4
  ) %>%
  cols_align(align = "center")

# gtsave(table_cor_de, "clickbait_correlation_table_de.png")


kr_clickbait <- kr_data_clean %>%
  filter(views > 0) %>%
  mutate(
    like_conversion = likes / views,
    title_clean = str_replace_all(title, "[^a-zA-Z]", ""),
    caps_ratio = ifelse(
      nchar(title_clean) > 0,
      str_count(title_clean, "[A-Z]") / nchar(title_clean),
      0
    ),
    exclamation_count = str_count(title, "!"),
    is_high_caps = as.numeric(caps_ratio > 0.5),
    has_exclamation = as.numeric(exclamation_count > 0)
  ) %>%
  filter(
    !is.na(like_conversion) & !is.numeric(like_conversion) == FALSE &
      !is.na(caps_ratio) & is.finite(like_conversion)
  )

# Pearson Correlation (Linear)
cor_caps_pearson_kr <- cor.test(
  kr_clickbait$caps_ratio, 
  kr_clickbait$like_conversion, 
  method = "pearson"
)

cor_excl_pearson_kr <- cor.test(
  kr_clickbait$exclamation_count, 
  kr_clickbait$like_conversion,
  method = "pearson"
)

print(cor_caps_pearson_kr)
print(cor_excl_pearson_kr)

# Spearman Rank Correlation (Monotonic / Non)
cor_caps_spearman_kr <- cor.test(
  kr_clickbait$caps_ratio,
  kr_clickbait$like_conversion,
  method = "spearman",
  exact = FALSE
)

cor_excl_spearman_kr <- cor.test(
  kr_clickbait$exclamation_count,
  kr_clickbait$like_conversion,
  method = "spearman",
  exact = FALSE
)

print(cor_caps_spearman_kr)
print(cor_excl_spearman_kr)

cor_summary_kr <- tibble(
  `Clickbait Feature` = c("ALL-CAPS Ratio", "Exclamation Mark Count"),
  `Pearson r` = c(cor_caps_pearson_kr$estimate, cor_excl_pearson_kr$estimate),
  `Pearson p-value` = c(cor_caps_pearson_kr$p.value, cor_excl_pearson_kr$p.value),
  `Spearman rho` = c(cor_caps_spearman_kr$estimate, cor_excl_spearman_kr$estimate),
  `Spearman p-value` = c(cor_caps_spearman_kr$p.value, cor_excl_spearman_kr$p.value)
)

table_cor_kr <- cor_summary_kr %>%
  gt() %>%
  tab_header(
    title = "Correlation: Clickbait Title Elements vs Like Conversion",
    subtitle = "Target Variable: Likes / Views Ratio"
  ) %>%
  fmt_number(
    columns = c(`Pearson r`, `Pearson p-value`, `Spearman rho`, `Spearman p-value`),
    decimals = 4
  ) %>%
  cols_align(align = "center")

# gtsave(table_cor_kr, "clickbait_correlation_table_kr.png")


# 4. Is comment disabling random or strongly associated with specific categories
# and negative comments?
# Hypothesis: Disabling comments is non-randomly distributed and heavily 
# concentrated in sensitive content categories.
# Statistical method: Chi-Square Test of Independence

us_comments <- us_data_clean %>%
  filter(!is.na(comments_disabled), views > 0) %>%
  mutate(
    dislike_ratio = dislikes / views,
    high_dislike = ifelse(
      dislike_ratio > quantile(dislike_ratio, 0.75, na.rm = TRUE),
      "High dislike",
      "Normal Dislike"
    ),
    comments_disabled_label = ifelse(comments_disabled, "Disabled", "Enabled")
  )

# Category vs Comment Disabling
cat_table_us <- table(us_comments$category_id, us_comments$comments_disabled_label)

chi_cat_us <- chisq.test(cat_table_us)
print(chi_cat_us)

cramers_v_cat_us <- cramer_v(cat_table_us)
print(cramers_v_cat_us)
# The Cramer's result is 0.14, which indicates that the relationship between the
# variables is almost independent, even though the p-value achieved in the 
# Chi-Square test is less than 0.05

# Dislike level vs Comment disabling
dislike_table_us <- table(us_comments$high_dislike, us_comments$ comments_disabled_label)

chi_dislike_us <- chisq.test(dislike_table_us)
print(chi_dislike_us)

cramers_v_dislike_us <- cramer_v(dislike_table_us)
print(cramers_v_dislike_us)
# The Cramer's result is 0.016 with degrees of freedom of 1, which indicates a 
# non-existent association between the two categorical variables despite the 
# p-value of Chi-Square being less than 0.05.
# Overall, the result is that the relationship between the categories, dislikes,
# and comment disabling is real, but in practice, the strength of the 
# relationships are negligible.

chi_summary_us <- tibble(
  Hypothesis = c(
    "Category vs Comment Disabling",
    "High Dislike Ratio vs Comment Disabling"
  ),
  `Chi-Square (X2)` = c(chi_cat_us$statistic, chi_dislike_us$statistic),
  df = c(chi_cat_us$parameter, chi_dislike_us$parameter),
  `p-value` = c(chi_cat_us$p.value, chi_dislike_us$p.value),
  `Cramer's V` = c(cramers_v_cat_us, cramers_v_dislike_us)
)

table_chi_us <- chi_summary_us %>%
  gt() %>%
  tab_header(
    title = "Chi-Square Tests of Independence: Comment Disabling Drivers",
    subtitle = "Evaluating Association with Video Category and Dislike Rates"
  ) %>%
  fmt_number(
    columns = c(`Chi-Square (X2)`, `Cramer's V`),
    decimals = 3
  ) %>%
  fmt_number(
    columns = `p-value`,
    decimals = 4
  )

# gtsave(table_chi_us, "chisq_comment_disabling_results_us.png")


de_comments <- de_data_clean %>%
  filter(!is.na(comments_disabled), views > 0) %>%
  mutate(
    dislike_ratio = dislikes / views,
    high_dislike = ifelse(
      dislike_ratio > quantile(dislike_ratio, 0.75, na.rm = TRUE),
      "High dislike",
      "Normal Dislike"
    ),
    comments_disabled_label = ifelse(comments_disabled, "Disabled", "Enabled")
  )

# Category vs Comment Disabling
cat_table_de <- table(de_comments$category_id, de_comments$comments_disabled_label)

chi_cat_de <- chisq.test(cat_table_de)
print(chi_cat_de)

cramers_v_cat_de <- cramer_v(cat_table_de)
print(cramers_v_cat_de)

# Dislike level vs Comment disabling
dislike_table_de <- table(de_comments$high_dislike, de_comments$ comments_disabled_label)

chi_dislike_de <- chisq.test(dislike_table_de)
print(chi_dislike_de)

cramers_v_dislike_de <- cramer_v(dislike_table_de)
print(cramers_v_dislike_de)

chi_summary_de <- tibble(
  Hypothesis = c(
    "Category vs Comment Disabling",
    "High Dislike Ratio vs Comment Disabling"
  ),
  `Chi-Square (X2)` = c(chi_cat_de$statistic, chi_dislike_de$statistic),
  df = c(chi_cat_de$parameter, chi_dislike_de$parameter),
  `p-value` = c(chi_cat_de$p.value, chi_dislike_de$p.value),
  `Cramer's V` = c(cramers_v_cat_de, cramers_v_dislike_de)
)

table_chi_de <- chi_summary_de %>%
  gt() %>%
  tab_header(
    title = "Chi-Square Tests of Independence: Comment Disabling Drivers",
    subtitle = "Evaluating Association with Video Category and Dislike Rates"
  ) %>%
  fmt_number(
    columns = c(`Chi-Square (X2)`, `Cramer's V`),
    decimals = 3
  ) %>%
  fmt_number(
    columns = `p-value`,
    decimals = 4
  )

gtsave(table_chi_de, "chisq_comment_disabling_results_de.png")


kr_comments <- kr_data_clean %>%
  filter(!is.na(comments_disabled), views > 0) %>%
  mutate(
    dislike_ratio = dislikes / views,
    high_dislike = ifelse(
      dislike_ratio > quantile(dislike_ratio, 0.75, na.rm = TRUE),
      "High dislike",
      "Normal Dislike"
    ),
    comments_disabled_label = ifelse(comments_disabled, "Disabled", "Enabled")
  )

# Category vs Comment Disabling
cat_table_kr <- table(kr_comments$category_id, kr_comments$comments_disabled_label)

chi_cat_kr <- chisq.test(cat_table_kr)
print(chi_cat_kr)

cramers_v_cat_kr <- cramer_v(cat_table_kr)
print(cramers_v_cat_kr)

# Dislike level vs Comment disabling
dislike_table_kr <- table(kr_comments$high_dislike, kr_comments$ comments_disabled_label)

chi_dislike_kr <- chisq.test(dislike_table_kr)
print(chi_dislike_kr)

cramers_v_dislike_kr <- cramer_v(dislike_table_kr)
print(cramers_v_dislike_kr)

chi_summary_kr <- tibble(
  Hypothesis = c(
    "Category vs Comment Disabling",
    "High Dislike Ratio vs Comment Disabling"
  ),
  `Chi-Square (X2)` = c(chi_cat_kr$statistic, chi_dislike_kr$statistic),
  df = c(chi_cat_kr$parameter, chi_dislike_kr$parameter),
  `p-value` = c(chi_cat_kr$p.value, chi_dislike_kr$p.value),
  `Cramer's V` = c(cramers_v_cat_kr, cramers_v_dislike_kr)
)

table_chi_kr <- chi_summary_kr %>%
  gt() %>%
  tab_header(
    title = "Chi-Square Tests of Independence: Comment Disabling Drivers",
    subtitle = "Evaluating Association with Video Category and Dislike Rates"
  ) %>%
  fmt_number(
    columns = c(`Chi-Square (X2)`, `Cramer's V`),
    decimals = 3
  ) %>%
  fmt_number(
    columns = `p-value`,
    decimals = 4
  )

# gtsave(table_chi_kr, "chisq_comment_disabling_results_kr.png")
