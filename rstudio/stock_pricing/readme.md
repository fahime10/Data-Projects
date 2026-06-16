# Stock Pricing Analysis
This project provides a quantitative analysis of four major economic sectors using 25 years of historical market data. By analyzing Tech (XLK), Energy (XLE), Healthcare (XLV), and Finance (XLF), the study identifies how different industries respond to systemic shocks and determines an optimal portfolio based on risk-adjusted returns

## Dataset
Data was sourced from quantmod package in R

## Tools
R language (quantmod, ggplot2)  
Power BI

## Key findings
* While Tech and Energy offer high growth, Healthcare acts as a defensive anchor, offering better risk-adjusted returns
* The Energy sector is the high-risk high-reward sector
* A data-driven Monte Carlo simulation reveals that maximizing the Sharpe ratio requires to focus more on defensive sectors, such as Healthcare, to offset the noise of high-volatility sectors
* The low correlation coefficient between Energy and Tech suggests that a combined holding reduces portfolio drawdowns during sector-specific crashes

## Visual Analysis
### Long-term Sector Growth
![Growth of £1 investment](plots/sector_comparison.png)
*This chart illustrates the cumulative performance of £1 from 2000-2025, highlighting he resilience of Healthcare and Tech.*  

### Reward vs Risk
![Returns against Volatility](plots/returns_volatility.png)
*The scatterplot confirms Energy as the high-volatility outlier*  

### Optimal Portfolio
![Optimal Portfolio](plots/optimal_portfolio.png)
*A display of the optimal portfolio based on the risk-adjusted return calculation*  

## Project structure
dashboard/ - contains the dashboard  
data/ – contains three datasets for the dashboard  
docs/ - contains an index.html file to view the final report  
report/ – contains an Rmd file and an html file for the report  
script/ - contains the main script for the research being done  

### Author
Fahim Ahmed