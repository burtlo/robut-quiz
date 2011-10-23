# encoding: UTF-8
require 'robut'

class Robut::Plugin::Quiz
  include Robut::Plugin
  
  QUESTION_REGEX = /^ask ?(choice|polar|scale)? (?:question )?.+(?:(?:for )?(\d+) minutes?)$/

  def usage
    [ 
      "#{at_nick} ask choice question 'What do you want for lunch?', 'pizza', 'sandwich', 'salad' for 1 minute",
      "#{at_nick} ask polar 'Should I continue the presentation?' for 3 minutes",
      "#{at_nick} ask scale 'how much did you like the presentation?', '1..5' for 2 minutes",
      "#{at_nick} ask 'Should I continue the presentation?', 'y|yes', 'n|no' for 1 minutes"
    ]
  end
  
  def handle(time, sender_nick, message)
    
    # check to see if the user is asking the bot a question
    request = words(message).join(" ")
    
    if sent_to_me? message and is_a_valid_question? request
      
      enqueue_the_question time, sender_nick, request
      
    end
    
    if sent_to_me? message and currently_asking_a_question?
      
      process_response_for_active_question time, sender_nick, request
      
    end
    
  end
  
  def is_a_valid_question? message
    QUESTION_REGEX =~ message
  end
  
  def enqueue_the_question(time,sender,question)
    # enqueue the question with a unique identifier
    (store["quiz::question_queue"] ||= []) << [time,sender,question]
    # start a worker thread unless one has already been started
  end
  
  
  # if there are no active questions then ask the question
  # TODO: create the question worker
  
  def currently_asking_a_question?
    @current_question
  end
  
  def process_the_question(time,sender,request)
    
    request =~ QUESTION_REGEX
    type = Regexp.last_match(1) || 'polar'
    question_length = Regexp.last_match(2) || '2' 
    
    set_current_question create_the_question_based_on_type(type,sender,request), question_length
  end
  
  def create_the_question_based_on_type(question_type,sender,request)
    self.class.const_get(question_type.capitalize).new sender, request
  end
  
  def set_current_question(question,length_of_time)
    
    start_accepting_responses_for_this_question question
    
    reply question.ask_question
    
    sleep length_of_time.to_i * 60
    
    stop_accepting_responses_for_this_question question
    
    question.declare_results
    
  end
  
  def start_accepting_responses_for_this_question(question)
    @current_question = question
  end
  
  def stop_accepting_responses_for_this_question(question)
    @current_question = nil
  end
  
end

module Robut::Plugin::Quiz::Question
  
  # @see ask%20%3F(choice%7Cpolar%7Cscale)%3F%20(%3F%3Aquestion%20)%3F'(%5B%5E'%5D%2B)'%5B%5Cs%2C%5D*((%3F%3A'%5B%5E'%5D%2B'%5B%5Cs%2C%5D*)*)%2B(%3F%3A(%3F%3Afor%20)%3F(%5Cd%2B)%20minutes%3F)%3F
  # 
  # 1st: question type - choice, polar, scale
  # 2nd: question
  # 3rd: choices 
  #
  QUESTION_REGEX = /^ask ?(choice|polar|scale)? (?:question )?'([^']+)'[\s,]*((?:'[^']+'[\s,]*)*)*(?:(?:for )?(\d+) minutes?)?$/
  
  # This regex will find all the questions and parameters specified with the question 
  GROUP_REGEX = /'([^']+)'/ 
  
  def initialize(sender,request)
    @sender = sender
    process_question(request)
  end
  
  def process_question(request)
    
    request =~ QUESTION_REGEX
    @question = Regexp.last_match(2)
    # After the target, question type, question, and answer length has been determined
    # look at all the single quoted items to find the list of parameters if there are any
    @parameters = request.scan(GROUP_REGEX)[1..-1].flatten
    
    # puts "Request: #{request}"
    # puts %{ 
    #   type:       #{question_type}
    #   questions:  #{question}
    #   parameters: #{parameters} 
    #   time:       #{answer_length} }
    
  end
  
end

class Robut::Plugin::Quiz::Polar
  include Robut::Plugin::Quiz::Question
  
  def ask_question
    "@#{@sender} asks '#{@question}' (yes/no)"
  end
  
  def handle_response(time,sender_nick,response)
    # process a yes/no y/n - store results per user
  end
  
  def declare_results
    
  end
  
end