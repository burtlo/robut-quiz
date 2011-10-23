# encoding: UTF-8
require 'robut'

class Robut::Plugin::Quiz
  include Robut::Plugin
  
  def usage
    [ 
      "#{at_nick} ask polar 'Should I continue the presentation?' for 3 minutes",
    ]
  end
  
  def handle(time, sender_nick, message)
    
    # check to see if the user is asking the bot a question
    request = words(message).join(" ")
    
    if sent_to_me? message and is_a_valid_question? request
      
      enqueue_the_question sender_nick, request
      reply "@#{sender_nick}, I have enqueued your question"
      quizmaster
      
    end
    
    if sent_to_me? message and currently_asking_a_question? and is_a_valid_response? request
      process_response_for_active_question sender_nick, request
    end
    
  rescue => exception
    reply "Problem: #{exception}"
  end
  
  QUESTION_REGEX = /^ask ?(choice|polar|scale)? (?:question )?.+(?:(?:for )?(\d+) minutes?)$/
  
  def is_a_valid_question? message
    QUESTION_REGEX =~ message
  end
  
  ANSWER_REGEX = /^answer .+$/
  
  def is_a_valid_response? message
    ANSWER_REGEX =~ message
  end
  
  def enqueue_the_question(sender,question)
    (store["quiz::question::queue"] ||= []) << [sender,question]
  end
  
  def quizmaster
    @@quizmaster ||= Thread.new { pop_the_question until there_are_no_more_questions_to_pop }
  end
  
  def pop_the_question
    if popped_question = (store["quiz::question::queue"] ||= []).pop
      process_the_question *popped_question
    end
  end
  
  def there_are_no_more_questions_to_pop
    (store["quiz::question::queue"] ||= []).empty?
  end
  
  def currently_asking_a_question?
    defined? @@current_question and @@current_question
  end
  
  def process_the_question(sender,request)
    
    request =~ QUESTION_REGEX
    type = Regexp.last_match(1) || 'polar'
    question_length = Regexp.last_match(2) || '2' 
    
    set_current_question create_the_question_based_on_type(type,sender,request), question_length
  end
  
  #
  # @param [String] question_type the name of the question type which will be
  #   converted from a String to the Class name within the current namespace.
  # @param [String] sender the sender of the question
  # @param [String] request the entire message that initiated the question 
  #
  def create_the_question_based_on_type(question_type,sender,request)
    self.class.const_get(question_type.capitalize).new sender, request
  end
  
  def set_current_question(question,length_of_time)
    
    start_accepting_responses_for_this_question question
    
    reply question.ask

    sleep length_of_time.to_i * 60
    
    stop_accepting_responses_for_this_question question
    
    reply "The results are in for '#{question}':"
    reply question.results
    
  end
  
  def start_accepting_responses_for_this_question(question)
    @@current_question = question
  end
  
  def stop_accepting_responses_for_this_question(question)
    @@current_question = nil
  end
  
  def process_response_for_active_question(sender_nick, request)
    if @@current_question.handle_response sender_nick, request
      reply "@#{sender_nick} I have received a response"
    else
      reply "@#{sender_nick} I did not understand that answer"
    end
  end
  
end




module Robut::Plugin::Quiz::Question
  
  # @see ask%20%3F(choice%7Cpolar%7Cscale)%3F%20(%3F%3Aquestion%20)%3F'(%5B%5E'%5D%2B)'%5B%5Cs%2C%5D*((%3F%3A'%5B%5E'%5D%2B'%5B%5Cs%2C%5D*)*)%2B(%3F%3A(%3F%3Afor%20)%3F(%5Cd%2B)%20minutes%3F)%3F
  # 
  # 1st: question type - choice, polar, scale
  # 2nd: question
  # 3rd: choices
  #
  QUESTION_REGEX = /^ask ?(choice|polar|scale)? (?:question )?['"]([^'"]+)['"][\s,]*((?:['"][^'"]+['"][\s,]*)*)*(?:(?:for )?(\d+) minutes?)?$/
  
  # This regex will find all the questions and parameters specified with the question 
  GROUP_REGEX = /['"]([^'"]+)['"]/ 
  
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
    
  end
  
  def to_s
    @question
  end
  
  def ask
    "@all Question '#{@question}'"
  end
  
end

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