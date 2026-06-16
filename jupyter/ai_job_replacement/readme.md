# AI Workforce Replacement & Employee Attrition Analysis
This project showcases data analytical skills.

This project explores how AI adoption impacts employee productivity, burnout, job security perceptions, and reskilling needs.

The analysis is beased on two datasets, both extracted from Kaggle:
* AI Worker Burnout & Attrition Risk (1,500 records)
* AI Job Replacement & Skill Shift (15,000 records)

The goal is to understand how AI is shaping the modern workforce and identify patterns that organizations can use to balance productivity with employee wellbeing.

## Key questions
* How does AI usage level relate to productivity?
* Does increased AI adoption increase employee burnout?
* Which roles fear they are most at risk?
* Do employees with higher automation risk also have a higher reskilling urgency?
* Can reskilling mitigate employee attrition and fear of replacement?

## Dataset
Dataset source: Kaggle  
https://www.kaggle.com/datasets/nudratabbas/ai-worker-burnout-and-attrition-risk-dataset  
The dataset contains 1,500 rows.  

Dataset source: Kaggle  
https://www.kaggle.com/datasets/dmahajanbe23/ai-job-replacement-and-skill-shift-dataset
The dataset contains 15,000 rows.

## Tools
Python (pandas, seaborn, matplotlib, scikit-learn, stattistical testing with ANOVA and Tukey tests)

## Project workflow
1. Data cleaning and preprocessing using pandas
2. Exploratory Data Analysis using visualizations
3. Statistical analysis using ANOVA and Tukey tests
4. Clusteting (PCA + grouping) to identify optimal AI usage patterns
5. Interpretation of results and report writing

## Key findings
* Dual effect in AI usage: increased number of AI tools is associated with higher productivity, and prolonged daily interaction with AI systems contributes to increased burnout
* Moderate AI usage may help maintain productivity without substantially increasing burnout
* Different industries face the same level of challenge when it comes to fear of AI replacing their roles
* Industries should focus on reskilling employees to adapt to use AI in their work routines to offset the fear of replacement

## Project structure
data/ – contains both datasets  
notebooks/ – contains 3 Python notebooks  
report/ – contains the report

## Limitations
Both datasets are synthetic and may not fully reflect real-world behaviour. However, the records were created to give a realistic scenario of the current time .

### Author
Fahim Ahmed

### Field and tools
Data Analytics; Python