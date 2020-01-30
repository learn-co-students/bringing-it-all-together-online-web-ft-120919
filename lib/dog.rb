require 'pry'

class Dog
    
    attr_accessor :name, :breed, :id
    
    def initialize(attr_hash)
        attr_hash.each do |k, v|
            self.send("#{k}=", v) if self.respond_to?("#{k}=")
        end
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
        sql = "DROP TABLE IF EXISTS dogs"
        
        DB[:conn].execute(sql)
    end
    
    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
    
    def self.create(attr_hash)
        dog = self.new(attr_hash)
        dog.save
        dog
    end
    
    def self.new_from_db(row)
        attr_hash = {:id => [], :name => [], :breed => []}
        attr_hash[:id] = row[0]
        attr_hash[:name] = row[1]
        attr_hash[:breed] = row[2]
        self.new(attr_hash)
    end
    
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        
        dog = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog)
    end
    
    
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = self.new_from_db(dog[0])
            # binding.pry
          dog = dog_data
        else
          dog = self.create(dog)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"

        dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog)
    end


    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        
        DB[:conn].execute(sql, self.name, self.breed, self.id)
        self
    end

    
    

end