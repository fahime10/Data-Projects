# Project:
# Predictive Inventory Management: Linking Demand Forecasting to 
# Optimal Stocking Strategies

install.packages("tidyverse")
install.packages("fable")

library(tidyverse)
library(ggplot2)
library(fable)
library(feasts)
library(tsibble)

data <- read.csv("./data/car_data.csv")

View(data)
str(data)
glimpse(data)

# Data cleaning

colSums(is.na(data))
# No nulls found

sum(duplicated(data))
# No duplicates found

data <- data %>%
  select(-Phone)
# Phone number is not useful for this project

data <- data %>%
  mutate(Date = mdy(Date))

data <- data %>%
  rename(Price = Price....)

# Exploratory Data Analysis
# Date
dim(data)

min(data$Date)
max(data$Date)
max(data$Date) - min(data$Date)
# The data covers 728 days, which is alright for forecasting

# SKUs
n_distinct(data$Company)
# 30 different companies

n_distinct(data$Model)
# 154 unique car models

data %>%
  count(Body.Style, sort = TRUE)

data %>%
  count(Transmission, sort = TRUE)

# Time Series
monthly_sales <- data %>%
  mutate(Month_Year = floor_date(Date, "month")) %>%
  group_by(Month_Year) %>%
  summarise(Total_Units_Sold = n())

ggplot(monthly_sales, aes(x = Month_Year, y = Total_Units_Sold)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "darkblue", size = 2) +
  scale_x_date(
    date_breaks = "2 month",
    date_labels = "%b %Y"
  ) +
  labs(
    title = "Monthly Car Demand",
    x = "Timeline",
    y = "Units sold"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 1),
    plot.margin = margin(t = 10, r = 50, b = 10, l = 10)
  )

# Best selling car body style
ggplot(data, aes(x = reorder(Body.Style, Body.Style, function(x)-length(x)))) +
  geom_bar(fill = "coral", color = "black") +
  labs(
    title = "Total Sales Volume by Vehicle Body Style",
    x = "Body Style",
    y = "Units sold"
  ) +
  theme_minimal()

# Pie chart for cars sold by region
regional_pct <- data %>%
  count(Dealer_Region) %>%
  mutate(
    Percentage = n / sum(n),
    label_pos = cumsum(Percentage) - (Percentage / 2),
    Label = paste0(round(Percentage * 100, 1), "%")
  )

ggplot(regional_pct, aes(x = "", y = Percentage, fill = Dealer_Region)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(
    aes(label = Label), 
    position = position_stack(vjust = 0.5), 
    color = "white", 
    size = 3
  ) +
  labs(
    title = "Cars sold by region",
    x = "",
    y = "",
    fill = "Region"
  ) +
  theme_minimal() + 
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

# Demand Decomposition
monthly_ts <- monthly_sales %>%
  mutate(Month_Year = yearmonth(Month_Year)) %>%
  as_tsibble(index = Month_Year)

monthly_ts %>%
  model(classical_decomposition(Total_Units_Sold ~ season(12), type = "additive")) %>%
  components() %>%
  autoplot() +
  labs(title = "Classical Decomposition of Car Demand")
  theme_minimal()
# The purpose of the time series decomposition is to take a messy, complicated
# line of data and strip it down into its core individual components.
# It is much like a prism splitting white lights into individual colours, in 
# this case, Trend, Seasonality, and Random Noise.
# To break it down:
# 1) The raw historical data of total units sold is very bumpy and so it is hard
# to use for long-term planning on its own because too many things are happening
# at once;
# 2) The trend (long-term growth) strips away the holidays and monthly bounces 
# to show the direction of the business, in this case, from around 900 units in 
# mid-2022 to 1,100 by mid-2023. This tells us that the business is indeed 
# expanding, but they will need more logistics and larger fleet allocations in 
# the coming year;
# 3) The seasonal pattern shows spikes in October-December (above the baseline 
# of 400 units), but then crashes every January/February. This means the 
# business should anticipate by buying massive amounts of stock, but around 
# December, they should slow down because there will not be as many customers;
# 4) The random (trend minus seasonality) line represents the risk, in this case
# it is flat, which means that the data is highly deterministic. This means that
# sales are almost entirely driven by trend (predictable growth) and calendar 
# cycles (seasonality). Future demand forecasting models should be very accurate
# if this is the case
  
# ABC Analysis
sku_analysis <- data %>%
  group_by(Body.Style) %>%
  summarise(
    Units_Sold = n(),
    Total_Revenue = sum(Price, na.rm = TRUE)
  ) %>%
  mutate(Rev_Share = Total_Revenue / sum(Total_Revenue) * 100) %>%
  arrange(desc(Rev_Share))

View(sku_analysis)

sku_abc <- sku_analysis %>%
  arrange(desc(Total_Revenue)) %>%
  mutate(
    Cum_Revenue = cumsum(Total_Revenue),
    Cum_Rev_Pct = Cum_Revenue / sum(Total_Revenue) * 100
  ) %>%
  mutate(
    ABC_Class = case_when(
      Cum_Rev_Pct <= 75 ~ "A",
      Cum_Rev_Pct <= 95 ~ "B",
      TRUE ~"C"
    )
  )

View(sku_abc)
# Class A includes SUV, Hatchback, and Sedan, and these need to be under great 
# control because they contribute to at least 75% of the revenue;
# Class B includes Passenger, and contributes 17% of the revenue, so inventory 
# checks for this type of car is less frequent;
# Class C includes Hardtop, and contributes to 13% of the revenue, so the business 
# can count on these semi-annually, meaning it would be best not to over-order 
# these

# Geographic Demand Analysis
regional_sales <- data %>%
  mutate(Month_Year = floor_date(Date, "month")) %>%
  group_by(Month_Year, Dealer_Region) %>%
  summarise(Units_Sold = n(), .groups = 'drop')

ggplot(regional_sales, aes(
  x = Month_Year, 
  y = Units_Sold, 
  color = Dealer_Region
  )
  ) +
  geom_line(size = 1) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %y") +
  labs(
    title = "Regional Demand",
    x = "Timeline",
    y = "Units Sold",
    color = "Region"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90))
# All regions experience almost identical peaks and troughs. 

# Predictive modeling
fit <- monthly_ts %>%
  model(
    Exponential_Smoothing = ETS(Total_Units_Sold),
    Arima_Model = ARIMA(Total_Units_Sold)
  )

forecast_6m <- fit %>%
  forecast(h = "6 months")

forecast_6m %>%
  autoplot(monthly_ts, level = 95) +
  labs(
    title = "6-Month Car Demand Forecast (2024)",
    subtitle = "Comparing ETS and ARIMA performance on seasonal demand",
    x = "Timeline",
    y = "Units Forecasted"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90))
# The ARIMA model struggled with the shorter time horizon, and so the ETS model 
# performed better. The ETS model suggests that total monthly demand will rise 
# above 2,000 units by mid-2024, which means that the supply chain must increase
# inventory to keep up with this demand.