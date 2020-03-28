
class Character
  #creating a model without db table, still need the validations to work

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :seed_number, :description
  attr_accessor :description

  validates_presence_of :name
  validates_presence_of :seed_number
  validates :seed_number, :inclusion => { :in => 1..9, message: "must be a number between 1 and 9"}

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end

end
