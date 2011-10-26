# encoding: UTF-8

module Robut::Plugin::Quiz::Question
  
  # This regex will find all the questions and parameters specified with the question 
  GROUP_REGEX = /['"]([^'"]+)['"]/ 
  
  def initialize(sender,request)
    @sender = sender
    process_question(request)
  end
  
  def process_question(request)
    
    parsed_parameters = request.scan(GROUP_REGEX)
    
    @question = parsed_parameters.first
    # After the target, question type, question, and answer length has been determined
    # look at all the single quoted items to find the list of parameters if there are any
    @parameters = parsed_parameters[1..-1].flatten
    
  end
  
  def to_s
    @question
  end
  
  def ask
    "@all Question '#{@question}'"
  end
  
  def captured_results
    @captured_results ||= {}
  end
  
end
