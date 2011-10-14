require_relative 'spec_helper'

describe Robut::Plugin::Quiz do
  
  subject { 
    connection = double("connection")
    connection.stub_chain(:config, :nick) { "quizmaster" }
    Robut::Plugin::Quiz.new connection 
  }
  
  
  [ 
    "ask choice 'What do you want for lunch?', 'pizza', 'sandwich', 'salad' for 1 minute",
    "ask polar 'Should I continue the presentation?' for 3 minutes",
    "ask scale question 'how much did you like the presentation?', '1..5'",
    "ask 'Should I continue the presentation?', 'y|yes', 'n|no' for 1 minutes"
    
  ].each do |question|
  
    it "should match the question: '#{question}'" do
      
      subject.is_a_valid_question?(question).should be_true
      
    end
    
  end
    
end