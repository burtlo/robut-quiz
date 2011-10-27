# encoding: UTF-8

class Robut::Plugin::Quiz::Range
  include Robut::Plugin::Quiz::Question
  
  RANGE_VALUES = /(\d+)(?:-|\.\.)(\d+)/
  
  def handle_response(sender_nick,response)
    
    if within_range? response
      store_range_response_for sender_nick, response
      true
    else
      false
    end
    
  end
  
  def start_value
    if Array(@parameters).first.to_s =~ RANGE_VALUES
      Regexp.last_match(1).to_i
    else
      1
    end
  end
  
  def highest_value
    if Array(@parameters).first.to_s =~ RANGE_VALUES
      Regexp.last_match(2).to_i
    else
      5
    end
  end
  
  def within_range?(value)
    value.to_i >= start_value and value.to_i <= highest_value
  end
  
  def ask
    "@all Question '#{@question}' (#{start_value}..#{highest_value})"
  end
  
  def results
    return "I'm sorry, not enough votes were cast to be create a summary." if captured_results.length == 0
    
    result_values = captured_results.values.extend Robut::Plugin::Quiz::Range::Averages
    "#{result_values.length} votes with a mean of #{result_values.mean}"
  end
  
  def store_range_response_for(sender_nick,value)
    captured_results[sender_nick] = value.to_i
  end
  
  
  module Averages
    
    def sum
      inject(:+)
    end
    
    def mean
      return 0 if length == 0
      sum.to_f / length.to_f
    end
    
    def mode
      frequency = inject(Hash.new(0)) { |hash,value| hash[value] += 1; hash }
      sort_by {|value| frequency[value] }.last
    end
    
  end
  
end
