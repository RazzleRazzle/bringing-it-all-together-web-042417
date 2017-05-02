require "pry"
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:name,breed:breed,id:id=nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(array)
    new_dog = self.new
    new_dog.id = array[0]
    new_dog.name = array[1]
    new_dog.breed = array[2]
    new_dog
  end

  def save
    if self.id == nil
      sql = "INSERT INTO dogs(name,breed) VALUES (?,?)"
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      self.update
    end
    self
  end

  def self.create(name:name,breed:breed)
    new_dog = self.new
    new_dog.name = name
    new_dog.breed = breed
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql,id)
    self.new_from_db(row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql,name)
    self.new_from_db(row[0])
  end

  def self.find_or_create_by(name:name, breed:breed)
    our_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !our_dog.empty?
      dog_info = our_dog[0]
      self.new_from_db(dog_info)
    else
      new_dog = self.create(name:name, breed:breed)
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?,breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
