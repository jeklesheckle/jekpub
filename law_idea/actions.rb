# this file contains class outlines for actions and Fields
# actions are not objects, they are simply arrays of Fields accessed by name
# thinking about changing that fact ^^^^

# TODO:
# * add more example actions
# * add a checker to Action.init that ensure the fields are valid

class Field
  attr_reader :prompt, :type, :response
  def initialize(prompt, type)
    @prompt = prompt

    if type != "string" && type != "int" && type != "bool" then
      raise ArgumentError.new "invalid Field type given"
    end

    @type = type
    @response = nil
  end

  def set_response(new_response)
    case type
    when "string"
      @response = new_response.to_s
    when "bool"
      if new_response == "true" then
        @response = true
      elsif new_response == "false" then
        @response = false
      else
        raise ArgumentError.new("cannot set response for a boolean field to a non-boolean value (value: #{})", new_response)
      end
    when "int"
      @response = new_response.to_i
    end
  end
end


#this class is just a wrapper for an array of fields
class Action
  def initialize
    @fields = []
  end

  def fields
    @fields
  end

  def <<(field)
    @fields << field
  end
end
