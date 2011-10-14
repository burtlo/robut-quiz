# encoding: UTF-8
require 'robut'

class Robut::Plugin::Quiz
  include Robut::Plugin
  
  # @see http://rubular.com?regex=ask%20%3F(choice%7Cpolar%7Cscale)%3F%20(%3F%3Aquestion%20)%3F'(%5B%5E'%5D%2B)'%5B%5Cs%2C%5D*(%3F%3A'(%5B%5E'%5D%2B)'%5B%5Cs%2C%5D*)*(%3F%3A(%3F%3Afor%20)%3F(%5Cd%2B)%20minutes%3F)%3F
  # 
  # 1st: question type - choice, polar, scale
  # 2nd: question
  # 3rd: choices 
  # 
  QUESTION_REGEX = /^ask ?(choice|polar|scale)? (?:question )?'([^']+)'[\s,]*(?:'([^']+)'[\s,]*)*(?:(?:for )?(\d+) minutes?)?$/
  
  def usage
    [ 
      "#{at_nick} ask choice (question) 'What do you want for lunch?', 'pizza', 'sandwich', 'salad' for 1 minute",
      "#{at_nick} ask polar (question) 'Should I continue the presentation?' for 3 minutes",
      "#{at_nick} ask scale (question) 'how much did you like the presentation?', '1..5'",
      "#{at_nick} ask 'Should I continue the presentation?', 'y|yes', 'n|no' for 1 minutes"
    ]
  end
  
  def handle(time, sender_nick, message)
    
    # check to see if the user is asking the bot a question
    
    if sent_to_me? message and is_a_question? message
      
      
      
      
    end
    
    # check to see what time of question the user is asking
    
    # allow each question to handle the question appropriately for the default
    
  end
  
  def is_a_valid_question? message
    message =~ QUESTION_REGEX
  end
  
end
