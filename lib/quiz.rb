# encoding: UTF-8
require 'robut'

class Robut::Plugin::Quiz
  include Robut::Plugin
  
  #
  # @return [Array<String>] contains the various types of responses that are 
  #   valid usage examples that would be returned by the Help Plugin
  # 
  def usage
    [ 
      "#{at_nick} ask 'Should we break for lunch?'",
      "#{at_nick} ask for 3 minutes 'Should I continue the presentation?'",
      "#{at_nick} answer yes"
    ]
  end
  
  #
  # @param [Time] time at which the message has arrived
  # @param [String] sender_nick the sender
  # @param [String] message the message that was sent
  #
  def handle(time, sender_nick, message)
    
    # check to see if the user is asking the bot a question
    request = words(message).join(" ")
    
    if sent_to_me? message and is_a_valid_question? request
      
      enqueue_the_question sender_nick, request
      reply "@#{sender_nick}, I have added your question to the list."
      quizmaster
      
    end
    
    if sent_to_me? message and currently_asking_a_question? and is_a_valid_response? request
      process_response_for_active_question sender_nick, request
    end
    
  end
  
  QUESTION_REGEX = /^ask ?(choice|polar|range)? (?:question )?(?:(?:for )?(\d+) minutes?)?(.+)$/
  
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
  
  #
  # Return a new thread which will pop questions in the queue of questions
  # 
  def quizmaster
    if not defined?(@@quizmaster) or @@quizmaster.nil? or !@@quizmaster.alive?
      @@quizmaster = Thread.new { pop_the_question until there_are_no_more_questions_to_pop }
    end
    
    @@quizmaster
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
  
  #
  # @param [String] sender the user proposing the question
  # @param [String] request the data related to the asking and the question data itself.
  #
  def process_the_question(sender,request)
    request =~ QUESTION_REGEX
    type = Regexp.last_match(1) || 'polar'
    question_length = Regexp.last_match(2) || '2'
    question_data = Regexp.last_match(3)
    
    set_current_question create_the_question_based_on_type(type,sender,question_data), question_length
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
    
    # allow some time between the results and asking the next question
    sleep 10
    
  end
  
  def start_accepting_responses_for_this_question(question)
    @@current_question = question
  end
  
  def stop_accepting_responses_for_this_question(question)
    @@current_question = nil
  end
  
  #
  # @param [String] sender_nick the name of the person that is responding to
  #   the question.
  # @param [String] response is the answer to the question proposed.
  #
  def process_response_for_active_question(sender_nick, response)
    if @@current_question.handle_response sender_nick, response[/^answer (.+)$/,1]
      reply "Thank you, @#{sender_nick}, I have recorded your response."
    else
      reply "Sorry, @#{sender_nick}, I was unable to record that answer"
    end
  end
  
end


require_relative 'question'
require_relative 'polar'
require_relative 'range'
require_relative 'choice'