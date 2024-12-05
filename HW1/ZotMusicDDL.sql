DROP SCHEMA IF EXISTS ZotMusic CASCADE;
CREATE SCHEMA ZotMusic;
SET search_path TO ZotMusic;

CREATE TABLE Users (
    user_id        text NOT NULL,
    email          text NOT NULL,
    joined_date    date NOT NULL,
    nickname       text NOT NULL,
    street         text,
    city           text,
    state          text,
    zip            text,
    genres         text,
    PRIMARY KEY (user_id)
);

CREATE TABLE Artists (
    user_id        text,
    bio            text,
    stagename      text,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE
);

CREATE TABLE Listeners (
    user_id        text,
    subscription   text,
    first_name     text NOT NULL,
    last_name      text NOT NULL,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE,
    CHECK (subscription IN ('free', 'monthly', 'yearly'))
);

CREATE TABLE Records (
    record_id      text NOT NULL,
    artist_user_id text NOT NULL,
    title          text NOT NULL,
    genre          text NOT NULL,
    release_date   date NOT NULL,
    PRIMARY KEY (record_id),
    FOREIGN KEY (artist_user_id) REFERENCES Artists (user_id) ON DELETE CASCADE
);

CREATE TABLE Singles (
    record_id      text NOT NULL,
    video_url      text,
    PRIMARY KEY (record_id),
    FOREIGN KEY (record_id) REFERENCES Records (record_id) ON DELETE CASCADE
);

CREATE TABLE Albums (
    record_id      text NOT NULL,
    description    text,
    PRIMARY KEY (record_id),
    FOREIGN KEY (record_id) REFERENCES Records (record_id) ON DELETE CASCADE
);

CREATE TABLE Songs (
    record_id      text NOT NULL,
    track_number   int NOT NULL,
    title          text NOT NULL,
    length         int NOT NULL,
    bpm            int,
    mood           text,
    PRIMARY KEY (record_id, track_number),
    FOREIGN KEY (record_id) REFERENCES Records (record_id) ON DELETE CASCADE
);

CREATE TABLE Sessions (
    session_id        text NOT NULL,
    user_id           text NOT NULL,
    record_id         text NOT NULL,
    track_number      int NOT NULL,
    initiate_at       timestamp NOT NULL,
    leave_at          timestamp NOT NULL,
    music_quality     text NOT NULL,
    device            text NOT NULL,
    remaining_time    int NOT NULL,
    replay_count      int,
    PRIMARY KEY (session_id),
    FOREIGN KEY (user_id) REFERENCES Listeners(user_id) ON DELETE CASCADE,
    FOREIGN KEY (record_id, track_number) REFERENCES Songs(record_id, track_number) ON DELETE CASCADE
);

CREATE TABLE Reviews (
    review_id     text NOT NULL,
    user_id       text NOT NULL,
    record_id     text NOT NULL,
    rating        int NOT NULL,
    body          text,
    posted_at     timestamp NOT NULL,
    PRIMARY KEY (review_id),
    FOREIGN KEY (user_id) REFERENCES Listeners (user_id) ON DELETE CASCADE,
    FOREIGN KEY (record_id) REFERENCES Records (record_id) ON DELETE CASCADE
);

CREATE TABLE ReviewLikes(
    user_id text NOT NULL,
    review_id text NOT NULL,
    PRIMARY KEY (user_id, review_id),
    FOREIGN KEY (user_id) REFERENCES Listeners(user_id) ON DELETE CASCADE,
    FOREIGN KEY (review_id) REFERENCES Reviews(review_id) ON DELETE CASCADE
);
