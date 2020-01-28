class Dog
  attr_accessor :name, :breed, :id

  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.create(name: nil, breed: nil)
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, name, breed)
    result_row = DB[:conn].execute("SELECT * FROM dogs WHERE id = last_insert_rowid();")[0]
    new_from_db(result_row)
  end


  def self.new_from_db(row)
    id, name, breed = row[0..2]
    new(name: name, breed: breed, id: id)
  end

  def self.find_by_id(id_param)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    row = DB[:conn].execute(sql, id_param)[0]
    row.empty? ? nil : new_from_db(row)
  end

  def self.find_by_name(name_param)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    row = DB[:conn].execute(sql, name_param)[0]
    row.empty? ? nil : new_from_db(row)
  end

  def self.find_or_create_by(name: nil, breed: nil)
    if breed.nil?
      self.find_by_name(name)
    else
      sql = "SELECT * FROM dogs WHERE (name, breed) = (?, ?);"
      row = DB[:conn].execute(sql, name, breed)[0]
      if row.nil? || row.empty?
        self.create(name: name, breed: breed)
      else
        self.new_from_db(row)
      end
    end
  end

  def save
    if self.id && self.find_by_id(self.id)
      self.update
    else
      reference = Dog.find_or_create_by(name: self.name, breed: self.breed)
      self.id = reference.id
      self.name = reference.name
      self.breed = reference.breed
    end
    self
  end

  def update
    sql = "UPDATE dogs SET (name, breed) = (?, ?) WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    nil
  end
end