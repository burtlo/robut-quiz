# encoding: UTF-8

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
