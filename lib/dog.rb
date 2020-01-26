class Dog
    attr_accessor :name, :breed, :id
#accepts a hash or keyword argument value with key-value pairs as an argument. key-value pairs need to contain id, name, and breed
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end
    def self.create_table
        sql = <<-SQL
               CREATE TABLE IF NOT EXISTS dogs (
                   id INTEGER PRIMARY KEY,
                   name TEXT,
                   breed TEXT
               )
               SQL
               DB[:conn].execute(sql)

    end

    def self.drop_table
        sql = <<-SQL
                  DROP TABLE IF EXISTS dogs
               SQL
               DB[:conn].execute(sql)

    end
  
#saves an instance of the dog class to the database and then sets the given dogs `id` attribute
#returns an instance of the dog class
    def save
        if self.id
            self.update
        else
          sql = <<-SQL
                 INSERT INTO dogs (name, breed) 
                 VALUES (?, ?)
               SQL

               DB[:conn].execute(sql, self.name, self.breed)
               #then sets the given dogs `id` attribute
               @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
             
        end
        #returns an instance of the dog class
        self
    end
   
    def self.create(attributes_hash)
      
        dog = Dog.new(attributes_hash)
        dog.save
        dog  
    end

     #creates an instance with corresponding attribute values
    def self.new_from_db(row)

        new_dog = self.new(id: row[0], name: row[1],breed: row[2])
        new_dog
       
    end
    
    #returns a new dog object by id
    def self.find_by_id(id)
        sql = <<-SQL
               SELECT * FROM dogs
               WHERE id = ?
               LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first

    end
   # #when two dogs have the same name and different breed, it returns the correct dog specifying with name = ? AND breed = ?
   #when creating a new dog with the same name as persisted dogs, it returns the correct dog
    def self.find_or_create_by(name:, breed:)
       sql = <<-SQL
           SELECT * FROM dogs
           WHERE name = ? AND breed = ? 
       SQL

      dog = DB[:conn].execute(sql, name, breed).first

        # creates an instance of a dog if it does not already exist
       if dog 
           new_dog = self.new_from_db(dog)
          
       else
           new_dog = self.create(name: name, breed: breed) #can also be written as self.create(:name => name, :breed => breed)
       end
    end

     #returns an instance of dog that matches the name from the DB
    def self.find_by_name(name)

        sql = <<-SQL
             SELECT * FROM dogs
             WHERE name = ?
             LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end
    #updates the record associated with a given instance
    def update
        sql = <<-SQL
           UPDATE dogs
           SET name = ?, breed = ?
           WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
end