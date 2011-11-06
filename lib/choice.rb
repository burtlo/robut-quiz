# encoding: UTF-8

class Robut::Plugin::Quiz::Choice
  include Robut::Plugin::Quiz::Question
  
  def ask
    "@all Question '#{@question}' (#{@parameters.map {|p| "'#{p}'" }.join("/")})"
  end
  
  def handle_response(sender_nick,response)
    
    if a_valid_choice response
      store_response sender_nick, response
      true
    else
      false
    end
    
  end
  
  def a_valid_choice(response)
    @parameters.find {|choice| choice == response }
  end
  
  def store_response(sender_nick,response)
    captured_results[sender_nick] = response
  end
  
  def results
    
    response = @parameters.map do |choice|
      found = captured_results.values.find_all {|result| result == choice }
      
      "#{found.length} '#{choice}'" unless found.empty?
      
    end.compact.join(", ")
    
    response.empty? ? "No votes have been made" : response
    
  end
  
end