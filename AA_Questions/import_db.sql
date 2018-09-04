PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname varchar(255) NOT NULL,
  lname varchar(255)
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title varchar(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id integer NOT NULL,
  user_id integer NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body text NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id integer NOT NULL,
  user_id integer NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
  users (fname, lname)
VALUES 
  ('Homer', 'Simpson'),
  ('Bart', 'Simpson'),
  ('Ned', 'Flanders'),
  ('Barney', 'Gumble');

INSERT INTO 
  questions (title, body, user_id)
VALUES 
  ('Homer''s question', 'Why is the sky blue??', (SELECT id FROM users WHERE fname = 'Homer') ),
  ('Bart''s question', 'What''s my name??', (SELECT id FROM users WHERE fname = 'Bart') );