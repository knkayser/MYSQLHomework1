USE sakila;

-- 1a display first and last names -- 
SELECT first_name AS 'First Name', last_name AS 'Last Name'
FROM actor;

-- 1b display first and last names in single columns
 SELECT *, CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'Actor Name' FROM `actor`;

-- 2a find id number, first name, and last name of an actor with first name of Joe
SELECT actor_id AS 'Actor ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE first_name = 'Joe';

-- 2b find actors whose last names contain GEN
SELECT *
FROM actor
WHERE last_name LIKE '%gen%';

-- 2c all actors with LI in last name, ordered by last name and first name
SELECT first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name ASC;

-- 2d display country id and country for Afghanistan, Bangladesh, and China
SELECT country_id AS 'Country ID', country AS 'Country'
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a create column in actor named description with BLOB
ALTER TABLE actor
ADD Description BLOB;

-- 3b delete description column
ALTER TABLE actor
DROP COLUMN Description;

-- 4a list last names of actors and how many actors have that last name
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Total Actors with Same Last Name'
FROM actor
GROUP BY last_name;

-- 4b list last names and number for names shared by at least two actors
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Total Actors with Same Last Name'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c change Groucho Williams to Harpo
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d oops, change it back
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a query to recreate address table
SHOW CREATE TABLE address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
);

-- 6a display first and last names ans address of staff members using join
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b display total amount rung up by each staff member in August 2005
SELECT staff.first_name, staff.last_name, SUM(amount) AS 'Total Amount Rung up (%)'
FROM staff
JOIN payment ON payment.staff_id = staff.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;

-- 6c list each film and number of actors for that film
SELECT title, COUNT(actor_id) AS 'Number of Actors'
FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY title;

-- 6d How many copies of Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) AS 'Number of Copies of Hunchback Impossble'
FROM inventory
WHERE film_id IN (
	SELECT film_id
	from film
	WHERE title = 'Hunchback Impossible'
);

-- 6e list the total paid by each customer
SELECT c.first_name, c.last_name, SUM(amount) AS 'Total Paid'
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY c.last_name ASC;

-- 7a display titles of movies starting with K and Q in English
SELECT title AS 'Title'
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language_id = 1;

-- 7b use subqueies to display all actors in Alone Trip
SELECT first_name AS 'First Name', last_name AS 'Last Name'
FROM actor 
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
        )
	);

-- 7c select names and emails of all Canadian customers
SELECT cu.first_name AS 'First Name', cu.last_name AS 'Last Name', cu.email
FROM address a
JOIN city c ON c.city_id = a.city_id 
JOIN customer cu ON cu.address_id = a.address_id
WHERE c.country_id IN (
	SELECT country_id
	FROM country
	WHERE country = 'Canada'
);

-- 7d identify all movies categorized as family films
SELECT title AS 'Family Movie Title'
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id IN (
		SELECT category_id
		FROM category
		WHERE name = 'Family'
        )
    );

-- 7e display most frequency rented movies in descending orders
SELECT title AS 'Title', COUNT(rental_id) AS 'Times Rented'
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY r.inventory_id
ORDER BY COUNT(rental_id) DESC;

-- 7f display how much business, in dollars, each store brought in 
SELECT c.store_id AS 'Store ID', SUM(amount) AS 'Total Business ($)'
FROM store s
JOIN customer c ON s.store_id = c.store_id
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY c.store_id;

-- 7g display for each store its store ID, city, and country
SELECT s.store_id AS 'Store ID', c.city AS 'City', cn.country AS 'Country'
FROM store s 
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country cn ON c.country_id = cn.country_id;

-- 7h list the top five genres in gross revenue in descending order
SELECT name AS 'Genre', SUM(amount) as 'Gross Revenue ($)'
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8a Create a view of the query above
CREATE VIEW top_five_genres AS
	SELECT name, SUM(amount) as 'Gross Revenue ($)'
	FROM category c
	JOIN film_category fc ON c.category_id = fc.category_id
	JOIN inventory i ON fc.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
	JOIN payment p ON r.rental_id = p.rental_id
	GROUP BY c.name
	ORDER BY SUM(amount) DESC LIMIT 5;

-- 8b Display the view created above
SELECT * FROM top_five_genres;

-- 8c Drop view
DROP VIEW top_five_genres;
