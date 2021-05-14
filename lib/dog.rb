require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(hash)
        @id = hash[:id]
        @name = hash[:name]
        @breed = hash[:breed]
    end

    def self.create_table
        sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"

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

    def self.create(hash)
        new_dog = Dog.new(hash)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        found_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", [id]).flatten

        Dog.new(id: found_dog[0], name: found_dog[1], breed: found_dog[2])
    end

    def self.find_or_create_by(name:, breed:)
        doggo = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", [name, breed]).flatten

        #if there is a dog
            #show new Dog object but do not save
        #else
            #create Dog
        if !doggo.empty?
            found_dog = Dog.new(id: doggo[0], name: doggo[1], breed: doggo[2])
        else
            found_dog = Dog.create(name: name, breed: breed)
        end
        found_dog
    end

    def self.find_by_name(name)
        found_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", [name]).flatten

        Dog.new(id: found_dog[0], name: found_dog[1], breed: found_dog[2])
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", [name, breed, id])
    end

end
