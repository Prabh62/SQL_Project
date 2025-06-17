-- Q1: Who Is The senior Most Emploee based upon Job title ?
Select * from Employee
Order by levels desc
limit 1

-- Q2: Which Countries has the most Invoices ?
Select Count(*) as c, Billing_country 
From invoice
Group by billing_country
order by c Desc

-- Q3: What are top 3 values of total invoice
Select total From invoice
order by total desc
limit 3

-- Q4: Which City has the best Customers? 
-- We would like to throw a Promotional music festival in the city we made most money.
-- write a query that returens one city that has the higest sum of invoice totals.
-- Return both the city name & sum of all invoice totals
Select Sum(Total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc

-- Q5: Who is the best customer?
-- Write a query that returns the person who spent the most money
SELECT c.customer_id,c.first_name,c.last_name,SUM(i.total) AS total
FROM customer as c
JOIN invoice  as i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY total DESC
LIMIT 1;

-- Q6: Write a query to return the email, first name ,last name, & genre of all Rock Music Listeners.
-- Return your list ordred alphabetically by email starting  with A
SELECT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id in(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- Q7: Write a query that returns the artist name and total track count of the top 10 rock bands
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS Number_of_songs
From track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY Number_of_songs DESC
LIMIT 10;

-- Q8: Return all the track names that have  song length longer than the average song length.
-- Returne the name and milliseconds fron each track.
-- Order by the song length with the longest songs listed first.
SELECT name, milliseconds
FROM track
WHERE milliseconds >(
	SELECT AVG (milliseconds) AS avg_track_length
	FROM track
)
ORDER BY Milliseconds DESC;

-- Q9: Find how much amount spent by each customer on artist?
-- Write query to return customer name, artistname and total spent
 WITH best_selling_artist AS (
	SELECT artist.artist_id AS Artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.Quantity) AS artist_total_sales
	FROM invoice_line
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN album ON track.album_id = album.album_id
	JOIN artist ON album.artist_id = artist.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
 )
 
 SELECT c.customer_id,c.first_name, c.last_name, bsa.artist_name, bsa.
 SUM(il.unit_price*il.quantity) AS Consumer_total_Spent
 FROM customer c
 JOIN invoice i ON c.customer_id = i.customer_id
 JOIN invoice_line il ON il.invoice_id = i.invoice_id
 JOIN track t ON t.track_id = il.track_id
 JOIN album abl ON abl.album_id = t.album_id
 JOIN best_selling_artist bsa ON bsa.artist_id = abl.artist_id
 GROUP BY 1,2,3,4,5
 ORDER BY 6 DESC
 LIMIT 5;

-- Q10: We want to find out the most popular music genre for each country.
-- We determine the most popular genreas the genre with the highest amount of purchases.
-- Write a query that returns each country along with top genre.
-- For countries where the maximu mnumber of purchases is sharedreturn all genres.
WITH popular_genre AS
(
	SELECT COUNT(il.quantity) AS Purchase, c.country, g.name, g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.Country ORDER BY COUNT(il.quantity)DESC) AS RowNo
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id= t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC,1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <=1
  
-- Q11: Write a query that determine the customer that has spent the most on music for each country.
-- Write a queery that returns the country along with top customer and how much they spent.
-- For countries where the top amount spent is shared.
-- provide all customers who spent this amount.

WITH RECURSIVE
	customer_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS spending_total
		FROM invoice
		JOIN customer on Customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),
		
	Country_max_spending AS(
		SELECT billing_country,MAX(spending_total) AS max_spending
		FROM customer_with_country
		GROUP BY Billing_country)

SELECT cc.billing_country,cc.spending_total,cc.first_name,cc.last_name,cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.spending_total = ms.max_spending
ORDER BY 1