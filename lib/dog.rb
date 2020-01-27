class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def save 
        #saves instance of dog class to the database
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, @name, @breed)
        #gets id from database
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        #returns instance of dog class from db
        self
    end

    def self.create(id: nil, name:, breed:)
        new_dog = self.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id_num)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id_num)[0]
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        #find if dog exists in db by checking attributes against table values
        sql = "SELECT * FROM dogs WHERE name = ? and breed = ?"
        found_dog = DB[:conn].execute(sql, name, breed)
        
        if found_dog.empty?
            #if dog doesn't exist create dog with attributes
            self.create(name: name, breed: breed)
        else 
            #if dog does exist create ruby object from database
            self.new_from_db(found_dog[0])
        end
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        self.new_from_db(row)
    end

    def update 
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end
end