# encoding: UTF-8

class Robut::Plugin::Quiz::Polar
  include Robut::Plugin::Quiz::Question
  
  YES_ANSWER = /y|yes/i
  NO_ANSWER = /n|no/i
  
  def handle_response(sender_nick,response)
    
    if response =~ YES_ANSWER
      store_positive_response_for sender_nick
    elsif response =~ NO_ANSWER
      store_negative_response_for sender_nick
    else
      nil
    end
    
  end
  
  def results
    
    yes_votes = no_votes = 0
    
    captured_results.each_pair do |key,value|
      yes_votes = yes_votes + 1 if value
      no_votes = no_votes + 1 unless value
    end
    
    "#{yes_votes} YES vote#{yes_votes != 1 ? 's' : ''} and #{no_votes} NO vote#{no_votes != 1 ? 's' : ''}"
  end
  
  def captured_results
    @captured_results ||= {}
  end
  
  def store_positive_response_for sender_nick
    captured_results[sender_nick] = true
  end
  
  def store_negative_response_for sender_nick
    captured_results[sender_nick] = false
  end
  
end