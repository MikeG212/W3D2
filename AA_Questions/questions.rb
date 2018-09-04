require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end  
end

class User
  attr_reader :id, :fname, :lname

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        users 
      WHERE
        id = ?
    SQL
  
    User.new(user.first) 
  end
  
  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM 
        users 
      WHERE
        fname = ? AND lname = ?
    SQL
  
    User.new(user.first)
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']  
  end
  
  def create 
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO 
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def authored_questions
    Question.find_by_author_id(@id)
  end
  
  def authored_replies
    Reply.find_by_user_id(@id)
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end
  
end 







class Question
  attr_reader :id, :title, :body, :user_id
  
  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        questions 
      WHERE
        id = ?
    SQL
    Question.new(question.first) 
  end
  
  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM 
        questions 
      WHERE
        user_id = ?
    SQL
    
    questions.map { |q| Question.new(q) }
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']  
    @user_id = options['user_id']  
  end
  
  def create 
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO 
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end 
  
  def author
    User.find_by_id(@user_id)
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
  
  def likers 
    QuestionLike.likers_for_question_id(@id)
  end 
  
  def num_likes 
    QuestionLike.num_likes_for_question_id(@id)
  end 
  
end 







class QuestionFollow
  attr_reader :id, :question_id, :user_id
  
  def self.find_by_id(id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollow.new(question_follow.first) 
  end
  
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM 
        question_follows
      JOIN 
        users ON question_follows.user_id = users.id
      WHERE
        question_id = ?
    SQL
    followers.map { |f| User.new(f) }
  end 
  
  def self.followed_questions_for_user_id(user_id)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN 
        questions ON question_follows.question_id = questions.id 
      WHERE 
        question_follows.user_id = ?
    SQL
    followed_questions.map { |q| Question.new(q) }
  end
  
  def self.most_followed_questions(n)
    mfquestions_qid = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      GROUP BY 
        question_id
      ORDER BY 
        COUNT(questions.user_id) DESC
      LIMIT ?
    SQL
    mfquestions_qid.map { |hash| Question.find_by_id(hash['question_id']) }
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']  
    @user_id = options['user_id']
  end 
   
  def create 
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO 
        question_follows (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end 
end










class QuestionLike
  attr_reader :id, :question_id, :user_id
  
  def self.find_by_id(id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        question_likes
      WHERE
        id = ?
    SQL
    QuestionLike.new(question_like.first) 
  end
  
  def self.likers_for_question_id(question_id)
    likers_uid = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM
        question_likes
      JOIN
        users ON question_likes.user_id = users.id
      WHERE
        question_id = ?
    SQL
    likers_uid.map { |hash| User.find_by_id(hash['user_id']) }
  end
  
  def self.num_likes_for_question_id(question_id)
    likers_count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(user_id)
      FROM
        question_likes
      JOIN
        users ON question_likes.user_id = users.id
      WHERE
        question_id = ?
    SQL
    likers_count.first.values.first
  end
  
  def self.liked_questions_for_user_id(user_id)
    liked_questions_qid = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM 
        question_likes 
      JOIN 
        users ON question_likes.user_id = users.id
      WHERE 
        user_id = ?
    SQL
    liked_questions_qid.map { |hash| Question.find_by_id(hash['question_id']) }
  end 
  
  def self.most_liked_questions(n)
    ml_questions_ids = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_likes
      JOIN
        questions ON question_likes.question_id = questions.id
      GROUP BY 
        question_id
      ORDER BY 
        COUNT(questions.user_id) DESC
      LIMIT ?
    SQL
    ml_questions_ids.map { |hash| Question.find_by_id(hash['question_id']) }
  end 
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']  
    @user_id = options['user_id']
  end
  
  def create 
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO 
        question_likes(question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end 








class Reply
  attr_reader :id, :question_id, :user_id
  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        replies
      WHERE
        id = ?
    SQL
    Reply.new(reply.first) 
  end
  
  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end 
  
  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end 
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']  
    @user_id = options['user_id']
    @reply_id = options['reply_id']
    @body = options['body']  
  end
  
  def create 
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @reply_id, @body)
      INSERT INTO 
        replies (question_id, user_id, reply_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def author
    User.find_by_id(@user_id)
  end
  
  def question
    Question.find_by_id(@question_id)
  end
  
  def parent_reply
    return question unless !!@reply_id
    Reply.find_by_id(@reply_id)
  end
  
  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end   
end 

 