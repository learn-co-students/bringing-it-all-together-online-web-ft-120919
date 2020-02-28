class Dog
    attr_accessor :breed, :name, :id

    def initialize(breed:, name:, id:nil)
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

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)

        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        # binding.pry
        dog_info = DB[:conn].execute(sql, id)[0]
        Dog.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_info = dog[0]
            dog = self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
          else
            dog = self.create(name: name, breed: breed)
          end
        dog
    end

    def self.find_by_name(name)
        dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    end
end