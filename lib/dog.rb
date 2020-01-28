require 'pry'
class Dog
    attr_accessor :name, :id, :breed
    def initialize(id:nil,name:,breed:)
        @name = name 
        @id = id
        @breed = breed 
    end 
    def self.create_table 
        sql = <<-SQL
            CREATE TABLE dogs
            (id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT)
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
        sql = <<-DUMPSTERFIRE
                INSERT INTO dogs (name,breed)
                VALUES (?,?)
            DUMPSTERFIRE
            DB[:conn].execute(sql,self.name,self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self 
    end 
    def self.create(name: , breed:)
        self.new(name:name, breed:breed).save
    end 
    def self.new_from_db(row)
        new_dog = self.new(id:id, name:name, breed:@breed)
        new_dog.id = row[0]
        new_dog.name = row[1]
        new_dog.breed = row[2]
    end 
end 
yield ;)