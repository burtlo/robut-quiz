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
  
  describe "#handle" do
    
    context "when a polar question is asked" do
      
      it "should find all the components of the question" do

        subject.should_receive(:handle_polar).with('Should I continue the presentation?',nil,'3')
        subject.handle Time.now,'person',"@quizmaster ask polar 'Should I continue the presentation?' for 3 minutes"
        
      end
      
    end
    
    context "when a choice question is asked" do
      
      it "should find all the components of the question" do
        
        subject.should_receive(:handle_choice).with('What should I talk about next?',"'x', 'y', 'z'",'2')
        subject.handle Time.now,'person',"@quizmaster ask choice 'What should I talk about next?', 'x', 'y', 'z'"
        
      end
      
    end
    
  end
    
end