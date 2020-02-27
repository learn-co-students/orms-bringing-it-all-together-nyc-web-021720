class Dog
    attr_accessor :name, :breed, :id

    #
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    #
    def self.create_table
        sql = <<-SQL
            create table if not exists dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    #
    def self.drop_table
        sql = <<-SQL
            drop table dogs;
        SQL

        DB[:conn].execute(sql)
    end

    #
    def save
        if id then
            update
        else
            save_new
        end
    end

    #
    def save_new
        sql = <<-SQL
            insert into dogs (name, breed)
            values (?, ?)
        SQL

        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute("select last_insert_rowid()")[0][0]
        self     
    end

    #
    def self.create(name:, breed:)
        Dog.new(name: name, breed: breed).save
    end

    #
    def self.find_by_id(id_param)
        sql = <<-SQL
            select *
            from dogs
            where id = ?
        SQL

        DB[:conn].execute(sql, id_param).map do |row|
            new_from_db(row)
        end.first
    end

    #
    def self.find_by_name(name_param)
        sql = <<-SQL
            select *
            from dogs
            where name = ?
        SQL

        DB[:conn].execute(sql, name_param).map do |row|
            new_from_db(row)
        end.first
    end

    #
    def self.find_or_create_by(name:, breed:)
        dog = find_by_name(name)

        if dog == nil || dog.breed != breed then
            dog = create(name: name, breed: breed)
        end

        dog
    end

    #
    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    #
    def update
        sql = <<-SQL
            update dogs
            set name = ?, breed = ?
            where id = ?
        SQL

        DB[:conn].execute(sql, name, breed, id)
    end
end