
class Character
  #creating a model without db table, still need the validations to work
  MAGIC_WORDS = ['gamma', 'radioactive']

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :description, :image_url, :url
  attr_accessor :description

  validates_presence_of :name
  validates_presence_of :description, message: 'This character does not have a description. Please choose another.'


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end

  def description_split#getting an clean array of words from the description text
    self.description.split(/[^[[:word:]]]+/)
  end

  def word(index)
    i = index - 1
    magic_words = Character::MAGIC_WORDS
    words = self.description_split

    if words.any?
      words = words.map(&:downcase)
      if magic_words.select{|magic| words.include?(magic.downcase)}.any? #first checking if any magic words are included
        return  magic_words.select{|magic| words.include?(magic.downcase)}.first
      else#else return the word with specific index
        return words[i]
      end
    else
      ""
    end
  end

end
