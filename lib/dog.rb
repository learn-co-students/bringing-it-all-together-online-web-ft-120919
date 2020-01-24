class Dog
  attr_accessor :name, :breed, :id

  def initialize(params = nil, id:nil , name:nil, breed:nil)
    if (!params.nil?)
      @id = params["id"]
      @name =  params["name"]
      @breed = params["breed"]
    else
      @id=id
      @name=name
      @breed=breed
    end
  end


  def self.create_table
    sql =  <<-SQL
     CREATE TABLE IF NOT EXISTS dogs (
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
       )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
     DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.find_by_id(id)
    sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE id = ?
     LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    @id = row[0]
    @name =  row[1]
    @breed = row[2]
    params = {id: @id, name: @name, breed:@breed}
    new_animal = self.new(params)
    new_animal  # return the newly created instance
  end

  def self.find_or_create_by(name:, breed:)
    results = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !results.empty?
      row = results[0]
      id = row[0]
      name = row[1]
      breed = row[2]
      dog = Dog.new(id:id, name:name, breed:breed)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog

  end

  def self.find_by_name(name)
    sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = ?
     LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

end