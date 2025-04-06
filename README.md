# OVERVIEW:
This project focuses on evaluating the performance of MoMo’s top-up feature, which enables users to recharge prepaid mobile accounts via e-Wallet, Internet banking, SMS, or linked bank accounts. The service supports major telecom operators such as Mobifone, Viettel, VinaPhone, Vietnamobile, and Viettel.
The objective of this analysis is to identify trends, patterns, and relationships among the variables in the dataset, offering insightful recommendations for the business. By understanding this data, MoMo can optimize its operations and improve the user experience by providing more tailored services.

### Data Sources:

- Daily transaction records from January to December 2020 (Transactions table)
- User demographic data (User_info table)
- Commission rates from Telco partners (Commission table)

### Key Steps:

- Process and standardize raw data using SQL Server to ensure data consistency and readiness for analysis.
- Perform business analysis to identify key performance insights, including the most profitable month, day-of-week revenue patterns, customer acquisition trends, and detailed breakdowns by age, gender, and location.
- Apply RFM (Recency, Frequency, Monetary) segmentation in SQL Server to categorize users into strategic groups, enabling targeted marketing efforts to boost revenue.
- Visualize business performance by importing processed data into Power BI to develop an interactive, real-time dashboard for monitoring key metrics.

# DATA CLEANING:

- Create a staging table where I can work on and clean the data. This allows me to keep the raw data intact as a backup in case anything goes wrong.
- TRANSACTIONS_DUP
- Standardize missing data in Purchase_status column.
- Change the date format.
- The Amount column appears to be sorted in string order instead of numerical order, format Amount values and change into the data type into INT.
- USER_INF_DUP
- Delete duplicates in order_id column.
- Checking the logic of first_tran_date column and correct it. Change data type of first_tran_date column.
- Ensure the accuracy and consistency of data, specifically for the location and gender columns in the user table.

# THE ANALYSIS:
### Observations and insights:
**Questions**

- Total revenue in Jan 2020: 1,409,827VND
- Most profitable month: September (1,690,900VND)
- Least profitable month: February (1,378,500VND)
- Day of the week (make the most money): Wednesday
- Day of the week (make the least money): Monday

**User demographic**
Age group analysis: which age groups make generate the most revenue?
Individuals aged 23 to 32 account for the largest share of both transaction volumn and value.
Gender distribution:
Men use the service more frequently and spend more money than female customers.
This suggests that more marketing efforts should be directed toward attracting female customers to improve revenue from this segment.
Geography analysis:
Ho Chi Minh city makes the highest average and total revenue.
 Revenue by Merchant: 
Viettel leads in average monthly revenue (596,033 VND), followed by Mobifone and Vinaphone. Gmobile has the lowest revenue.
# RFM SEGMENTATION:
The RFM model relies on three key quantitative factors:

- Recency: The time since the customer’s last purchase.
- Frequency: How frequently the customer makes a purchase.
- Monetary value: The total amount the customer spends on purchases.

RFM_group: This is the customer group classified based on the average score of the Recency, Frequency, and Monetary factors. The scores range from 1 to 5, with groups having higher average scores representing customers with higher value and greater potential for the company.

- Groups with high RFM_group values: These are customers who make frequent purchases, spend a lot, and have made recent transactions with the company. This group is important, with high value and strong growth potential.
- Groups with low RFM_group values: These are customers who make fewer transactions, purchase less frequently, and spend little. This group may require additional strategies for re-engagement and nurturing to encourage them to return.

### Strategies for enhancing the experience of each group of users
To enhance the experience of each customer group based on the RFM model, you can implement tailored strategies that focus on the specific needs and behaviors of each segment. Here's a breakdown of strategies for each group:
**1. High RFM Group (Valuable, Engaged Customers)**

- These are your most valuable and engaged customers, who make frequent purchases, spend significantly, and have made recent transactions.
-  to their preferences and buying habits.
- VIP or Loyalty Programs: Develop a VIP program that offers early access to new Personalized Offers: Provide exclusive promotions, discounts, or loyalty rewards tailoredproducts, special events, or higher-tier rewards.
- Customer Success: Assign dedicated account managers or customer success teams to offer personalized assistance and build strong relationships.
- Referral Programs: Encourage them to refer others by offering incentives for successful referrals, capitalizing on their loyalty and engagement.

**2. Medium RFM Group (Occasional but Potentially Valuable Customers)**

- These customers make purchases less frequently or have medium spending but are still valuable to your business.
- Engagement Campaigns: Send personalized emails or notifications about new products, services, or updates that might interest them.
- Targeted Retargeting: Use retargeting ads to remind them about products they've shown interest in or previously purchased.
- Incentivize Frequency: Offer discounts for repeat purchases or encourage them to shop more frequently through time-sensitive offers or limited-time promotions.
- Exclusive Content: Provide them with exclusive content, such as sneak peeks, product demos, or webinars, to maintain interest.

**3. Low RFM Group (Inactive or Low-Value Customers)**

- These customers make infrequent purchases, spend little, and have not interacted with the business recently.
- Re-engagement Campaigns: Implement email or SMS campaigns to re-engage these customers, offering them special discounts or reminding them of their past interest.
- Win-Back Offers: Provide attractive offers like “We Miss You” discounts to encourage them to return and make a purchase.
- Feedback Requests: Ask for feedback on why they haven’t interacted recently, and use this data to improve products, services, or marketing efforts.
- Educational Content: Educate them about the value of your product or service through content like how-to guides, testimonials, or case studies to reignite interest.



## THE END.

