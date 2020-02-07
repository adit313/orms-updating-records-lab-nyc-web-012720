require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(name, grade, id = nil)
  	@name = name
  	@grade = grade
  	@id = id
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
      new_student = self.new(row[1],row[2], row[0]) # self.new is the same as running Song.new
      new_student  
  end

  def self.all
        sql = <<-SQL
        SELECT * FROM students
    SQL

    result = []

    student_maker = DB[:conn].execute(sql)
    student_maker.each {|e| result << self.new_from_db(e)}
    return result
  end

  def self.find_by_name(input)
    # find the student in the database given a name
    # return a new instance of the Student class
            sql = <<-SQL
        SELECT * FROM students where name = ?
    SQL

    student_maker = DB[:conn].execute(sql, input)

    return self.new_from_db(student_maker[0])
  end
  
def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
 
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

end
