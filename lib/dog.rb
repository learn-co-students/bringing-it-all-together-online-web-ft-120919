require 'pry'

class Dog
    attr_accessor :name, :breed, :id
    def initialize(hash)
        @name = hash[:name]  
        @breed = hash[:breed]  
        @id = nil    
    end
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end
    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if not self.id
            sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            rec = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = '#{self.name}'
            SQL
            dog_values = DB[:conn].execute(rec)[0]
            self.id = dog_values[0]
        else
            sql = <<-SQL
            UPDATE dogs
            WHERE id = '#{self.id}'
            SET name = '#{self.name}', breed = '#{self.breed}'
            SQL
            DB[:conn].execute(sql)
        end
        self
    end
    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end
    def self.new_from_db(row)
        dog = {name: row[1],
        breed: row[2]}
        dog = Dog.new(dog)
        dog.id = row[0]
        dog
    end
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = '#{id}'
        SQL
        row = DB[:conn].execute(sql)[0]
        Dog.new_from_db(row)
    end
    def self.find_or_create_by(val)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = '#{val[:name]}' AND breed = '#{val[:breed]}'
        SQL
        row = DB[:conn].execute(sql)[0]  
        # binding.pry
        if row          
            # binding.pry
            Dog.new_from_db(row)

        else
            Dog.new(val)                   
        end
         
    end
end