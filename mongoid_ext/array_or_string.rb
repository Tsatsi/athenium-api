class ArrayOrString
  attr_reader :array_or_string

  def initialize(array_or_string)
    @array_or_string = array_or_string
  end

  # Converts an object of this instance into a database friendly value.
  def mongoize
    array_or_string.is_a?(Array) ? array_or_string.join(", ") : array_or_string
  end

  class << self

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(object)
      ArrayOrString.new(object).mongoize
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(object)
      case object
        when ArrayOrString then
          object.mongoize
        else
          object
      end
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      case object
        when ArrayOrString then
          object.mongoize
        else
          object
      end
    end
  end
end