class ModelBase
  def self.find_by_id(table_name, id)
    obj = QuestionsDatabase.instance.execute(<<-SQL, table_name, id)
      SELECT
        *
      FROM 
        ? 
      WHERE
        id = ?
    SQL
  
    self.class.new(obj.first) 
  end
end