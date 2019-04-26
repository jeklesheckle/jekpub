# this file contains class outlines for actions and Fields
# actions are not objects, they are simply arrays of Fields accessed by name

# TODO:
# * add more example actions
# * perhaps enhance the

private class Field
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
  end
end


ALL_ACTIONS = {
  "murder" => [
    Field.new("perpetrator", "string"),
    Field.new("mentally aware", "bool")
  ]
}

def create_action(action_name)
  new_action = ALL_ACTIONS[action_name]

  if new_action == nil then
    raise ArgumentError.new "invalid action name, cannot create action."
  end

  new_action
end
