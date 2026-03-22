🛒 Blinkit Business Intelligence — SQL Analysis

End-to-end SQL analysis of Blinkit's operations using a dataset of 25,000 customers and 50,000 orders.
This project uncovers actionable business insights across customers, sales, delivery, marketing, inventory, and feedback.


📌 Project Overview
Blinkit (formerly Grofers) is one of India's leading quick-commerce grocery delivery platforms.
This project performs a complete Business Intelligence analysis using SQL on Blinkit's database — covering everything from customer behavior to marketing ROI.

🗃️ Database Schema
TableDescriptioncustomers25K customer profiles with segments, area, pincodeorders50K orders with payment method, date, store infoorder_itemProduct-level order details with quantity & priceproductsProduct catalog with brand, price, MRP, margincategoryProduct categoriesdeliveryDelivery partner, time, distance, delay reasonsmarketingCampaign performance — spend, ROAS, conversionsinventoryStock received, damaged stock, stock levelscustomer_feedbacksRatings, sentiment, feedback categoryratingRating scale reference

📊 Analysis Breakdown — 7 Parts | 61 Queries
Part 1 — Customer Analysis 👥

Customer segment distribution (VIP, Regular, New)
Top areas & pincodes by customer count
Monthly new customer registration trend
Returning vs New customers
Customer Lifetime Value (CLV)
Most loyal customers

Part 2 — Sales & Revenue Analysis 💰

Total revenue & monthly revenue trends
Average Order Value (AOV)
Peak ordering hours & days
Top 10 best-selling products
Revenue by category
Payment method breakdown
MRP vs Selling Price (discount insights)

Part 3 — Delivery Performance Analysis 🚴

On-time vs Delayed delivery rate
Average delivery time by area
Top reasons for delays
Distance vs Delivery time correlation
Best & worst performing delivery partners
Impact of delivery delay on customer ratings

Part 4 — Marketing & Campaign Analysis 📢

Best performing marketing channels (ROAS)
Campaign conversion funnel analysis
Target audience performance
Monthly marketing spend vs revenue
Full campaign impact on orders

Part 5 — Inventory Analysis 📦

Low stock & overstock products
Damaged stock % by category
Fast-moving vs slow-moving products
Products near shelf-life expiry
Monthly stock received trend

Part 6 — Customer Feedback & Sentiment Analysis ⭐

Overall average rating
Sentiment distribution (Positive / Neutral / Negative)
Average rating by category
Worst rated products
Monthly sentiment trend
Delayed delivery impact on ratings

Part 7 — Combined Mega Insights 🏆

Full Business Summary Dashboard (single query)
High-value customers with delivery & rating analysis
Marketing → Order → Delivery → Feedback full funnel
Customer churn risk analysis (90+ days inactive)
Best area for business expansion
Low stock + high demand products (urgent restock alert)


💡 Key Business Insights

📍 Top 3 areas contribute majority of total revenue
🚴 Delayed deliveries directly correlate with lower customer ratings
📢 Certain marketing channels deliver significantly higher ROAS
📦 Several high-demand products frequently hit low-stock levels
🔄 A significant portion of customers show churn risk after 90 days of inactivity
💳 UPI is the most preferred payment method


🛠️ Tools & Technologies
Show Image
Show Image
Show Image

Database: MySQL
Concepts Used: JOINs, Subqueries, Aggregations, CASE statements, Date functions, CTEs
Analysis Type: Business Intelligence, Exploratory Data Analysis (EDA)


📁 File Structure
Blinkit_SQL_Analysis/
│
├── README.md                        ← Project overview (this file)
└── blinkit_complete_analysis.sql    ← All 61 SQL queries (7 parts)

🚀 How to Run

Import the blinkit_db database into MySQL Workbench
Open blinkit_complete_analysis.sql
Run queries part by part or all at once
Explore the results and insights!


👨‍💻 Author
Pradeep Kumar
Aspiring Data Analyst | SQL | Python | Power BI
📧 [kumarpradeepnalot9828@gmail.com]
🔗 www.linkedin.com/in/
pradeep-kumar-50b03a2b5
]

⭐ If you found this project helpful, please give it a star!
