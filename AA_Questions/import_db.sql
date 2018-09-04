PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users, questions, question_follows, replies, question_likes;

CREATE TABLE users (
  fname varchar(255) NOT NULL,
  lname varchar(255)
);

CREATE TABLE questions (
  title varchar(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(user_id)
)

CREATE TABLE question_follows (
  SELECT
    *
  FROM
    questions
  JOIN
    users
  ON questions.user_id = user.id
);

CREATE TABLE replies (
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body text NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(question_id),
  FOREIGN KEY (reply_id) REFERENCES replies(reply_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
)

CREATE TABLE question_likes (
  question_id integer NOT NULL,
  user_id integer NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(question_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
)

INSERT INTO users (fname, lname)
VALUES ('Homer', 'Simpson'),
('Bart', 'Simpson'),
('Ned', 'Flanders'),
('Barney', 'Gumble');

INSERT INTO questions (title, body, user_id)
VALUES ('Homer''s question', 'Why is the sky blue??', 
  SELECT
    id
  FROM
    users
  WHERE
    name = 'Homer'
  ),
  
  ('Bart''s question', 'What''s my name??', 
    SELECT
      id
    FROM
      users
    WHERE
      name = 'Bart'
  )

