/*markdown
1. We want to highlight 10 wines to increase our sales. Which ones should we choose and why?
*/

SELECT name, ratings_average, ratings_count
FROM wines
GROUP BY name
ORDER BY ratings_average DESC, ratings_count DESC
LIMIT 10;

/*markdown
2. We have a limited marketing budget for this year. Which country should we prioritise and why?
*/

SELECT name, users_count, wines_count, wineries_count
FROM countries
ORDER BY users_count DESC, wines_count DESC
LIMIT 3;

/*markdown
3. We would like to give awards to the best wineries. Come up with 3 relevant ones. Which wineries should we choose and why?
*/

SELECT SUM (ratings_average) AS rating_average, winery_id, wineries.name
FROM wines
INNER JOIN wineries ON wines.winery_id = wineries.id
GROUP BY winery_id, wineries.name
ORDER BY rating_average DESC
LIMIT 3
;




/*markdown
4. We detected that a big cluster of customers likes a specific combination of tastes. We identified a few keywords that match these tastes: coffee, toast, green apple, cream, and citrus (note that these keywords are case sensitive ⚠️). We would like you to find all the wines that are related to these keywords. Check that at least 10 users confirm those keywords, to ensure the accuracy of the selection. Additionally, identify an appropriate group name for this cluster.
*/

SELECT
    wines.name as wine_name,
    keywords_wine.*,
    keywords.name as keywords_name
FROM wines
join keywords_wine on wines.id = keywords_wine.wine_id
join keywords on keywords_wine.keyword_id = keywords.id
WHERE keywords_name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
    and keywords_wine.count >= 10
GROUP BY wine_name
HAVING count(distinct(keywords_name)) >= 5;    

/*markdown
5. We would like to select wines that are easy to find all over the world. Find the top 3 most common grapes all over the world and for each grape, give us the the 5 best rated wines.
*/

--5a. Select wines that are easy to find all over the world. 
--5b. Find the top 3 most common grapes all over the world
WITH top_grapes AS (
    SELECT grape_id, country_code
    FROM most_used_grapes_per_country
    GROUP BY grape_id
    ORDER BY SUM(wines_count) DESC
    LIMIT 3
)

SELECT tg.grape_id,
       g.name AS grape_name,
       w.name AS wine_name,
       w.ratings_average,
       w.ratings_count,
       r.country_code
FROM top_grapes tg
JOIN regions r ON tg.country_code = r.country_code
JOIN wines w ON w.region_id = r.id
JOIN grapes g ON g.id = tg.grape_id
ORDER BY tg.grape_id, w.ratings_average DESC, w.ratings_count DESC
LIMIT 5;

--5c. for each grape, select the 5 best rated wines
  SELECT name, region_id, ratings_average
  FROM wines
  GROUP BY name
  ORDER BY ratings_average DESC
  LIMIT 5;


/*markdown
6. We would like to create a country leaderboard. Come up with a visual that shows the average wine rating for each country. Do the same for the vintages.
*/

--AVG wine rating for each country
SELECT
    ROUND(avg(wines.ratings_average), 2) AS Average_Rating,
    sum(wines.ratings_count) AS Rating_Count,
    countries.name AS Country
FROM
    wines
    JOIN regions ON regions.id = wines.region_id
    JOIN countries ON countries.code = regions.country_code
WHERE
    wines.ratings_average AND wines.ratings_count > 0
GROUP BY
    Country
ORDER BY
    Average_Rating DESC

import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

# Create a connection to the database
conn = sqlite3.connect('vivino.db')

# Define the SQL query
query = """
SELECT
    ROUND(avg(wines.ratings_average), 2) AS Average_Rating,
    sum(wines.ratings_count) AS Rating_Count,
    countries.name AS Country
FROM
    wines
    JOIN regions ON regions.id = wines.region_id
    JOIN countries ON countries.code = regions.country_code
WHERE
    wines.ratings_average AND wines.ratings_count > 0
GROUP BY
    Country
ORDER BY
    Average_Rating DESC
"""

# Execute the query and store the result in a DataFrame
df = pd.read_sql_query(query, conn)

# Close the connection to the database
conn.close()

# Create a bar plot of the average rating for each country
plt.figure(figsize=(10, 6))
plt.barh(df['Country'], df['Average_Rating'], color='skyblue')
plt.xlabel('Average Rating')
plt.title('Average Wine Rating by Country')
plt.gca().invert_yaxis()  # Invert y-axis to have the country with the highest rating at the top
plt.show()

--AVG vintage rating for each country
SELECT
    ROUND(avg(vintages.ratings_average), 2) AS Average_Rating,
    sum(vintages.ratings_count) AS Rating_Count,
    countries.name AS Country
FROM
    vintages
    JOIN wines ON wines.id = vintages.wine_id
    JOIN regions ON regions.id = wines.region_id
    JOIN countries ON countries.code = regions.country_code
WHERE
    vintages.ratings_average AND vintages.ratings_count > 0
GROUP BY
    Country
ORDER BY
    Average_Rating DESC

/*markdown
7. One of our VIP clients likes Cabernet Sauvignon and would like our top 5 recommendations. Which wines would you recommend to him?
*/

SELECT
    wines.name AS Wine,
    grapes.name AS Grape,
    wines.ratings_count AS 'Ratings Count',
    wines.ratings_average
FROM
    wines
    JOIN regions ON regions.id = wines.region_id
    JOIN countries ON countries.code = regions.country_code
    JOIN most_used_grapes_per_country AS mugpc ON mugpc.country_code = countries.code
    JOIN grapes ON grapes.id = mugpc.grape_id
WHERE Grape = 'Cabernet Sauvignon'
LIMIT 5;