/* ============================================================================
PROJECT: Global Retail Performance & Margin Optimization (SQL Deep-Dive)
AUTHOR: Valid-Analyst
OBJECTIVE: Validate dashboard KPIs, analyze discount impact on profitability, 
           and rank top-performing products across global markets.
============================================================================
*/

-- 1. Executive Financial Summary: Overall Revenue, Net Profit, and Margin (%)
SELECT 
    COUNT(*) AS Total_Transactions,
    ROUND(SUM(sales), 2) AS Total_Revenue,
    ROUND(SUM(profit), 2) AS Total_Net_Profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS Net_Profit_Margin_Pct
FROM retail_sales;


-- 2. Discount Cannibalization Analysis: Impact of Discount Bands on Segment Profitability
SELECT 
    segment,
    discount_band,
    COUNT(*) AS Order_Count,
    ROUND(SUM(sales), 2) AS Net_Sales,
    ROUND(SUM(profit), 2) AS Net_Profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS Profit_Margin_Pct
FROM retail_sales
GROUP BY segment, discount_band
ORDER BY segment, Net_Profit DESC;


-- 3. Profitability Tier Audit (CASE WHEN Logic): Categorizing deals by margin health
SELECT 
    segment,
    CASE 
        WHEN profit <= 0 THEN 'Unprofitable / Break-Even'
        WHEN (profit / sales) * 100 < 10 THEN 'Low Margin (<10%)'
        WHEN (profit / sales) * 100 BETWEEN 10 AND 25 THEN 'Healthy Margin (10-25%)'
        ELSE 'High Margin (>25%)'
    END AS Margin_Tier,
    COUNT(*) AS Deal_Count,
    ROUND(SUM(sales), 2) AS Total_Sales,
    ROUND(SUM(profit), 2) AS Total_Profit
FROM retail_sales
GROUP BY segment, Margin_Tier
ORDER BY segment, Total_Profit DESC;


-- 4. Product Unit Economics: Comparing Revenue, COGS, and Net Margin by Product
SELECT 
    product,
    SUM(units_sold) AS Total_Units_Sold,
    ROUND(SUM(sales), 2) AS Total_Sales,
    ROUND(SUM(cogs), 2) AS Total_COGS,
    ROUND(SUM(profit), 2) AS Total_Profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS Product_Margin_Pct
FROM retail_sales
GROUP BY product
ORDER BY Total_Profit DESC;


-- 5. Top 3 Most Profitable Products per Country (Subquery & Window Function)
SELECT 
    country,
    product,
    Total_Profit,
    Profit_Rank
FROM (
    SELECT 
        country,
        product,
        ROUND(SUM(profit), 2) AS Total_Profit,
        RANK() OVER(PARTITION BY country ORDER BY SUM(profit) DESC) AS Profit_Rank
    FROM retail_sales
    GROUP BY country, product
) AS RankedProducts
WHERE Profit_Rank <= 3;
