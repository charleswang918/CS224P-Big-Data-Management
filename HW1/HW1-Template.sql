-- Your Name: Chuqi Wang (79167724)


-- 1. Table Creation and Analysis –-

-- SQL DDL statements
\i /Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/ZotMusicDDL.sql
-- Songs table field design observations
\d songs

/*
record_id: text NOT NULL
track_number: int NOT NULL
title: text NOT NULL
length: int NOT NULL
bpm: int
mood: text
*/

-- 2. Data Loading (COPY commands) --
\copy Users from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Users.csv' delimiter ',' csv header;
\copy Artists from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Artists.csv' delimiter ',' csv header;
\copy Listeners from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Listeners.csv' delimiter ',' csv header;
\copy Records from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Records.csv' delimiter ',' csv header;
\copy Singles from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Singles.csv' delimiter ',' csv header;
\copy Albums from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Albums.csv' delimiter ',' csv header;
\copy Songs from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Songs.csv' delimiter ',' csv header;
\copy Sessions from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Sessions.csv' delimiter ',' csv header;
\copy Reviews from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/Reviews.csv' delimiter ',' csv header;
\copy ReviewLikes from '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW1/zot-music-dataset-assignment1/ReviewLikes.csv' delimiter ',' csv header;
-- 3. Query Answers --
set search_path to zotmusic;

-- Problem A --
select 'Users' as entity, count(*) from Users union all
select 'Records' as entity, count(*) from Records union all
select 'Reviews' as entity, count(*) from Reviews;

-- Problem B --
select u.user_id, u.email, u.nickname, u.zip from users as u
join artists on artists.user_id = u.user_id
join listeners on listeners.user_id = u.user_id
where email like '%@icloud.com';

-- Problem C --
select record_id, title, genre, release_date from records
where artist_user_id = (
	select a.user_id from artists as a
	join users as u on a.user_id = u.user_id
	where email = 'fwilson@outlook.com'
) 
order by release_date;

-- Problem D --
with cte as (
	select * from records
	where artist_user_id = (
	select a.user_id from artists as a
	join users as u on a.user_id = u.user_id
	where email = 'fwilson@outlook.com'
	)
)

select artist_user_id, genre, 
	count(case when a.record_id is not null then 1 end) as album_count,
	count(case when s.record_id is not null then 1 end) as single_count
from cte
left join singles as s on cte.record_id = s.record_id
left join albums as a on cte.record_id = a.record_id
group by artist_user_id, genre;

-- Problem E --
select coalesce(a.stagename, u.nickname) as name, 
u.email from users as u
join artists as a on u.user_id = a.user_id
join records as r on u.user_id = r.artist_user_id
group by a.user_id, a.stagename, u.email, u.nickname
having count(distinct r.genre) >= 9;

-- Problem F --
with cte as (
	select artist_user_id from records as r
	where r.genre in ('R&B', 'Hip-Hop')
	group by artist_user_id
	having count(distinct case when r.genre = 'R&B' then 1 end) > 0 and 
	count(distinct case when r.genre = 'Hip-Hop' then 1 end) > 0
)

select u.user_id, u.email from users as u
join cte on u.user_id = cte.artist_user_id
where u.user_id not in (
	select distinct artist_user_id from records as r
	where r.genre in ('Indie', 'Jazz')
)
order by u.user_id;

-- Problem G --
select email, nickname, array_length(string_to_array(genres, ','), 1) as num_genres
from users 
order by num_genres desc 
limit 10;

-- Problem H --
select unnest(string_to_array(genres, ',')) as genre, count(user_id) as num_users
from users 
group by genre 
order by num_users desc;

-- Problem I --
select r.title, r.record_id, s.track_number, s.title, 
count(se.user_id) as num_listeners
from sessions as se
join songs as s on se.record_id = s.record_id and se.track_number = s.track_number
join records as r on se.record_id = r.record_id
where se.remaining_time <= s.length * 0.2 or se.replay_count > 0
group by r.record_id, s.track_number, s.title
order by num_listeners desc
limit 10;

-- Problem J --

  -- View DDL:
create view RatedRecords as
with cte as (
	select rv.review_id, rv.record_id, rv.rating, 
	coalesce(count(rl.user_id), 0) + 1 as weight
	from reviews as rv
	left join reviewlikes as rl on rv.review_id = rl.review_id
	group by rv.review_id, rv.record_id, rv.rating
)
select r.title, r.record_id, 
coalesce(sum(cte.rating * cte.weight) / nullif(sum(cte.weight), 0), 0) as rating, 
count(cte.review_id) as num_reviews
from records as r
join cte on r.record_id = cte.record_id
group by r.title, r.record_id;

  -- View test query:
select * from RatedRecords
where num_reviews >= 5
order by rating desc
limit 10;

-- Problem K --                                                                 

  -- Table alteration DDL:
alter table records
add rating decimal(3, 2);

  -- Table update query:
update records as r
set rating = RatedRecords.rating
from RatedRecords
where r.record_id = RatedRecords.record_id;

  -- Change verification query:
select r.title, r.record_id, r.rating, RatedRecords.num_reviews 
from records as r
join RatedRecords on r.record_id = RatedRecords.record_id
where RatedRecords.num_reviews >= 5
order by r.rating desc
limit 10;

-- Problem L --                                                            

  -- Query against view:
select a.user_id, u.nickname, avg(rr.rating) as content_rating 
from artists as a
join users as u on a.user_id = u.user_id
join records as r on a.user_id = r.artist_user_id
join RatedRecords as rr ON r.record_id = rr.record_id
group by a.user_id, u.nickname
having avg(rr.rating) >= 3.3;


EXPLAIN ANALYZE
select a.user_id, u.nickname, avg(rr.rating) as content_rating 
from artists as a
join users as u on a.user_id = u.user_id
join records as r on a.user_id = r.artist_user_id
join RatedRecords as rr ON r.record_id = rr.record_id
group by a.user_id, u.nickname
having avg(rr.rating) >= 3.3;

  -- Index DDL:
create index idx_records_rating on records (rating);

  -- Query against materialized data:
select a.user_id, u.nickname, avg(r.rating) as content_rating 
from artists as a
join users as u on a.user_id = u.user_id
join records as r on a.user_id = r.artist_user_id
group by a.user_id, u.nickname
having avg(r.rating) >= 3.3;

EXPLAIN ANALYZE
select a.user_id, u.nickname, avg(r.rating) as content_rating 
from artists as a
join users as u on a.user_id = u.user_id
join records as r on a.user_id = r.artist_user_id
group by a.user_id, u.nickname
having avg(r.rating) >= 3.3;
  /*
     … brief performance discussion …
	 Without Materialized Data (Using RatedRecords View), the planning time is 2.533 ms and 
	 execution time is 52.630 ms.
	 
	 With Materialized Data and Index (Using Records Table Directly), the planning time is 
	 1.907 ms and the execution time is only 1.526 ms.

	 In conclusion, Using materialized data (with an indexed rating column in Records) provides 
	 significantly faster and more scalable performance than dynamically calculating ratings 
	 through the RatedRecords view.
  */

-- Problem M --    
select coalesce(music_quality, 'ALL') as music_quality, 
coalesce(device, 'ALL') as device,
count(*) as num_session
from sessions
group by rollup(music_quality, device)
order by num_session desc;




-- HW2 Question 7 -- 
--(a):
select review_id, record_id, rating from reviews 
where user_id = 'user_9e48cbb4-0bf9-43fc-a578-213fae51068b'
order by rating desc limit 10

--(b):
select count(*) from records
where genre = 'Folk';

--(c):
select rc.artist_user_id, rv.posted_at, rv.rating, rc.title, rv.review_id, rv.record_id 
from reviews rv
join records rc on rv.record_id = rc.record_id


COPY (
select rc.artist_user_id, rv.posted_at, rv.rating, rc.title, rv.review_id, rv.record_id 
from reviews rv
join records rc on rv.record_id = rc.record_id) TO '/Users/chuqiwang/Desktop/UCI/CS224P/assignments/HW2/setup/reviews_by_artist.csv' 
DELIMITER ',' CSV HEADER

select rc.artist_user_id, rv.record_id, rc.title, rv.rating, rv.posted_at
from reviews rv
join records rc on rv.record_id = rc.record_id
where rc.artist_user_id = 'user_6f33f39e-7659-4673-bd80-ca11394424b0'
order by rv.posted_at desc limit 10

--(d):
select max(replay_count) from sessions
where user_id = 'user_05f9132b-47fb-4d2b-992c-17b3c4afb2df'
and initiate_at between'2024-08-01 00:00:00' and '2024-09-01 00:00:00';

select * from users





