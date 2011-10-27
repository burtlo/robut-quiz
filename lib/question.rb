# encoding: UTF-8

module Robut::Plugin::Quiz::Question
  
  # This regex will find all the questions and parameters specified with the question 
  GROUP_REGEX = /['"]([^'"]+)['"]/ 
  
  #
  # Initialize the question with the asker of the question and the details about
  # question that is being asked.
  # 
  # @param [String] sender the name of the person asking the question.
  # @param [String] question_with_parameters this is the remaining question and
  #   parameters left on the question posed to the chat room.
  # 
  def initialize(sender,question_with_parameters)
    @sender = sender
    process_question(question_with_parameters)
  end
  
  #
  # This is used internally to process the the question and parameters that sent
  # to the question.
  # 
  # @param [String] question_with_parameters this is the remaining question and
  #   parameters left on the question posed to the chat room.
  #
  def process_question(question_with_parameters)
    
    parsed_elements = question_with_parameters.scan(GROUP_REGEX)
    
    @question = parsed_elements.first.first
    # After the target, question type, question, and answer length has been determined
    # look at all the single quoted items to find the list of parameters if there are any
    @parameters = Array(parsed_elements[1..-1].flatten)
    
  end
  
  #
  # @return [String] the question that is being asked.
  def to_s
    @question
  end
  
  #
  # Ask the question that has been proposed.
  # 
  # @return [String] a string that asks the question in the chat room.
  def ask
    "@all Question '#{@question}'"
  end
  
  #
  # Maintains a list of the results that have been captured for the question.
  # The hash that is maintained would be used with the user's nickname as the
  # key and the value as a response to the question.
  # 
  # @return [Hash] used for storing responses from the various senders.
  # 
  def captured_results
    @captured_results ||= {}
  end
  
end
