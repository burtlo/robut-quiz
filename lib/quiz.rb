# encoding: UTF-8
require 'robut'

class Robut::Plugin::Quiz
  include Robut::Plugin
  
  # @see ask%20%3F(choice%7Cpolar%7Cscale)%3F%20(%3F%3Aquestion%20)%3F'(%5B%5E'%5D%2B)'%5B%5Cs%2C%5D*((%3F%3A'%5B%5E'%5D%2B'%5B%5Cs%2C%5D*)*)%2B(%3F%3A(%3F%3Afor%20)%3F(%5Cd%2B)%20minutes%3F)%3F
  # 
  # 1st: question type - choice, polar, scale
  # 2nd: question
  # 3rd: choices 
  # 
  QUESTION_REGEX = /^ask ?(choice|polar|scale)? (?:question )?'([^']+)'[\s,]*((?:'[^']+'[\s,]*)*)*(?:(?:for )?(\d+) minutes?)?$/
  
  # This regex will find all the questions and parameters specified with the question 
  GROUP_REGEX = /'([^']+)'/ 
  

  def usage
    [ 
      "#{at_nick} ask choice question 'What do you want for lunch?', 'pizza', 'sandwich', 'salad' for 1 minute",
      "#{at_nick} ask polar 'Should I continue the presentation?' for 3 minutes",
      "#{at_nick} ask scale 'how much did you like the presentation?', '1..5'",
      "#{at_nick} ask 'Should I continue the presentation?', 'y|yes', 'n|no' for 1 minutes"
    ]
  end
  
  def handle(time, sender_nick, message)
    
    # check to see if the user is asking the bot a question
    request = words(message).join(" ")
    
    if sent_to_me? message and is_a_valid_question? request
      
      request =~ QUESTION_REGEX
      
      question_type = Regexp.last_match(1) || 'choice'
      question = Regexp.last_match(2)
      answer_length = Regexp.last_match(4) || '2 minutes'

      # After the target, question type, question, and answer length has been determined
      # look at all the single quoted items to find the list of parameters if there are any
      parameters = request.scan(GROUP_REGEX)[1..-1].flatten
      
      puts "Request: #{request}"
      puts %{ 
        type:       #{question_type}
        questions:  #{question}
        parameters: #{parameters} 
        time:       #{answer_length} }
      
      case question_type
      when 'polar'
        handle_polar(question,parameters,answer_length)
      when 'choice'
        handle_choice(question,parameters,answer_length)
      when 'scale'
        handle_scale(question,parameters,answer_length)
      else
        puts "failed to find a question type"
      end
      
      
    end
    
    # check to see what time of question the user is asking
    
    # allow each question to handle the question appropriately for the default
    
  end
  
  def handle_polar(question,parameters,length)
    puts "#{question} #{parameters} #{length}"
  end
  
  def handle_choice(question,parameters,length)
    puts "#{question} #{parameters} #{length}"
  end
  
  def handle_scale(question,parameters,length)
    puts "#{question} #{parameters} #{length}"
  end
  
  def is_a_valid_question? message
    QUESTION_REGEX =~ message
  end
  
end
