use zomato;
select * from product;
select * from sales;
select * from users;
select * from goldusers_signup;

-- 1. What is the total amount each customer spent on zomato ?
select b.userid,sum(a.price) total_amt_spent from product a
join sales b on a.product_id=b.product_id
group by b.userid;

-- 2. How many days each customer visited zomato ?
select userid,count(distinct created_date) visit_days from sales
group by userid;

-- 3.Was the first product purchased by the each customer ?

select * from
(select *,rank() over(partition by userid order by created_date) rnk from sales)a where rnk=1;
-- conclusion: yes,each customer bought first product.

-- 4. What is the most purchased item in the menu and how many times was it purchased by all customers ?
select userid,product_id,count(product_id) from sales where product_id =
(select product_id from sales group by product_id order  by count(product_id) desc limit 1)
group by userid;

-- 5. Which item was the most popular for each customer ?
select * from 
(select *,rank() over(partition by userid order by cnt desc ) rnk from  
(select userid,product_id,count(product_id)  cnt from sales group by userid,product_id )a)b
where rnk = 1;

-- 6. Which item was the first purchased by the customer after they became a member ?
select * from
(select c.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a join goldusers_signup b on 
a.userid=b.userid and created_date >= gold_signup_date)c)d where rnk = 1 ;

-- 7. Which item was purchased just before the customer become a member ?
select * from
(select c.*,rank() over(partition by userid order by created_date desc) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a join goldusers_signup b on 
a.userid=b.userid and created_date <= gold_signup_date)c)d where rnk = 1 ;

-- 8. What is the total order and amount spent for each member before they became a member ?

select a.userid,count(a.created_date) order_purchased,sum(c.price) total_amt_spent from product c join sales a on a.product_id=c.product_id
 join goldusers_signup b on 
a.userid=b.userid and created_date <= gold_signup_date
group by userid;

/* 9. If buying each product generates point e.g. ₹5=2 zomato points and each product has different purchasing points
 e.g. p1 ₹5=1 zomato point,for p2 ₹10=5 zomato points and p3 ₹5=1 zomato points
 Que-Calculate points collected by each customers and for which product most points have been given till now ?
 */

select userid,sum(total_points) total_money_earned from 
(select e.*,amt/points total_points from
(select d.* ,case when product_id =1 then 5 when product_id =2 then 2 when product_id =3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt  from 
(select a.*,b.price from sales a join 
 product b on a.product_id=b.product_id)c
 group by userid,product_id)d)e)f
 group by userid;

select product_id,max(total_points_earned) from
(select product_id,sum(total_points) total_points_earned from 
(select e.*,amt/points total_points from
(select d.* ,case when product_id =1 then 5 when product_id =2 then 2 when product_id =3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt  from 
(select a.*,b.price from sales a join 
 product b on a.product_id=b.product_id)c
 group by userid,product_id)d)e)f
 group by product_id)g;

/* 10. In the first one year after a customer joins a gold program (including their joining date) irrespective of what customer has
purchased they earn 5 zomato points for every ₹10 spent.Who earned more userid = 1 or 3 and what was their points earning in their first year ?
*/
select c.*,d.price*0.5 total_points_earned from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a join goldusers_signup b on 
a.userid=b.userid and created_date >= gold_signup_date and created_date <= date_add(gold_signup_date,interval 1 year))c
join product d on c.product_id = d.product_id;

-- 11. rnk all the transaction of the customers ?
select *,rank() over(partition by userid order by created_date) from sales ;

-- 12. rnk all the transactions for each member whenever they are a zomato gold member, for every non gold member transaction mark as na .
select C.*,case when gold_signup_date is null then 'NA' ELSE RANK() over(partition by userid order by created_date )  END as rnk from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a left join goldusers_signup b on 
a.userid=b.userid and created_date >= gold_signup_date)C;









