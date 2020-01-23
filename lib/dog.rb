class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    #Accepts a hash or keyword argument value with key-value pairs as an argument
    #Key-value pairs need to contain id, name, and breed
    @name = name
    @breed = breed 
    @id = id
  end #initialize

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self 
  end #save
  
  def self.create(attr_hash)
    dog = Dog.new(attr_hash)
    dog.save
    dog 
  end #self.create

  def self.new_from_db(row)
    #Dog.new(id: row[0], name: row[1], breed: row[2])
    Dog.create(name: row[1], breed: row[2])
  end #self.new_from_db

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end #self.drop_table

  def self.create_table
    # self.drop_table
    sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end #self.create_table

  def self.find_by_id(an_id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, an_id)[0]
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end #self.find_by_id

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * from dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      #Dog with that name and breed is already in the database
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      #Dog with that name and breed is NOT already in the db
      dog = Dog.create(name: name, breed: breed)
    end #if
    dog 
  end #self.find_or_create_by

  def self.find_by_name(a_name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    dog_info = DB[:conn].execute(sql, a_name)[0]
    Dog.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0])
  end #self.find_by_name

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  

end #class