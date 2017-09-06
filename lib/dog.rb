class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash = {})
    @name = dog_hash[:name] || dog_hash["name"]
    @breed = dog_hash[:breed] || dog_hash["breed"]
    @id = dog_hash["id"] || nil
  end

  def self.create_table
    sql_create = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
      SQL

      DB[:conn].execute(sql_create)
  end

  def self.drop_table
    sql_drop = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql_drop)
  end

  def save
    unless self.id

      sql_persist = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?);
      SQL

      DB[:conn].execute(sql_persist, self.name, self.breed)

      sql_get_id = <<-SQL
        SELECT last_insert_rowid() FROM dogs;
      SQL

      @id = DB[:conn].execute(sql_get_id)[0][0]
    else
      # self.upate
    end
    self
  end

  def self.create(new_dog_hash)
    new_dog = self.new(new_dog_hash)
    new_dog.save
  end

  def self.find_by_id(id_to_find)
    DB[:conn].results_as_hash = true
    sql_find_id = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.id = ?
    SQL
    self.new(DB[:conn].execute(sql_find_id,id_to_find)[0])
    # binding.pry
  end

  def self.find_or_create_by(find_hash)
    sql_find = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    local_name = find_hash[:name]
    local_breed = find_hash[:breed]
    find_dog = DB[:conn].execute(sql_find, local_name, local_breed)
    # binding.pry
    if find_dog.empty?
      self.create(find_hash)
    else
      self.create(find_dog[0])
    end

  end

  def self.new_from_db(row)
    self.new({:name => row[1], "id" => row[0], :breed => row[2]})
  end

  def self.find_by_name(find_name)

    DB[:conn].results_as_hash = true
    sql_find = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    self.new(DB[:conn].execute(sql_find, find_name)[0])

  end

  def update
    sql_update = <<-SQL
      UPDATE dogs
      SET (name, breed) = (?, ?)
      WHERE id = ?
    SQL

    DB[:conn].execute(sql_update, self.name, self.breed, self.id)
  end


end
