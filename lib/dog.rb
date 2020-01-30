require 'pry'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

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
        id = row[0]
        name = row[1]
        breed = row[2]
        attr_hash = {:id => id, :name => name, :breed => breed}
        # self.new(attr_hash)
        # attr_hash.save
        # binding.pry
    end

    

end